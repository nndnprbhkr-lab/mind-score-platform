using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Provides read access and follow-up submission for scored assessment results.
/// </summary>
public sealed class ResultService : IResultService
{
    private readonly IResultRepository _results;
    private readonly ITestRepository   _tests;

    private static readonly JsonSerializerOptions CamelCase =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

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
            dtos.Add(ResponseService.ToDto(r, test?.Name ?? string.Empty));
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
        return ResponseService.ToDto(result, test?.Name ?? string.Empty);
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

        var payload = JsonSerializer.Deserialize<AiFollowUpPayload>(result.AiFollowUpJson, CamelCase)
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

        var updatedJson = JsonSerializer.Serialize(payload, CamelCase);
        await _results.UpdateFollowUpAsync(resultId, updatedJson, cancellationToken);

        // Reflect the update in the returned DTO without a second DB round-trip.
        result.AiFollowUpJson = updatedJson;
        var test = await _tests.GetByIdAsync(result.TestId, cancellationToken);
        return ResponseService.ToDto(result, test?.Name ?? string.Empty);
    }
}
