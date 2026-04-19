namespace MindScorePlatform.Application.DTOs;

/// <summary>
/// Pair compatibility analysis when both partners have taken the Relationship Dynamics Assessment.
/// Shows shared compatibility insights that both partners see.
/// </summary>
public sealed class PairCompatibilityDto
{
    /// <summary>Compatibility score (0-100). High = stable, well-matched. Low = challenging, requires conscious effort.</summary>
    public int CompatibilityScore { get; init; }

    /// <summary>Compatibility level: High | Good | Challenging.</summary>
    public string CompatibilityLevel { get; init; } = string.Empty;

    /// <summary>Primary risk: the conflict cycle or dynamic this pair is vulnerable to.</summary>
    public string ConflictCycleRisk { get; init; } = string.Empty;

    /// <summary>Type codes and names for both partners (for context).</summary>
    public PairMemberSnapshot Partner1 { get; init; } = new();
    public PairMemberSnapshot Partner2 { get; init; } = new();

    /// <summary>Blind spot for Partner 1: what they don't see about Partner 2.</summary>
    public string BlindSpot1 { get; init; } = string.Empty;

    /// <summary>Blind spot for Partner 2: what they don't see about Partner 1.</summary>
    public string BlindSpot2 { get; init; } = string.Empty;

    /// <summary>Concrete repair scripts tailored to this pair's dimension combination.</summary>
    public IReadOnlyList<RepairScriptDto> RepairScripts { get; init; } = [];

    /// <summary>Single shared growth edge: the pattern most worth addressing together.</summary>
    public string SharedGrowthEdge { get; init; } = string.Empty;

    /// <summary>Dimension comparison: how similar or different they are on each dimension.</summary>
    public IReadOnlyList<DimensionComparisonDto> DimensionComparison { get; init; } = [];

    /// <summary>Actionable advice specific to their pairing.</summary>
    public string ActionableAdvice { get; init; } = string.Empty;
}

public sealed class PairMemberSnapshot
{
    public string TypeCode { get; init; } = string.Empty;
    public string TypeName { get; init; } = string.Empty;
    public string Emoji { get; init; } = string.Empty;
}

public sealed class RepairScriptDto
{
    /// <summary>Situation where this script applies (e.g., "After a disagreement", "When one partner feels unseen").</summary>
    public string Situation { get; init; } = string.Empty;

    /// <summary>Concrete script tailored to their specific types and dimensions.</summary>
    public string Script { get; init; } = string.Empty;
}

public sealed class DimensionComparisonDto
{
    /// <summary>Dimension name: Attachment Security, Conflict Engagement, Emotional Expression, Love Language Alignment.</summary>
    public string DimensionName { get; init; } = string.Empty;

    /// <summary>Partner 1's percentage on this dimension (0-100).</summary>
    public int Partner1Score { get; init; }

    /// <summary>Partner 2's percentage on this dimension (0-100).</summary>
    public int Partner2Score { get; init; }

    /// <summary>Gap between them on this dimension (absolute difference).</summary>
    public int Gap { get; init; }

    /// <summary>What this gap means for the relationship (e.g., "You approach conflict differently; that's a strength if channeled right").</summary>
    public string GapInterpretation { get; init; } = string.Empty;
}
