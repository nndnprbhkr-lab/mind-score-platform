using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Domain.Models;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Stateless adaptive question engine.
///
/// Algorithm:
///   1. Load all eligible questions for the test + context + age band.
///   2. Build a set of already-answered question IDs.
///   3. Build answered-values map for branching evaluation.
///   4. Hard stop: if answered count ≥ per-context target → mark complete.
///   5. If no answers yet → return the first anchor question (lowest Order).
///   6. Try branching from the last answered question:
///   7. If the last answered question has branching rules:
///      a. Evaluate each condition against the answer value.
///      b. If a condition matches → fetch the branch target by Code.
///      c. If the branch target is already answered → fall through to linear.
///   8. Linear fallback → return the next unanswered question by Order.
///   9. If no more unanswered questions → mark IsComplete = true.
///
/// Completion threshold: answered count reaches the per-context target (step 4),
/// OR the question pool is fully exhausted (step 9).
/// </summary>
public sealed class AdaptiveQuestionService : IAdaptiveQuestionService
{
    // Estimated total questions per context (used for progress + remaining calculation)
    private static readonly Dictionary<AssessmentContext, int> _targetCounts = new()
    {
        [AssessmentContext.General]           = 20,
        [AssessmentContext.Career]            = 22,
        [AssessmentContext.Relationships]     = 22,
        [AssessmentContext.Leadership]        = 22,
        [AssessmentContext.PersonalDevelopment] = 20,
    };

    private readonly IQuestionRepository _questions;
    private readonly IUserRepository _users;

    public AdaptiveQuestionService(IQuestionRepository questions, IUserRepository users)
    {
        _questions = questions;
        _users = users;
    }

    public async Task<AdaptiveNextQuestionResponseDto> GetNextAsync(
        AdaptiveNextQuestionRequestDto request,
        Guid? userId,
        CancellationToken cancellationToken)
    {
        // ── 1. Resolve age band ───────────────────────────────────────────────
        Guid? ageBandId = null;
        if (userId.HasValue)
        {
            var user = await _users.GetByIdAsync(userId.Value, cancellationToken);
            ageBandId = user?.AgeBandId;
        }

        // ── 2. Load all eligible questions for this test + context ────────────
        var allQuestions = await _questions.GetByTestIdAsync(
            request.TestId,
            cancellationToken,
            ageBandId,
            request.Context);

        if (allQuestions.Count == 0)
            return Complete(request.AnsweredSoFar.Count, request.Context);

        // ── 3. Build answered set ─────────────────────────────────────────────
        var answeredIds = request.AnsweredSoFar
            .Select(a => a.QuestionId)
            .ToHashSet();

        var answeredValues = request.AnsweredSoFar
            .ToDictionary(a => a.QuestionId, a => a.Value);

        // ── 4. Hard stop at per-context target ────────────────────────────────
        // Prevents the engine from over-serving when the pool is larger than the
        // target (e.g. 26 questions in pool, target = 20 for General).
        var target = _targetCounts.GetValueOrDefault(request.Context, 20);
        if (answeredIds.Count >= target)
            return Complete(answeredIds.Count, request.Context);

        // ── 6. First question ─────────────────────────────────────────────────
        if (answeredIds.Count == 0)
        {
            var first = allQuestions.MinBy(q => q.Order)!;
            return BuildResponse(first, answeredIds.Count, request.Context, allQuestions.Count);
        }

        // ── 7. Try branching from the last answered question ──────────────────
        var lastAnsweredId = request.AnsweredSoFar.Last().QuestionId;
        var lastQuestion = allQuestions.FirstOrDefault(q => q.Id == lastAnsweredId);

        if (lastQuestion?.BranchingRulesJson is not null)
        {
            var branchTarget = await TryResolveBranchAsync(
                lastQuestion,
                answeredValues[lastAnsweredId],
                request.TestId,
                answeredIds,
                cancellationToken);

            if (branchTarget is not null)
                return BuildResponse(branchTarget, answeredIds.Count, request.Context, allQuestions.Count);
        }

        // ── 8. Linear fallback — next unanswered question by Order ───────────
        var next = allQuestions
            .Where(q => !answeredIds.Contains(q.Id))
            .OrderBy(q => q.Order)
            .FirstOrDefault();

        if (next is null)
            return Complete(answeredIds.Count, request.Context);

        return BuildResponse(next, answeredIds.Count, request.Context, allQuestions.Count);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<Question?> TryResolveBranchAsync(
        Question lastQuestion,
        int answerValue,
        Guid testId,
        HashSet<Guid> answeredIds,
        CancellationToken cancellationToken)
    {
        BranchingRules? rules;
        try
        {
            rules = JsonSerializer.Deserialize<BranchingRules>(
                lastQuestion.BranchingRulesJson!,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch
        {
            return null;
        }

        if (rules is null) return null;

        foreach (var condition in rules.Conditions)
        {
            if (condition.AnswerRange.Length < 2) continue;
            if (answerValue < condition.AnswerRange[0] || answerValue > condition.AnswerRange[1]) continue;

            // Condition matched — resolve the branch target question
            var branchQ = await _questions.GetByCodeAsync(testId, condition.NextQuestionCode, cancellationToken);

            // Only return the branch target if it hasn't been answered yet
            if (branchQ is not null && !answeredIds.Contains(branchQ.Id))
                return branchQ;

            break; // Condition matched but target already answered — fall through
        }

        return null;
    }

    private static AdaptiveNextQuestionResponseDto BuildResponse(
        Question question,
        int answeredCount,
        AssessmentContext context,
        int totalEligible)
    {
        var target = _targetCounts.GetValueOrDefault(context, 20);
        var clampedAnswered = Math.Min(answeredCount, target);
        var progress = target > 0 ? (double)clampedAnswered / target : 0;
        var remaining = Math.Max(1, target - clampedAnswered);

        return new AdaptiveNextQuestionResponseDto
        {
            Question = ToDto(question),
            IsComplete = false,
            AnsweredCount = answeredCount,
            EstimatedRemaining = remaining,
            Progress = Math.Round(progress, 2),
        };
    }

    private static AdaptiveNextQuestionResponseDto Complete(int answeredCount, AssessmentContext context)
    {
        var target = _targetCounts.GetValueOrDefault(context, 20);
        return new AdaptiveNextQuestionResponseDto
        {
            Question = null,
            IsComplete = true,
            AnsweredCount = answeredCount,
            EstimatedRemaining = 0,
            Progress = 1.0,
        };
    }

    private static QuestionDto ToDto(Question q) => new()
    {
        Id = q.Id,
        TestId = q.TestId,
        Text = q.Text,
        Order = q.Order,
        Code = q.Code,
        QuestionType = q.QuestionType,
        ScenarioOptions = q.ScenarioOptionsJson is not null
            ? JsonSerializer.Deserialize<object>(q.ScenarioOptionsJson)
            : null,
        ContextTags = q.ContextTagsJson is not null
            ? JsonSerializer.Deserialize<List<string>>(q.ContextTagsJson)
            : null,
    };
}
