namespace MindScorePlatform.Application.DTOs.ContextInsights;

/// <summary>
/// Context-specific insights for the Relationships assessment context.
/// Domain basis: Attachment theory (Bowlby/Ainsworth), Thomas-Kilmann conflict model,
/// Chapman's 5 Love Languages, Gottman's Four Horsemen research.
/// Person's question: "Why do I keep having the same relationship problems?"
/// </summary>
public sealed class RelationshipInsightsDto
{
    /// <summary>
    /// Inferred attachment style from dimension scores.
    /// Values: Secure | Anxious | Avoidant | Disorganised
    /// </summary>
    public string AttachmentStyle { get; init; } = string.Empty;

    /// <summary>
    /// Ranked love languages inferred from personality dimensions.
    /// Languages: Words of Affirmation | Quality Time | Physical Touch | Acts of Service | Gifts
    /// </summary>
    public IReadOnlyList<LoveLanguageDto> LoveLanguages { get; init; } = [];

    /// <summary>
    /// Thomas-Kilmann conflict style.
    /// Values: Competing | Collaborating | Compromising | Accommodating | Avoiding
    /// </summary>
    public string ConflictStyle { get; init; } = string.Empty;

    /// <summary>What this type needs from a partner to feel secure and loved.</summary>
    public IReadOnlyList<string> EmotionalNeeds { get; init; } = [];

    /// <summary>Type combinations ranked by compatibility — who they naturally click with vs clash with.</summary>
    public IReadOnlyList<CompatibilityArchetypeDto> CompatibilityArchetypes { get; init; } = [];

    /// <summary>How this type closes down emotionally under threat or conflict.</summary>
    public IReadOnlyList<string> DefensivePatterns { get; init; } = [];

    /// <summary>Concrete language scripts for this type's hardest relationship conversations.</summary>
    public IReadOnlyList<CommunicationScriptDto> CommunicationScripts { get; init; } = [];

    /// <summary>The single relationship pattern most worth addressing for this type.</summary>
    public string RelationshipGrowthEdge { get; init; } = string.Empty;

    /// <summary>Relationship dynamics this type is systematically vulnerable to.</summary>
    public IReadOnlyList<string> ToxicPatterns { get; init; } = [];
}

public sealed class LoveLanguageDto
{
    public string Language { get; init; } = string.Empty;
    public int Score { get; init; }
}

public sealed class CompatibilityArchetypeDto
{
    public string TypeCode { get; init; } = string.Empty;
    public string Compatibility { get; init; } = string.Empty; // High | Good | Challenging
    public string Reason { get; init; } = string.Empty;
}

public sealed class CommunicationScriptDto
{
    public string Situation { get; init; } = string.Empty;
    public string Script { get; init; } = string.Empty;
}
