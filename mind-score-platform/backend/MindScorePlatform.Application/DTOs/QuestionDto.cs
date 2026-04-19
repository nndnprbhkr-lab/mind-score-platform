using System.Text.Json;
using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Application.DTOs;

/// <summary>
/// A question as returned to the client. Includes all fields needed
/// for adaptive rendering — question type, scenario options, and branching rules.
/// </summary>
public sealed class QuestionDto
{
    public Guid Id { get; init; }
    public Guid TestId { get; init; }
    public string Text { get; init; } = string.Empty;
    public int Order { get; init; }
    public string Code { get; init; } = string.Empty;

    /// <summary>Presentation format: Likert (default), Scenario, or FollowUp.</summary>
    public QuestionType QuestionType { get; init; } = QuestionType.Likert;

    /// <summary>
    /// Populated only when QuestionType == Scenario.
    /// Deserialized client-side to render multiple-choice scenario options.
    /// Each option contains display text and hidden trait score mappings.
    /// </summary>
    public JsonElement? ScenarioOptions { get; init; }

    /// <summary>
    /// Context tags for this question. Null = relevant to all contexts.
    /// e.g. ["Career", "Leadership"]
    /// </summary>
    public IReadOnlyList<string>? ContextTags { get; init; }
}

public sealed record CreateQuestionDto(Guid TestId, string Text, int Order);
