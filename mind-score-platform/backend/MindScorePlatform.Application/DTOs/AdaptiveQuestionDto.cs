using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Application.DTOs;

// ── Request ───────────────────────────────────────────────────────────────────

/// <summary>
/// Sent by the client to request the next adaptive question.
/// The full answered-so-far list is included so the engine is stateless
/// — no server-side session required.
/// </summary>
public sealed class AdaptiveNextQuestionRequestDto
{
    public Guid TestId { get; init; }

    /// <summary>Context the user selected at test start.</summary>
    public AssessmentContext Context { get; init; } = AssessmentContext.General;

    /// <summary>
    /// Every question the user has answered so far, in order.
    /// Empty list = "give me the first question".
    /// </summary>
    public IReadOnlyList<AdaptiveAnsweredDto> AnsweredSoFar { get; init; } = [];
}

/// <summary>A single answered question in the adaptive session history.</summary>
public sealed class AdaptiveAnsweredDto
{
    public Guid QuestionId { get; init; }

    /// <summary>
    /// The answer value.
    /// Likert: 1–5. Scenario: 0-based option index.
    /// </summary>
    public int Value { get; init; }
}

// ── Response ──────────────────────────────────────────────────────────────────

/// <summary>
/// The next question to show, plus session progress metadata.
/// When <see cref="IsComplete"/> is true, <see cref="Question"/> is null
/// and the client should proceed to submission.
/// </summary>
public sealed class AdaptiveNextQuestionResponseDto
{
    /// <summary>The next question to render. Null when the assessment is complete.</summary>
    public QuestionDto? Question { get; init; }

    /// <summary>True when there are no more questions — the client should submit.</summary>
    public bool IsComplete { get; init; }

    /// <summary>Estimated number of questions remaining (including this one).</summary>
    public int EstimatedRemaining { get; init; }

    /// <summary>Session progress fraction 0.0–1.0 for the progress bar.</summary>
    public double Progress { get; init; }

    /// <summary>Number of questions answered so far.</summary>
    public int AnsweredCount { get; init; }
}
