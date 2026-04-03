using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class TestService : ITestService
{
    private readonly ITestRepository _tests;
    private readonly IQuestionRepository _questions;

    public TestService(ITestRepository tests, IQuestionRepository questions)
    {
        _tests = tests;
        _questions = questions;
    }

    public async Task<IReadOnlyList<TestDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var tests = await _tests.GetAllAsync(cancellationToken);
        var result = new List<TestDto>(tests.Count);
        foreach (var t in tests)
        {
            var questions = await _questions.GetByTestIdAsync(t.Id, cancellationToken);
            result.Add(new TestDto(t.Id, t.Name, t.CreatedAtUtc, questions.Count));
        }
        return result;
    }

    public async Task<TestDto> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {id} not found.");
        var questions = await _questions.GetByTestIdAsync(id, cancellationToken);
        return new TestDto(test.Id, test.Name, test.CreatedAtUtc, questions.Count);
    }

    public async Task<TestDto> CreateAsync(CreateTestDto dto, CancellationToken cancellationToken)
    {
        var test = new Test
        {
            Id = Guid.NewGuid(),
            Name = dto.Name,
            CreatedAtUtc = DateTime.UtcNow,
        };
        await _tests.AddAsync(test, cancellationToken);
        return new TestDto(test.Id, test.Name, test.CreatedAtUtc, 0);
    }
}
