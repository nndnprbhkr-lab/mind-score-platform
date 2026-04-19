using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class QuestionService : IQuestionService
{
    private readonly IQuestionRepository _questions;
    private readonly ITestRepository _tests;
    private readonly IUserRepository _users;

    public QuestionService(IQuestionRepository questions, ITestRepository tests, IUserRepository users)
    {
        _questions = questions;
        _tests = tests;
        _users = users;
    }

    public async Task<IReadOnlyList<QuestionDto>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken, Guid? userId = null)
    {
        _ = await _tests.GetByIdAsync(testId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {testId} not found.");

        Guid? ageBandId = null;
        if (userId.HasValue)
        {
            var user = await _users.GetByIdAsync(userId.Value, cancellationToken);
            ageBandId = user?.AgeBandId;
        }

        var questions = await _questions.GetByTestIdAsync(testId, cancellationToken, ageBandId);
        return questions.Select(ToDto).ToList();
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
        return ToDto(question);
    }

    private static QuestionDto ToDto(Question q) => new()
    {
        Id = q.Id,
        TestId = q.TestId,
        Text = q.Text,
        Order = q.Order,
        Code = q.Code,
        QuestionType = q.QuestionType,
        ScenarioOptions = q.ScenarioOptionsJson is not null
            ? JsonSerializer.Deserialize<JsonElement>(q.ScenarioOptionsJson)
            : null,
        ContextTags = q.ContextTagsJson is not null
            ? JsonSerializer.Deserialize<List<string>>(q.ContextTagsJson)
            : null,
    };
}
