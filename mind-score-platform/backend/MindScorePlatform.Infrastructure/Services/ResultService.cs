using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Services.Mpi;
using MindScorePlatform.Infrastructure.Services.Scoring;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Provides read access and follow-up submission for scored assessment results.
/// </summary>
public sealed class ResultService : IResultService
{
    private readonly IResultRepository _results;
    private readonly ITestRepository   _tests;

    public ResultService(IResultRepository results, ITestRepository tests)
    {
        _results = results;
        _tests   = tests;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ResultDto>> GetByUserIdAsync(
        Guid userId, CancellationToken cancellationToken)
    {
        var results = await _results.GetByUserIdAsync(userId, cancellationToken);
        var dtos = new List<ResultDto>(results.Count);

        foreach (var r in results)
        {
            var test = await _tests.GetByIdAsync(r.TestId, cancellationToken);
            dtos.Add(ResultDtoMapper.ToDto(r, test?.Name ?? string.Empty));
        }

        return dtos;
    }

    /// <inheritdoc/>
    public async Task<ResultDto> GetByIdAsync(
        Guid id, Guid userId, CancellationToken cancellationToken)
    {
        var result = await _results.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Result {id} not found.");

        if (result.UserId != userId)
            throw new UnauthorizedAccessException("Access denied.");

        var test = await _tests.GetByIdAsync(result.TestId, cancellationToken);
        return ResultDtoMapper.ToDto(result, test?.Name ?? string.Empty);
    }

    /// <inheritdoc/>
    public async Task<ResultDto> SubmitFollowUpAsync(
        Guid resultId, Guid userId, SubmitFollowUpDto dto, CancellationToken cancellationToken)
    {
        var result = await _results.GetByIdAsync(resultId, cancellationToken)
            ?? throw new KeyNotFoundException($"Result {resultId} not found.");

        if (result.UserId != userId)
            throw new UnauthorizedAccessException("Access denied.");

        if (string.IsNullOrEmpty(result.AiFollowUpJson))
            throw new InvalidOperationException("This result has no follow-up questions.");

        var payload = JsonSerializer.Deserialize<AiFollowUpPayload>(result.AiFollowUpJson, ResultDtoMapper.CamelCase)
            ?? throw new InvalidOperationException("Follow-up payload could not be parsed.");

        if (payload.Questions.Count == 0)
            throw new InvalidOperationException("No follow-up questions found on this result.");

        var validIds = payload.Questions.Select(q => q.Id).ToHashSet();
        foreach (var answer in dto.Answers)
        {
            if (!validIds.Contains(answer.QuestionId))
                throw new InvalidOperationException($"Unknown follow-up question ID: {answer.QuestionId}");
        }

        payload.Answers = dto.Answers;

        // Apply majority-vote reclassification against the original dimension scores.
        var dimensions = JsonSerializer.Deserialize<Dictionary<string, MpiDimensionScore>>(
            result.DimensionScoresJson ?? "{}", ResultDtoMapper.CamelCase) ?? new();

        var reclassified = Reclassify(dimensions, payload);

        var newTypeCode = BuildTypeCode(reclassified);
        var profile     = MpiTypeProfileLibrary.GetProfile(newTypeCode);

        var insightsPayload = new
        {
            strengths          = profile.Strengths,
            growthAreas        = profile.GrowthAreas,
            careerPaths        = profile.CareerPaths,
            communicationStyle = profile.CommunicationStyle,
            workStyle          = profile.WorkStyle,
        };

        var updatedFollowUpJson     = JsonSerializer.Serialize(payload,         ResultDtoMapper.CamelCase);
        var updatedDimensionJson    = JsonSerializer.Serialize(reclassified,    ResultDtoMapper.CamelCase);
        var updatedInsightsJson     = JsonSerializer.Serialize(insightsPayload, ResultDtoMapper.CamelCase);

        await _results.UpdateAfterFollowUpAsync(
            resultId,
            updatedFollowUpJson,
            updatedDimensionJson,
            updatedInsightsJson,
            newTypeCode,
            profile.TypeName,
            profile.Emoji,
            profile.Tagline,
            cancellationToken);

        // Reflect all updates in the returned DTO without a second DB round-trip.
        result.AiFollowUpJson      = updatedFollowUpJson;
        result.DimensionScoresJson = updatedDimensionJson;
        result.InsightsJson        = updatedInsightsJson;
        result.PersonalityType     = newTypeCode;
        result.PersonalityName     = profile.TypeName;
        result.PersonalityEmoji    = profile.Emoji;
        result.PersonalityTagline  = profile.Tagline;

        var test = await _tests.GetByIdAsync(result.TestId, cancellationToken);
        return ResultDtoMapper.ToDto(result, test?.Name ?? string.Empty);
    }

    // ── Reclassification ──────────────────────────────────────────────────────

    /// <summary>
    /// Applies majority-vote reclassification to dimension scores based on
    /// the follow-up answers selected by the user.
    ///
    /// For each dimension that appears in any answer's DimensionImpact:
    ///   - Collect all impact values (1–5 scale) across every answer that touches it.
    ///   - Average them. &gt;3 = high pole wins; &lt;3 = low pole wins; =3 = no change.
    ///   - If the vote contradicts the current DominantPole, mirror the percentage
    ///     around 50 (i.e. new = 100 − old) to flip the pole while preserving strength.
    /// </summary>
    private static Dictionary<string, MpiDimensionScore> Reclassify(
        Dictionary<string, MpiDimensionScore> dimensions,
        AiFollowUpPayload payload)
    {
        // Build a lookup: questionId → selected option.
        var optionByQuestion = payload.Questions
            .Join(payload.Answers,
                q => q.Id,
                a => a.QuestionId,
                (q, a) => (Question: q, Answer: a))
            .Where(x => x.Answer.OptionIndex >= 0 && x.Answer.OptionIndex < x.Question.Options.Count)
            .ToDictionary(
                x => x.Question.Id,
                x => x.Question.Options[x.Answer.OptionIndex]);

        // Aggregate impact values per dimension across all answered questions.
        var impactAccumulator = new Dictionary<string, List<int>>();
        foreach (var option in optionByQuestion.Values)
        {
            foreach (var (dim, value) in option.DimensionImpact)
            {
                if (!impactAccumulator.ContainsKey(dim))
                    impactAccumulator[dim] = new List<int>();
                impactAccumulator[dim].Add(value);
            }
        }

        // Clone dimensions so we don't mutate the original dictionary.
        var updated = dimensions.ToDictionary(
            kv => kv.Key,
            kv => new MpiDimensionScore
            {
                Percentage   = kv.Value.Percentage,
                DominantPole = kv.Value.DominantPole,
                Strength     = kv.Value.Strength,
            });

        foreach (var (dim, values) in impactAccumulator)
        {
            if (!updated.ContainsKey(dim)) continue;

            var avg     = values.Average();
            var current = updated[dim];

            // avg == 3 means perfectly split — no change.
            if (Math.Abs(avg - 3.0) < 0.01) continue;

            var voteIsHighPole = avg > 3.0;
            var currentIsHighPole = current.Percentage >= 50.0;

            // Only flip when the vote contradicts the current pole.
            if (voteIsHighPole == currentIsHighPole) continue;

            var newPct      = 100.0 - current.Percentage;
            var newPole     = DimensionHighPole(dim);
            var newStrength = TensionDetector.ClassifyStrength(newPct);

            updated[dim] = new MpiDimensionScore
            {
                Percentage   = newPct,
                DominantPole = voteIsHighPole ? newPole : DimensionLowPole(dim),
                Strength     = newStrength,
            };
        }

        return updated;
    }

    private static string BuildTypeCode(Dictionary<string, MpiDimensionScore> dims)
    {
        static string Pole(Dictionary<string, MpiDimensionScore> d, string key, string high, string low)
            => d.TryGetValue(key, out var s) && s.Percentage >= 50 ? high : low;

        return Pole(dims, "EnergySource",   "E", "R")
             + Pole(dims, "PerceptionMode", "O", "I")
             + Pole(dims, "DecisionStyle",  "L", "V")
             + Pole(dims, "LifeApproach",   "S", "A");
    }

    private static string DimensionHighPole(string dim) => dim switch
    {
        "EnergySource"   => "E",
        "PerceptionMode" => "O",
        "DecisionStyle"  => "L",
        "LifeApproach"   => "S",
        _                => dim,
    };

    private static string DimensionLowPole(string dim) => dim switch
    {
        "EnergySource"   => "R",
        "PerceptionMode" => "I",
        "DecisionStyle"  => "V",
        "LifeApproach"   => "A",
        _                => dim,
    };

}
