using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Determines the next question to serve in an adaptive assessment session.
/// Stateless — all session state is passed in the request.
/// </summary>
public interface IAdaptiveQuestionService
{
    /// <summary>
    /// Given the test, context, and all questions answered so far,
    /// returns the next question to display (or marks the session complete).
    /// </summary>
    /// <param name="request">
    /// Session state: testId, context, and the full ordered list of answered questions.
    /// Pass an empty <see cref="AdaptiveNextQuestionRequestDto.AnsweredSoFar"/> list
    /// to get the first question.
    /// </param>
    /// <param name="userId">
    /// Used to resolve the user's age band for age-filtered question sets.
    /// </param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    Task<AdaptiveNextQuestionResponseDto> GetNextAsync(
        AdaptiveNextQuestionRequestDto request,
        Guid? userId,
        CancellationToken cancellationToken);
}
