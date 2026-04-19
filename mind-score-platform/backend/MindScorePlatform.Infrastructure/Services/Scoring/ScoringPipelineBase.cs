using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Shared infrastructure for all scoring pipelines.
/// Concrete pipelines inherit this and implement <see cref="CanHandle"/> and
/// <see cref="ExecuteAsync"/> with their assessment-specific logic.
/// </summary>
public abstract class ScoringPipelineBase : IScoringPipeline
{
    protected readonly IResponseRepository  _responses;
    protected readonly IResultRepository    _results;
    protected readonly IQuestionRepository  _questions;

    protected ScoringPipelineBase(
        IResponseRepository  responses,
        IResultRepository    results,
        IQuestionRepository  questions)
    {
        _responses = responses;
        _results   = results;
        _questions = questions;
    }

    /// <inheritdoc/>
    public abstract bool CanHandle(string testName);

    /// <inheritdoc/>
    public abstract Task<ResultDto> ExecuteAsync(
        Guid userId,
        SubmitResponsesDto dto,
        string testName,
        CancellationToken ct);

    // ── Shared helpers ────────────────────────────────────────────────────────

    /// <summary>
    /// Loads all questions for the given test and returns them keyed by ID.
    /// </summary>
    protected async Task<Dictionary<Guid, Question>> BuildQuestionMapAsync(
        Guid testId, CancellationToken ct)
    {
        var questions = await _questions.GetByTestIdAsync(testId, ct);
        return questions.ToDictionary(q => q.Id);
    }

    /// <summary>
    /// Deletes previous responses for this user / question set and inserts the
    /// new ones — ensuring retakes always replace prior attempts.
    /// </summary>
    protected async Task PersistResponsesAsync(
        Guid userId,
        IEnumerable<AnswerDto> answers,
        Dictionary<Guid, Question> questionMap,
        CancellationToken ct)
    {
        var responses = answers
            .Where(a => questionMap.ContainsKey(a.QuestionId))
            .Select(a => new Response
            {
                Id           = Guid.NewGuid(),
                UserId       = userId,
                QuestionId   = a.QuestionId,
                Value        = a.Value,
                CreatedAtUtc = DateTime.UtcNow,
            })
            .ToList();

        await _responses.DeleteByUserAndQuestionsAsync(userId, questionMap.Keys, ct);
        await _responses.AddRangeAsync(responses, ct);
    }
}
