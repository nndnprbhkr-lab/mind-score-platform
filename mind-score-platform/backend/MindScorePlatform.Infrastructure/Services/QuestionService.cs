using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class QuestionService : IQuestionService
{
    private readonly IQuestionRepository _questions;
    private readonly ITestRepository _tests;

    public QuestionService(IQuestionRepository questions, ITestRepository tests)
    {
        _questions = questions;
        _tests = tests;
    }

    public async Task<IReadOnlyList<QuestionDto>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken)
    {
        _ = await _tests.GetByIdAsync(testId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {testId} not found.");
        var questions = await _questions.GetByTestIdAsync(testId, cancellationToken);
        return questions.Select(q => new QuestionDto(q.Id, q.TestId, q.Text, q.Order)).ToList();
    }

    public async Task<QuestionDto> CreateAsync(CreateQuestionDto dto, CancellationToken cancellationToken)
    {
        _ = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        var question = new Question
        {
            Id = Guid.NewGuid(),
            TestId = dto.TestId,
            Text = dto.Text,
            Order = dto.Order,
            CreatedAtUtc = DateTime.UtcNow,
        };
        await _questions.AddAsync(question, cancellationToken);
        return new QuestionDto(question.Id, question.TestId, question.Text, question.Order);
    }
}
