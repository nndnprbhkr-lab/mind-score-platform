using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Resolves the correct <see cref="IScoringPipeline"/> for a given test name
/// and delegates execution to it.
/// </summary>
/// <remarks>
/// Pipelines are evaluated in DI registration order — the first whose
/// <see cref="IScoringPipeline.CanHandle"/> returns <c>true</c> is used.
/// Register specific pipelines before catch-all ones.
/// </remarks>
public sealed class ScoringPipelineFactory : IScoringPipelineFactory
{
    private readonly IEnumerable<IScoringPipeline> _pipelines;

    public ScoringPipelineFactory(IEnumerable<IScoringPipeline> pipelines)
        => _pipelines = pipelines;

    public Task<ResultDto> ExecuteAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var pipeline = _pipelines.FirstOrDefault(p => p.CanHandle(testName))
            ?? throw new InvalidOperationException(
                $"No scoring pipeline is registered for test '{testName}'.");

        return pipeline.ExecuteAsync(userId, dto, testName, ct);
    }
}
