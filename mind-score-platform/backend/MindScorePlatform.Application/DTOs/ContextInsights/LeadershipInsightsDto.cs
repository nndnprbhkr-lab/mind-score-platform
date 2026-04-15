namespace MindScorePlatform.Application.DTOs.ContextInsights;

/// <summary>
/// Context-specific insights for the Leadership assessment context.
/// Domain basis: Bass and Avolio Transformational Leadership, Situational Leadership (Hersey),
/// Korn Ferry leadership derailers research, Belbin team roles.
/// Person's question: "How do I naturally lead, where do I create problems, what's my next growth edge?"
/// </summary>
public sealed class LeadershipInsightsDto
{
    /// <summary>
    /// Primary leadership archetype.
    /// Values: Transformational | Transactional | Servant | Democratic | Autocratic | Coaching
    /// </summary>
    public string LeadershipStyle { get; init; } = string.Empty;

    /// <summary>
    /// Natural team role in Belbin terms.
    /// e.g. "Plant + Resource Investigator — generates ideas, connects external resources; weak Completer-Finisher"
    /// </summary>
    public string TeamRoleNatural { get; init; } = string.Empty;

    /// <summary>How this type naturally persuades and mobilises others.</summary>
    public IReadOnlyList<string> InfluenceTactics { get; init; } = [];

    /// <summary>What this type's leadership consistently fails to see or account for.</summary>
    public IReadOnlyList<string> LeadershipBlindSpots { get; init; } = [];

    /// <summary>
    /// How this type's strengths become weaponised under stress.
    /// e.g. Enthusiasm → chaos, Confidence → dismissiveness of concerns.
    /// </summary>
    public IReadOnlyList<string> ShadowTendencies { get; init; } = [];

    /// <summary>Type codes of team members that offset this leader's weaknesses.</summary>
    public IReadOnlyList<string> TeamComplementNeeds { get; init; } = [];

    /// <summary>How this type hands off work — what they delegate well vs hold onto.</summary>
    public string DelegationStyle { get; init; } = string.Empty;

    /// <summary>Patterns that could derail this type's leadership trajectory.</summary>
    public IReadOnlyList<string> Derailers { get; init; } = [];

    /// <summary>How this type develops and coaches others.</summary>
    public string CoachingStyle { get; init; } = string.Empty;

    /// <summary>
    /// The next leadership maturity stage for this type.
    /// e.g. "From inspiring individuals → creating systems that outlast their presence"
    /// </summary>
    public string LeadershipMaturityPath { get; init; } = string.Empty;
}
