using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;
using MindScorePlatform.Infrastructure.Services.Mpi;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Handles the submission and scoring pipeline for all assessment types.
/// </summary>
/// <remarks>
/// <para>
/// Receiving a set of answers triggers the following pipeline:
/// <list type="number">
///   <item>Validate that the test exists and at least one answer was provided.</item>
///   <item>Route to the appropriate engine based on the test name:
///     <see cref="MindScoreTestName"/> → <see cref="IMindScoringEngine"/>,
///     everything else → <see cref="IMpiScoringEngine"/>.</item>
///   <item>Persist raw responses (replacing any previous attempt for the same user/test).</item>
///   <item>Run the scoring engine and build a <see cref="Result"/> entity.</item>
///   <item>Upsert the result and return a <see cref="ResultDto"/>.</item>
/// </list>
/// </para>
/// <para>
/// The upsert pattern (delete-then-insert on responses, AddOrReplace on results)
/// ensures that retaking a test always reflects the most recent attempt.
/// </para>
/// </remarks>
public sealed class ResponseService : IResponseService
{
    /// <summary>
    /// The canonical test name used to identify MindScore cognitive assessments.
    /// Routing logic branches on this value; changing the name in the database
    /// requires updating this constant accordingly.
    /// </summary>
    private const string MindScoreTestName = "MindScore Assessment";

    /// <summary>
    /// Shared camelCase serialiser options used when storing JSON payloads in
    /// the database.  Defined once to avoid repeated allocation.
    /// </summary>
    private static readonly JsonSerializerOptions CamelCase =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    private readonly IResponseRepository  _responses;
    private readonly IResultRepository    _results;
    private readonly ITestRepository      _tests;
    private readonly IQuestionRepository  _questions;
    private readonly IMpiScoringEngine    _mpiEngine;
    private readonly IMindScoringEngine   _mindEngine;
    private readonly IAiFollowUpService   _aiFollowUp;
    private readonly AppDbContext         _db;

    public ResponseService(
        IResponseRepository responses,
        IResultRepository results,
        ITestRepository tests,
        IQuestionRepository questions,
        IMpiScoringEngine mpiEngine,
        IMindScoringEngine mindEngine,
        IAiFollowUpService aiFollowUp,
        AppDbContext db)
    {
        _responses  = responses;
        _results    = results;
        _tests      = tests;
        _questions  = questions;
        _mpiEngine  = mpiEngine;
        _mindEngine = mindEngine;
        _aiFollowUp = aiFollowUp;
        _db         = db;
    }

    /// <inheritdoc/>
    public async Task<ResultDto> SubmitAsync(
        Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        if (!dto.Answers.Any())
            throw new InvalidOperationException(
                "No answers were submitted. Please complete the assessment before submitting.");

        // Route based on test type: MindScore uses age-band norms; everything
        // else is treated as an MPI personality assessment.
        return test.Name == MindScoreTestName
            ? await SubmitMindScoreAsync(userId, dto, test.Name, cancellationToken)
            : await SubmitMpiAsync(userId, dto, test.Name, cancellationToken);
    }

    // ── MPI path ──────────────────────────────────────────────────────────────

    /// <summary>
    /// Persists responses and scores an MPI (MindType Profile Inventory) submission.
    /// </summary>
    private async Task<ResultDto> SubmitMpiAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questionMap = await BuildQuestionMapAsync(dto.TestId, ct);

        await PersistResponsesAsync(userId, dto.Answers, questionMap, ct);

