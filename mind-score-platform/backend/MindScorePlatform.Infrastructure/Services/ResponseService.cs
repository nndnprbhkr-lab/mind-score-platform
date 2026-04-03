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

    public ResponseService(
        IResponseRepository responses,
        IResultRepository results,
        ITestRepository tests,
        IQuestionRepository questions)
    {
        _responses = responses;
        _results = results;
        _tests = tests;
        _questions = questions;
    }

    public async Task<ResultDto> SubmitAsync(Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        var alreadySubmitted = await _responses.HasUserSubmittedAsync(userId, dto.TestId, cancellationToken);
        if (alreadySubmitted)
            throw new InvalidOperationException("You have already submitted this test.");

        var questions = await _questions.GetByTestIdAsync(dto.TestId, cancellationToken);
        var questionIds = questions.Select(q => q.Id).ToHashSet();

        var responses = dto.Answers
            .Where(a => questionIds.Contains(a.QuestionId))
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

        var score = CalculateScore(responses);

        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = dto.TestId,
            Score = score,
            CreatedAtUtc = DateTime.UtcNow,
        };
        await _results.AddAsync(result, cancellationToken);

        return new ResultDto(result.Id, result.UserId, result.TestId, test.Name, result.Score, result.CreatedAtUtc);
    }

    private static decimal CalculateScore(IReadOnlyList<Response> responses)
    {
        if (responses.Count == 0) return 0;

        decimal total = 0;
        int parsed = 0;
        foreach (var r in responses)
        {
            if (decimal.TryParse(r.Value, out var val))
            {
                total += val;
                parsed++;
            }
        }

        return parsed == 0 ? 0 : Math.Round(total / parsed, 2);
    }
}
