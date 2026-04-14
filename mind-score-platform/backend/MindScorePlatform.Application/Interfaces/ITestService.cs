using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Manages the catalogue of assessments available on the platform.
/// </summary>
public interface ITestService
{
    /// <summary>
    /// Returns all active assessments ordered for display on the dashboard.
    /// </summary>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>A read-only list of <see cref="TestDto"/> objects.</returns>
    Task<IReadOnlyList<TestDto>> GetAllAsync(CancellationToken cancellationToken);

    /// <summary>
    /// Returns a single assessment by its unique identifier.
    /// </summary>
    /// <param name="id">The assessment ID.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>The matching <see cref="TestDto"/>.</returns>
    /// <exception cref="KeyNotFoundException">Thrown when no test with the given ID exists.</exception>
    Task<TestDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    /// <summary>
    /// Creates a new assessment.  Restricted to admin users.
    /// </summary>
    /// <param name="dto">Name and optional metadata for the new assessment.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>The created <see cref="TestDto"/> with the server-assigned ID.</returns>
    Task<TestDto> CreateAsync(CreateTestDto dto, CancellationToken cancellationToken);
}
