using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class ResultService : IResultService
{
    private readonly IResultRepository _results;
    private readonly ITestRepository _tests;

    public ResultService(IResultRepository results, ITestRepository tests)
    {
        _results = results;
        _tests = tests;
    }

    public async Task<IReadOnlyList<ResultDto>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
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

    public async Task<ResultDto> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken)
    {
        var result = await _results.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Result {id} not found.");

        if (result.UserId != userId)
            throw new UnauthorizedAccessException("Access denied.");

        var test = await _tests.GetByIdAsync(result.TestId, cancellationToken);
        return ResponseService.ToDto(result, test?.Name ?? string.Empty);
    }
}
