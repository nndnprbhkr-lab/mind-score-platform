using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Generates AI-powered follow-up questions for ambiguous MPI dimension scores.
/// </summary>
public interface IAiFollowUpService
{
    /// <summary>
    /// Analyses the given dimension scores for tensions and, if any are found,
    /// calls the Claude API to generate targeted follow-up questions.
    /// </summary>
    /// <returns>
    /// A populated <see cref="AiFollowUpPayload"/> when tensions are detected and
    /// Claude responds successfully; <c>null</c> when all dimensions are clear or
    /// the API call fails (failure is silently absorbed — never throws).
    /// </returns>
    Task<AiFollowUpPayload?> GenerateAsync(
        Dictionary<string, MpiDimensionScore> dimensions,
        CancellationToken ct);
}
