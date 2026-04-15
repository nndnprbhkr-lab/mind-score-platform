namespace MindScorePlatform.Domain.Models;

/// <summary>
/// Deserialized form of a question's BranchingRulesJson.
/// Evaluated after the user answers a question to determine the next question.
/// </summary>
public sealed class BranchingRules
{
    /// <summary>Ordered list of conditions evaluated against the user's answer.</summary>
    public List<BranchCondition> Conditions { get; set; } = [];
}

/// <summary>
/// A single branching condition.
/// If the user's answer falls within [AnswerRange[0], AnswerRange[1]] (inclusive),
/// the question with code <see cref="NextQuestionCode"/> is served next.
/// </summary>
public sealed class BranchCondition
{
    /// <summary>
    /// Two-element array [min, max] (inclusive).
    /// For Likert: values 1–5. For Scenario: 0-based option index.
    /// </summary>
    public int[] AnswerRange { get; set; } = [];

    /// <summary>
    /// The Code of the next question to serve when this condition matches.
    /// Resolved via IQuestionRepository.GetByCodeAsync.
    /// </summary>
    public string NextQuestionCode { get; set; } = string.Empty;
}
