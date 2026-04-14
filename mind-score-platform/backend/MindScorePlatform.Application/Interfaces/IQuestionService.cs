using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Provides access to assessment questions and question creation.
/// </summary>
public interface IQuestionService
{
    /// <summary>
    /// Returns the ordered list of questions for a given test.
    /// </summary>
    /// <remarks>
    /// For MindScore assessments, questions are filtered by the user's age band
    /// so that only age-appropriate norm-referenced questions are returned.
    /// MPI questions are not age-filtered.
    /// </remarks>
    /// <param name="testId">The assessment whose questions should be returned.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <param name="userId">
    /// Optional user ID.  When provided, the age band is resolved from the
    /// user's profile for age-filtered questions.
    /// </param>
    /// <returns>An ordered, read-only list of <see cref="QuestionDto"/> objects.</returns>
    Task<IReadOnlyList<QuestionDto>> GetByTestIdAsync(
        Guid testId,
        CancellationToken cancellationToken,
        Guid? userId = null);

    /// <summary>
    /// Creates a new question and associates it with the specified test.
    /// Restricted to admin users.
    /// </summary>
    /// <param name="dto">Question text, order, and optional scoring metadata.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>The created <see cref="QuestionDto"/> with the server-assigned ID.</returns>
    Task<QuestionDto> CreateAsync(
        CreateQuestionDto dto, CancellationToken cancellationToken);
}
