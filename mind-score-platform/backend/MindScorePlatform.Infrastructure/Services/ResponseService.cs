using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class ResponseService : IResponseService
{
    private readonly IResponseRepository _responses;
    private readonly IResultRepository _results;
    private readonly ITestRepository _tests;
    private readonly IQuestionRepository _questions;
    private readonly IMpiScoringEngine _mpiEngine;
    private readonly IMindScoringEngine _mindEngine;
    private readonly AppDbContext _db;

    public ResponseService(
        IResponseRepository responses,
        IResultRepository results,
        ITestRepository tests,
        IQuestionRepository questions,
        IMpiScoringEngine mpiEngine,
        IMindScoringEngine mindEngine,
        AppDbContext db)
    {
        _responses = responses;
        _results = results;
        _tests = tests;
        _questions = questions;
        _mpiEngine = mpiEngine;
        _mindEngine = mindEngine;
        _db = db;
    }

    public async Task<ResultDto> SubmitAsync(Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        if (!dto.Answers.Any())
            throw new InvalidOperationException("No answers were submitted. Please complete the assessment before submitting.");

        // Route to MindScore engine when test is the MindScore assessment
        if (dto.TestId == MindScoreSeed.TestId)
            return await SubmitMindScoreAsync(userId, dto, test.Name, cancellationToken);

        return await SubmitMpiAsync(userId, dto, test.Name, cancellationToken);
    }

    // ── MPI path ──────────────────────────────────────────────────────────────

    private async Task<ResultDto> SubmitMpiAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questions = await _questions.GetByTestIdAsync(dto.TestId, ct);
        var questionMap = questions.ToDictionary(q => q.Id);

        var responses = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId))
            .Select(a => new Response
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                QuestionId = a.QuestionId,
                Value = a.Value,
                CreatedAtUtc = DateTime.UtcNow,
            })
            .ToList();

        await _responses.AddRangeAsync(responses, ct);

        var scoringInputs = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId) && int.TryParse(a.Value, out _))
            .Select(a => new MpiResponseInput
            {
                QuestionId = questionMap[a.QuestionId].Code,
                Value = int.Parse(a.Value),
            })
            .ToList();

        var mpiResult = _mpiEngine.Score(scoringInputs);

        var insightsPayload = new
        {
            strengths = mpiResult.Strengths,
            growthAreas = mpiResult.GrowthAreas,
            careerPaths = mpiResult.CareerPaths,
            communicationStyle = mpiResult.CommunicationStyle,
            workStyle = mpiResult.WorkStyle,
        };

        var camelCase = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = dto.TestId,
            Score = mpiResult.OverallScore,
            PersonalityType = mpiResult.TypeCode,
            PersonalityName = mpiResult.TypeName,
            PersonalityEmoji = mpiResult.Emoji,
            PersonalityTagline = mpiResult.Tagline,
            DimensionScoresJson = JsonSerializer.Serialize(mpiResult.Dimensions, camelCase),
            InsightsJson = JsonSerializer.Serialize(insightsPayload, camelCase),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ToDto(result, testName);
    }

    // ── MindScore path ────────────────────────────────────────────────────────

    private async Task<ResultDto> SubmitMindScoreAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questions = await _questions.GetByTestIdAsync(dto.TestId, ct);
        var questionMap = questions.ToDictionary(q => q.Id);

        // Persist raw responses
        var responses = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId))
            .Select(a => new Response
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                QuestionId = a.QuestionId,
                Value = a.Value,
                CreatedAtUtc = DateTime.UtcNow,
            })
            .ToList();

        await _responses.AddRangeAsync(responses, ct);

        // Resolve user's age band
        var user = await _db.Users.FindAsync([userId], ct)
            ?? throw new KeyNotFoundException($"User {userId} not found.");

        var ageBandId = user.AgeBandId
            ?? throw new InvalidOperationException("User has no age band assigned. Please ensure date of birth was provided at registration.");

        // Parse numeric answers
        var scoringInputs = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId) && int.TryParse(a.Value, out _))
            .Select(a => (a.QuestionId, int.Parse(a.Value)))
            .ToList();

        var mindResult = await _mindEngine.ScoreAsync(userId, ageBandId, scoringInputs, ct);

        var camelCase = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = dto.TestId,
            Score = mindResult.OverallScore,
            PersonalityType = "MIND_SCORE",
            PersonalityName = mindResult.Tier,
            PersonalityEmoji = TierEmoji(mindResult.Tier),
            PersonalityTagline = TierTagline(mindResult.Tier),
            DimensionScoresJson = JsonSerializer.Serialize(mindResult.Modules, camelCase),
            InsightsJson = JsonSerializer.Serialize(new { ageBandName = mindResult.AgeBandName, tier = mindResult.Tier }, camelCase),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ToDto(result, testName);
    }

    internal static ResultDto ToDto(Result result, string testName)
    {
        object? dimensions = null;
        object? insights = null;

        if (!string.IsNullOrEmpty(result.DimensionScoresJson))
            dimensions = JsonSerializer.Deserialize<object>(result.DimensionScoresJson);

        if (!string.IsNullOrEmpty(result.InsightsJson))
            insights = JsonSerializer.Deserialize<object>(result.InsightsJson);

        return new ResultDto
        {
            Id = result.Id,
            UserId = result.UserId,
            TestId = result.TestId,
            TestName = testName,
            Score = result.Score,
            TypeCode = result.PersonalityType,
            TypeName = result.PersonalityName,
            Emoji = result.PersonalityEmoji,
            Tagline = result.PersonalityTagline,
            DimensionScores = dimensions,
            Insights = insights,
            CreatedAtUtc = result.CreatedAtUtc,
        };
    }

    private static string TierEmoji(string tier) => tier switch
    {
        "Elite"       => "🧠",
        "Advanced"    => "⚡",
        "Proficient"  => "🌟",
        "Developing"  => "🌱",
        _             => "🔍",
    };

    private static string TierTagline(string tier) => tier switch
    {
        "Elite"       => "Exceptional cognitive and emotional mastery.",
        "Advanced"    => "Strong mental performance across key dimensions.",
        "Proficient"  => "Solid foundations with clear areas to develop.",
        "Developing"  => "Building mental fitness — growth in progress.",
        _             => "Early stage — every expert started here.",
    };
}
