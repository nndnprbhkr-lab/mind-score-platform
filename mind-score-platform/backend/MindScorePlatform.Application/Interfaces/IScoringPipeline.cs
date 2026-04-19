using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Handles the full scoring pipeline for one assessment type —
/// persisting responses, running the engine, enriching the result, and
/// returning the serialised DTO.
/// </summary>
public interface IScoringPipeline
{
    /// <summary>
    /// Returns <c>true</c> when this pipeline can handle the given test name.
    /// Pipelines are evaluated in registration order; the first match wins.
    /// </summary>
    bool CanHandle(string testName);

    /// <summary>Executes the full pipeline and returns the scored result.</summary>
    Task<ResultDto> ExecuteAsync(
        Guid userId,
        SubmitResponsesDto dto,
        string testName,
        CancellationToken ct);
}

/// <summary>
/// Resolves the correct <see cref="IScoringPipeline"/> for a given test and
/// delegates execution to it.
/// </summary>
public interface IScoringPipelineFactory
{
    Task<ResultDto> ExecuteAsync(
        Guid userId,
        SubmitResponsesDto dto,
        string testName,
        CancellationToken ct);
}
