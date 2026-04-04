using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class ResponseService : IResponseService
{
    private readonly IResponseRepository _responses;
    private readonly IResultRepository _results;
    private readonly ITestRepository _tests;
    private readonly IQuestionRepository _questions;
    private readonly IMpiScoringEngine _mpiEngine;

    public ResponseService(
        IResponseRepository responses,
        IResultRepository results,
        ITestRepository tests,
        IQuestionRepository questions,
        IMpiScoringEngine mpiEngine)
    {
        _responses = responses;
        _results = results;
        _tests = tests;
        _questions = questions;
        _mpiEngine = mpiEngine;
    }

    public async Task<ResultDto> SubmitAsync(Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        var alreadySubmitted = await _responses.HasUserSubmittedAsync(userId, dto.TestId, cancellationToken);
        if (alreadySubmitted)
            throw new InvalidOperationException("You have already submitted this test.");

        var questions = await _questions.GetByTestIdAsync(dto.TestId, cancellationToken);
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

        await _responses.AddRangeAsync(responses, cancellationToken);

        // Build scoring engine inputs using question Code for dimension/reversal detection
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
        };

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
            DimensionScoresJson = JsonSerializer.Serialize(mpiResult.Dimensions),
            InsightsJson = JsonSerializer.Serialize(insightsPayload),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _results.AddAsync(result, cancellationToken);

        return ToDto(result, test.Name);
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
}
