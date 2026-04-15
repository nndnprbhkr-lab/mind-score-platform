using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Domain.Entities;

public sealed class Question
{
    public Guid Id { get; set; }

    public Guid TestId { get; set; }

    /// <summary>MPI question code, e.g. "EI_01_R". Used by the scoring engine for dimension grouping and reversal detection.</summary>
    public string Code { get; set; } = string.Empty;

    public string Text { get; set; } = string.Empty;

    public int Order { get; set; }

    public DateTime CreatedAtUtc { get; set; }

    public Guid? ModuleId { get; set; }
    public Guid? AgeBandId { get; set; }
    public string? Difficulty { get; set; }
    public decimal? Weight { get; set; }
    public bool? IsReverseScored { get; set; }
    public int? Version { get; set; }

    // ── Adaptive / Context-Aware fields ──────────────────────────────────────

    /// <summary>
    /// Presentation format for this question.
    /// Defaults to Likert (0) for all existing questions — fully backward compatible.
    /// </summary>
    public QuestionType QuestionType { get; set; } = QuestionType.Likert;

    /// <summary>
    /// JSON branching rules evaluated after the user answers this question.
    /// Determines which question to serve next in adaptive mode.
    /// Null = no branching; next question is determined by Order.
    ///
    /// Shape:
    /// {
    ///   "conditions": [
    ///     { "answerRange": [1, 2], "nextQuestionCode": "EI_02_R_INTRO" },
    ///     { "answerRange": [4, 5], "nextQuestionCode": "EI_02_EXTRA" },
    ///     { "answerRange": [3, 3], "nextQuestionCode": "EI_03_NEUTRAL" }
    ///   ]
    /// }
    /// </summary>
    public string? BranchingRulesJson { get; set; }

    /// <summary>
    /// JSON array of assessment context tags that this question is relevant for.
    /// Null = shown in all contexts (General).
    /// e.g. ["Career", "Leadership"] — only served for Career or Leadership contexts.
    ///
    /// Shape: ["Career", "Leadership"]
    /// </summary>
    public string? ContextTagsJson { get; set; }

    /// <summary>
    /// JSON array of scenario options for QuestionType.Scenario questions.
    /// Null for Likert and FollowUp questions.
    ///
    /// Shape:
    /// [
    ///   {
    ///     "text": "Send a detailed agenda tonight so everyone is prepared",
    ///     "traitMappings": { "LifeApproach": 5, "DecisionStyle": 4 }
    ///   },
    ///   {
    ///     "text": "Arrive early and meet people individually before it starts",
    ///     "traitMappings": { "EnergySource": 5, "DecisionStyle": 2 }
    ///   }
    /// ]
    /// </summary>
    public string? ScenarioOptionsJson { get; set; }

    // ── Navigation properties ─────────────────────────────────────────────────
    public Module? Module { get; set; }
    public AgeBand? AgeBand { get; set; }
}
