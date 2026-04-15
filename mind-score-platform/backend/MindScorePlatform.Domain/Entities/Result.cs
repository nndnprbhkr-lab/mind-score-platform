using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Domain.Entities;

public sealed class Result
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid TestId { get; set; }

    public decimal Score { get; set; }

    public string PersonalityType { get; set; } = string.Empty;

    public string PersonalityName { get; set; } = string.Empty;

    public string PersonalityEmoji { get; set; } = string.Empty;

    public string PersonalityTagline { get; set; } = string.Empty;

    public string DimensionScoresJson { get; set; } = string.Empty;

    public string InsightsJson { get; set; } = string.Empty;

    public DateTime CreatedAtUtc { get; set; }

    // ── Context-Aware / Adaptive fields ──────────────────────────────────────

    /// <summary>
    /// The context the user selected at the start of this assessment.
    /// Defaults to General — fully backward compatible with existing results.
    /// </summary>
    public AssessmentContext Context { get; set; } = AssessmentContext.General;

    /// <summary>
    /// Context-specific insight payload. Shape varies by context:
    /// - Career: CareerInsightsDto schema
    /// - Relationships: RelationshipInsightsDto schema
    /// - Leadership: LeadershipInsightsDto schema
    /// - PersonalDevelopment: PersonalDevelopmentInsightsDto schema
    /// - General: null (uses InsightsJson instead)
    /// </summary>
    public string? ContextInsightsJson { get; set; }

    /// <summary>
    /// Ordered list of question IDs actually served during the adaptive session.
    /// Used for result auditing and consistent retesting.
    /// Shape: ["uuid1", "uuid2", ...]
    /// </summary>
    public string? AdaptivePathJson { get; set; }

    /// <summary>
    /// AI-generated follow-up questions, the user's answers, and the tensions they resolved.
    /// Shape:
    /// {
    ///   "tensions": ["High Agreeableness vs High Assertiveness"],
    ///   "questions": [
    ///     {
    ///       "text": "When someone disagrees with your idea in a meeting...",
    ///       "options": ["I adjust my view...", "I hold my ground..."],
    ///       "answer": "I hold my ground but stay warm",
    ///       "dimensionImpact": { "DecisionStyle": 3 }
    ///     }
    ///   ]
    /// }
    /// </summary>
    public string? AiFollowUpJson { get; set; }

    /// <summary>
    /// Algorithm confidence per dimension (0–100).
    /// Low confidence dimensions were targeted by AI follow-up questions.
    /// Shape: { "EnergySource": 87, "PerceptionMode": 43, "DecisionStyle": 91, "LifeApproach": 55 }
    /// </summary>
    public string? DimensionConfidenceJson { get; set; }
}
