namespace MindScorePlatform.Application.DTOs.ContextInsights;

/// <summary>
/// Context-specific insights for the Personal Development assessment context.
/// Domain basis: Jungian shadow work, Positive Psychology (Seligman PERMA),
/// Self-Determination Theory, ACT (Acceptance and Commitment Therapy) values work.
/// Person's question: "Who am I really, what patterns keep showing up, what would growth look like?"
/// </summary>
public sealed class PersonalDevelopmentInsightsDto
{
    /// <summary>What intrinsically drives and motivates this type.</summary>
    public IReadOnlyList<string> CoreMotivators { get; init; } = [];

    /// <summary>
    /// Jungian shadow — the traits this type denies in themselves and often projects onto others.
    /// e.g. A Dreamer who denies their need for external validation; projects perfectionism as criticism.
    /// </summary>
    public IReadOnlyList<string> ShadowPatterns { get; init; } = [];

    /// <summary>Specific activities and conditions that replenish this type's energy.</summary>
    public IReadOnlyList<string> EnergySources { get; init; } = [];

    /// <summary>Specific conditions and patterns that systematically deplete this type.</summary>
    public IReadOnlyList<string> EnergyDrains { get; init; } = [];

    /// <summary>
    /// How this type characteristically responds to stress.
    /// Expressed as their type's specific fight/flight/freeze/fawn pattern.
    /// </summary>
    public string StressResponse { get; init; } = string.Empty;

    /// <summary>How this type absorbs and processes new information most effectively.</summary>
    public string LearningStyle { get; init; } = string.Empty;

    /// <summary>Recurring self-defeating patterns specific to this type.</summary>
    public IReadOnlyList<string> SelfSabotagePatterns { get; init; } = [];

    /// <summary>
    /// Whether the type's current life tends to reflect their stated values.
    /// Describes the common misalignment pattern for this type.
    /// </summary>
    public string ValuesAlignment { get; init; } = string.Empty;

    /// <summary>The conditions under which this type thrives — ideal life design principles.</summary>
    public IReadOnlyList<string> IdealLifeDesign { get; init; } = [];

    /// <summary>
    /// The central growth paradox for this type — the defining tension they must navigate.
    /// e.g. "Needs safety to be creative, but only grows when they risk being seen before they're ready."
    /// </summary>
    public string GrowthParadox { get; init; } = string.Empty;
}