        var scoringInputs = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId) && int.TryParse(a.Value, out _))
            .Select(a => new MpiResponseInput
            {
                QuestionId = questionMap[a.QuestionId].Code,
                Value      = int.Parse(a.Value),
            })
            .ToList();

        var mpiResult = _mpiEngine.Score(scoringInputs);

        // Detect tensions and compute dimension confidence scores.
        var (_, confidence) = TensionDetector.Detect(mpiResult.Dimensions);

        // Generate AI follow-up questions for ambiguous dimensions (silently skipped on failure).
        var followUp = await _aiFollowUp.GenerateAsync(mpiResult.Dimensions, ct);

        var insightsPayload = new
        {
            strengths          = mpiResult.Strengths,
            growthAreas        = mpiResult.GrowthAreas,
            careerPaths        = mpiResult.CareerPaths,
            communicationStyle = mpiResult.CommunicationStyle,
            workStyle          = mpiResult.WorkStyle,
        };

        var result = new Result
        {
            Id                      = Guid.NewGuid(),
            UserId                  = userId,
            TestId                  = dto.TestId,
            Score                   = mpiResult.OverallScore,
            PersonalityType         = mpiResult.TypeCode,
            PersonalityName         = mpiResult.TypeName,
            PersonalityEmoji        = mpiResult.Emoji,
            PersonalityTagline      = mpiResult.Tagline,
            DimensionScoresJson     = JsonSerializer.Serialize(mpiResult.Dimensions, CamelCase),
            InsightsJson            = JsonSerializer.Serialize(insightsPayload, CamelCase),
            Context                 = dto.Context,
            DimensionConfidenceJson = JsonSerializer.Serialize(confidence, CamelCase),
            AiFollowUpJson          = followUp is not null
                                          ? JsonSerializer.Serialize(followUp, CamelCase)
                                          : null,
            CreatedAtUtc            = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ToDto(result, testName);
    }

    // ── MindScore path ────────────────────────────────────────────────────────

    /// <summary>
    /// Persists responses and scores a MindScore cognitive assessment submission.
    /// </summary>
    /// <remarks>
    /// Requires the user to have a valid <see cref="User.AgeBandId"/> assigned
    /// (set during registration or DOB update).  The age band determines which
    /// questions are applicable and which norm references are used for
    /// percentile conversion.
    /// </remarks>
    private async Task<ResultDto> SubmitMindScoreAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questionMap = await BuildQuestionMapAsync(dto.TestId, ct);

        await PersistResponsesAsync(userId, dto.Answers, questionMap, ct);

        // Resolve the user's age band — required for norm-referenced scoring.
        var user = await _db.Users.FindAsync([userId], ct)
            ?? throw new KeyNotFoundException($"User {userId} not found.");

        var ageBandId = user.AgeBandId
            ?? throw new InvalidOperationException(
                "User has no age band assigned. "
                + "Please ensure date of birth was provided at registration.");

        var scoringInputs = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId) && int.TryParse(a.Value, out _))
            .Select(a => (a.QuestionId, int.Parse(a.Value)))
            .ToList();

        var mindResult = await _mindEngine.ScoreAsync(userId, ageBandId, scoringInputs, ct);

        var result = new Result
        {
            Id                  = Guid.NewGuid(),
            UserId              = userId,
            TestId              = dto.TestId,
            Score               = mindResult.OverallScore,
            PersonalityType     = "MIND_SCORE",
            PersonalityName     = mindResult.Tier,
            PersonalityEmoji    = TierEmoji(mindResult.Tier),
            PersonalityTagline  = TierTagline(mindResult.Tier),
            DimensionScoresJson = JsonSerializer.Serialize(mindResult.Modules, CamelCase),
            InsightsJson        = JsonSerializer.Serialize(
                new { ageBandName = mindResult.AgeBandName, tier = mindResult.Tier },
                CamelCase),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ToDto(result, testName);
    }

    // ── Shared helpers ────────────────────────────────────────────────────────

    /// <summary>
    /// Loads all questions for the given test and returns them keyed by their ID.
    /// </summary>
    private async Task<Dictionary<Guid, Question>> BuildQuestionMapAsync(
        Guid testId, CancellationToken ct)
    {
        var questions = await _questions.GetByTestIdAsync(testId, ct);
        return questions.ToDictionary(q => q.Id);
    }

    /// <summary>
    /// Deletes any existing responses for this user / question set and inserts
    /// the new ones.  This upsert pattern ensures retakes always replace
    /// previous attempts rather than accumulating duplicate rows.
    /// </summary>
    private async Task PersistResponsesAsync(
        Guid userId,
        IEnumerable<AnswerDto> answers,
        Dictionary<Guid, Question> questionMap,
        CancellationToken ct)
    {
        var responses = answers
            .Where(a => questionMap.ContainsKey(a.QuestionId))
            .Select(a => new Response
            {
                Id           = Guid.NewGuid(),
                UserId       = userId,
                QuestionId   = a.QuestionId,
                Value        = a.Value,
                CreatedAtUtc = DateTime.UtcNow,
            })
            .ToList();

        await _responses.DeleteByUserAndQuestionsAsync(userId, questionMap.Keys, ct);
        await _responses.AddRangeAsync(responses, ct);
    }

    // ── DTO mapping ───────────────────────────────────────────────────────────

    /// <summary>
    /// Maps a <see cref="Result"/> entity to a <see cref="ResultDto"/> for API
    /// serialisation.  Deserialises stored JSON blobs back to dynamic objects so
    /// the client receives structured data rather than escaped strings.
    /// </summary>
    internal static ResultDto ToDto(Result result, string testName)
    {
        static object? Deserialize(string? json) =>
            string.IsNullOrEmpty(json) ? null : JsonSerializer.Deserialize<object>(json);

        static IReadOnlyList<string>? DeserializeStringList(string? json) =>
            string.IsNullOrEmpty(json)
                ? null
                : JsonSerializer.Deserialize<List<string>>(json);

        return new ResultDto
        {
            Id                  = result.Id,
            UserId              = result.UserId,
            TestId              = result.TestId,
            TestName            = testName,
            Score               = result.Score,
            TypeCode            = result.PersonalityType,
            TypeName            = result.PersonalityName,
            Emoji               = result.PersonalityEmoji,
            Tagline             = result.PersonalityTagline,
            DimensionScores     = Deserialize(result.DimensionScoresJson),
            Insights            = Deserialize(result.InsightsJson),
            Context             = result.Context,
            ContextInsights     = Deserialize(result.ContextInsightsJson),
            AdaptivePath        = DeserializeStringList(result.AdaptivePathJson),
            AiFollowUp          = Deserialize(result.AiFollowUpJson),
            DimensionConfidence = Deserialize(result.DimensionConfidenceJson),
            CreatedAtUtc        = result.CreatedAtUtc,
        };
    }

    // ── MindScore tier helpers ────────────────────────────────────────────────

    /// <summary>
    /// Returns the emoji associated with a MindScore performance tier.
    /// </summary>
    private static string TierEmoji(string tier) => tier switch
    {
        "Elite"      => "🧠",
        "Advanced"   => "⚡",
        "Proficient" => "🌟",
        "Developing" => "🌱",
        _            => "🔍",
    };

    /// <summary>
    /// Returns the motivational tagline for a MindScore performance tier.
    /// </summary>
    private static string TierTagline(string tier) => tier switch
    {
        "Elite"      => "Exceptional cognitive and emotional mastery.",
        "Advanced"   => "Strong mental performance across key dimensions.",
        "Proficient" => "Solid foundations with clear areas to develop.",
        "Developing" => "Building mental fitness — growth in progress.",
        _            => "Early stage — every expert started here.",
    };
}
