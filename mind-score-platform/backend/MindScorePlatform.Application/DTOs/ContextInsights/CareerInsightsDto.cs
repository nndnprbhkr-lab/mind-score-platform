namespace MindScorePlatform.Application.DTOs.ContextInsights;

/// <summary>
/// Context-specific insights for the Career assessment context.
/// Domain basis: Occupational psychology, Holland's RIASEC, Hogan Personality Inventory.
/// Person's question: "What kind of work am I built for, and where will I burn out?"
/// </summary>
public sealed class CareerInsightsDto
{
    /// <summary>Fit scores (0–100) across key work environment dimensions.</summary>
    public WorkEnvironmentFitDto WorkEnvironmentFit { get; init; } = new();

    /// <summary>How this personality naturally shows up in collaborative settings.</summary>
    public string CollaborationStyle { get; init; } = string.Empty;

    /// <summary>Management styles that energise vs drain this type.</summary>
    public ManagementCompatibilityDto ManagementCompatibility { get; init; } = new();

    /// <summary>Ranked role archetypes with fit scores — e.g. CEO: 94%, IC Specialist: 41%.</summary>
    public IReadOnlyList<RoleArchetypeDto> RoleArchetypes { get; init; } = [];

    /// <summary>Industries that match this type's cognitive and emotional wiring.</summary>
    public IReadOnlyList<IndustryAffinityDto> IndustryAffinity { get; init; } = [];

    /// <summary>How this specific type burns out — not generic stress, but type-specific patterns.</summary>
    public IReadOnlyList<string> BurnoutSignals { get; init; } = [];

    /// <summary>Natural career trajectory pattern: linear, portfolio, specialist, or generalist.</summary>
    public string CareerTrajectory { get; init; } = string.Empty;

    /// <summary>How this type comes across in interviews and what to amplify.</summary>
    public string InterviewPresence { get; init; } = string.Empty;

    /// <summary>Role types and environments that are mismatches for this personality.</summary>
    public IReadOnlyList<string> RedFlags { get; init; } = [];
}

public sealed class WorkEnvironmentFitDto
{
    public int Structured { get; init; }
    public int Fluid { get; init; }
    public int Remote { get; init; }
    public int HighStakes { get; init; }
    public int Collaborative { get; init; }
}

public sealed class ManagementCompatibilityDto
{
    public IReadOnlyList<string> ThrivesUnder { get; init; } = [];
    public IReadOnlyList<string> ChallengedBy { get; init; } = [];
}

public sealed class RoleArchetypeDto
{
    public string Name { get; init; } = string.Empty;
    public int FitScore { get; init; }
    public string Description { get; init; } = string.Empty;
}

public sealed class IndustryAffinityDto
{
    public string Industry { get; init; } = string.Empty;
    public int Score { get; init; }
}
