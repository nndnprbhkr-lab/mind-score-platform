using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Provides read access to scored assessment results.
/// </summary>
public interface IResultService
{
    /// <summary>
    /// Returns all scored results for the specified user, most recent first.
    /// </summary>
    /// <param name="userId">The authenticated user's ID.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>
    /// A read-only list of <see cref="ResultDto"/> objects, each enriched with
    /// the parent test name.  Returns an empty list when the user has no results.
    /// </returns>
    Task<IReadOnlyList<ResultDto>> GetByUserIdAsync(
        Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// Returns a single result by its ID, scoped to the requesting user.
    /// </summary>
    /// <param name="id">The result ID.</param>
    /// <param name="userId">
    /// The authenticated user's ID.  Used to ensure users can only access
    /// their own results (ownership check).
    /// </param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>The matching <see cref="ResultDto"/>.</returns>
    /// <exception cref="KeyNotFoundException">Thrown when no result matches the ID and userId combination.</exception>
    Task<ResultDto> GetByIdAsync(
        Guid id, Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// Stores the user's answers to AI-generated follow-up questions against the given result.
    /// </summary>
    /// <exception cref="KeyNotFoundException">Result not found.</exception>
    /// <exception cref="UnauthorizedAccessException">Result belongs to a different user.</exception>
    /// <exception cref="InvalidOperationException">No follow-up questions exist on this result.</exception>
    Task<ResultDto> SubmitFollowUpAsync(
        Guid resultId, Guid userId, SubmitFollowUpDto dto, CancellationToken cancellationToken);
}
