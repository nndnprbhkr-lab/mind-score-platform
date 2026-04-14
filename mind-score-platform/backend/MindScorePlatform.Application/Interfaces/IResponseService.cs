using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Handles assessment answer submission and orchestrates the scoring pipeline.
/// </summary>
public interface IResponseService
{
    /// <summary>
    /// Persists the user's answers and returns the scored result.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Internally routes to the correct scoring engine based on the test name:
    /// the MindScore cognitive assessment uses age-band normalised percentile
    /// scoring; all other tests use the MPI personality scoring engine.
    /// </para>
    /// <para>
    /// Retaking a test replaces all previous responses and the previous result
    /// for that user / test combination.
    /// </para>
    /// </remarks>
    /// <param name="userId">The ID of the authenticated user submitting answers.</param>
    /// <param name="dto">The test ID and list of question–answer pairs.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>A fully scored <see cref="ResultDto"/> including type code, insights, and dimension scores.</returns>
    /// <exception cref="KeyNotFoundException">Thrown when the specified test does not exist.</exception>
    /// <exception cref="InvalidOperationException">Thrown when no answers were provided or the user has no age band.</exception>
    Task<ResultDto> SubmitAsync(
        Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken);
}
