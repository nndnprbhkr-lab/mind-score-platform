using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Scoring pipeline for MindScore cognitive assessments.
/// Requires the user to have a valid age band (set from date of birth).
/// </summary>
public sealed class MindScoreScoringPipeline : ScoringPipelineBase
{
    private const string TestName = "MindScore Assessment";

    private readonly IMindScoringEngine _mindEngine;
    private readonly AppDbContext       _db;

    public MindScoreScoringPipeline(
        IResponseRepository  responses,
        IResultRepository    results,
        IQuestionRepository  questions,
        IMindScoringEngine   mindEngine,
        AppDbContext         db)
        : base(responses, results, questions)
    {
        _mindEngine = mindEngine;
        _db         = db;
    }

    public override bool CanHandle(string testName) =>
        string.Equals(testName, TestName, StringComparison.OrdinalIgnoreCase);

    public override async Task<ResultDto> ExecuteAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questionMap = await BuildQuestionMapAsync(dto.TestId, ct);

        await PersistResponsesAsync(userId, dto.Answers, questionMap, ct);

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
            DimensionScoresJson = JsonSerializer.Serialize(mindResult.Modules, ResultDtoMapper.CamelCase),
            InsightsJson        = JsonSerializer.Serialize(
                new { ageBandName = mindResult.AgeBandName, tier = mindResult.Tier },
                ResultDtoMapper.CamelCase),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ResultDtoMapper.ToDto(result, testName);
    }

    private static string TierEmoji(string tier) => tier switch
    {
        "Elite"      => "🧠",
        "Advanced"   => "⚡",
        "Proficient" => "🌟",
        "Developing" => "🌱",
        _            => "🔍",
    };

    private static string TierTagline(string tier) => tier switch
    {
        "Elite"      => "Exceptional cognitive and emotional mastery.",
        "Advanced"   => "Strong mental performance across key dimensions.",
        "Proficient" => "Solid foundations with clear areas to develop.",
        "Developing" => "Building mental fitness — growth in progress.",
        _            => "Early stage — every expert started here.",
    };
}
