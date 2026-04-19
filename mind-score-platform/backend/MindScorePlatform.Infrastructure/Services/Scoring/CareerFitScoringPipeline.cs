using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Scoring pipeline for the Career Fit Assessment.
/// Users select one of four scenario options per question; each option carries
/// <c>clusterImpact</c> weights across the 8 career archetypes.
///
/// Scoring algorithm:
///   1. For every answered question, look up the selected option's clusterImpact.
///   2. Accumulate raw totals per cluster.
///   3. Normalise each cluster to a percentage of the grand total (all cluster sums).
///   4. Sort descending — primary cluster is the winner.
///
/// Result storage:
///   PersonalityType     = primary cluster code (e.g. "ANALYST")
///   PersonalityName     = cluster display name  (e.g. "The Analyst")
///   DimensionScoresJson = all 8 clusters with percentage fit
///   InsightsJson        = top-3 fit clusters + primary cluster profile detail
/// </summary>
public sealed class CareerFitScoringPipeline : ScoringPipelineBase
{
    private const string TestName = "Career Fit Assessment";

    // Matches the ScenarioOptionsJson shape written by CareerFitSeed.
    private sealed record CareerFitOption(string Text, Dictionary<string, int> ClusterImpact);

    public CareerFitScoringPipeline(
        IResponseRepository responses,
        IResultRepository   results,
        IQuestionRepository questions)
        : base(responses, results, questions)
    {
    }

    public override bool CanHandle(string testName) =>
        string.Equals(testName, TestName, StringComparison.OrdinalIgnoreCase);

    public override async Task<ResultDto> ExecuteAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questionMap = await BuildQuestionMapAsync(dto.TestId, ct);
        await PersistResponsesAsync(userId, dto.Answers, questionMap, ct);

        // ── 1. Accumulate raw cluster totals ─────────────────────────────────
        var clusterTotals = new Dictionary<string, double>();

        foreach (var answer in dto.Answers)
        {
            if (!questionMap.TryGetValue(answer.QuestionId, out var q)) continue;
            if (q.ScenarioOptionsJson is null) continue;
            if (!int.TryParse(answer.Value, out var idx)) continue;

            var options = JsonSerializer.Deserialize<CareerFitOption[]>(
                q.ScenarioOptionsJson, ResultDtoMapper.CamelCase);

            if (options is null || idx < 0 || idx >= options.Length) continue;

            foreach (var (cluster, weight) in options[idx].ClusterImpact)
                clusterTotals[cluster] = clusterTotals.GetValueOrDefault(cluster) + weight;
        }

        // ── 2. Normalise to percentages ───────────────────────────────────────
        var grandTotal = clusterTotals.Values.DefaultIfEmpty(0).Sum();

        var ranked = CareerFitClusterLibrary.All.Keys
            .Select(code =>
            {
                var raw = clusterTotals.GetValueOrDefault(code);
                var pct = grandTotal > 0 ? Math.Round(raw / grandTotal * 100, 1) : 0.0;
                return (code, raw, pct);
            })
            .OrderByDescending(x => x.pct)
            .ThenBy(x => x.code)       // deterministic tiebreak
            .ToList();

        var primary = ranked[0];
        var profile = CareerFitClusterLibrary.GetProfile(primary.code);

        // ── 3. Build payload objects ──────────────────────────────────────────
        var top3 = ranked.Take(3).Select(c =>
        {
            var p = CareerFitClusterLibrary.GetProfile(c.code);
            return new { code = c.code, name = p.Name, emoji = p.Emoji, fitPercentage = c.pct };
        }).ToList();

        var dimensionScores = ranked.ToDictionary(
            c => c.code,
            c => new { percentage = c.pct });

        var insightsPayload = new
        {
            top3Clusters   = top3,
            primaryCluster = new
            {
                code        = primary.code,
                name        = profile.Name,
                emoji       = profile.Emoji,
                tagline     = profile.Tagline,
                strengths   = profile.Strengths,
                growthAreas = profile.GrowthAreas,
                idealRoles  = profile.IdealRoles,
            },
        };

        // ── 4. Persist result ─────────────────────────────────────────────────
        var result = new Result
        {
            Id                  = Guid.NewGuid(),
            UserId              = userId,
            TestId              = dto.TestId,
            Score               = (decimal)primary.pct,
            PersonalityType     = primary.code,
            PersonalityName     = profile.Name,
            PersonalityEmoji    = profile.Emoji,
            PersonalityTagline  = profile.Tagline,
            DimensionScoresJson = JsonSerializer.Serialize(dimensionScores, ResultDtoMapper.CamelCase),
            InsightsJson        = JsonSerializer.Serialize(insightsPayload, ResultDtoMapper.CamelCase),
            Context             = dto.Context,
            CreatedAtUtc        = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ResultDtoMapper.ToDto(result, testName);
    }
}
