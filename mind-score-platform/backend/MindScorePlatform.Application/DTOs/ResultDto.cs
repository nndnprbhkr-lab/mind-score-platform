using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Application.DTOs;

public sealed class ResultDto
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public Guid TestId { get; init; }
    public string TestName { get; init; } = string.Empty;
    public decimal Score { get; init; }
    public string TypeCode { get; init; } = string.Empty;
    public string TypeName { get; init; } = string.Empty;
    public string Emoji { get; init; } = string.Empty;
    public string Tagline { get; init; } = string.Empty;
    public object? DimensionScores { get; init; }
    public object? Insights { get; init; }
    public DateTime CreatedAtUtc { get; init; }

    // ── Context-aware fields ──────────────────────────────────────────────────

    /// <summary>The context selected at the start of the assessment.</summary>
    public AssessmentContext Context { get; init; } = AssessmentContext.General;

    /// <summary>
    /// Deserialized context-specific insights. Shape varies by Context value:
    /// Career → CareerInsightsDto, Relationships → RelationshipInsightsDto,
    /// Leadership → LeadershipInsightsDto, PersonalDevelopment → PersonalDevelopmentInsightsDto.
    /// Null for General context.
    /// </summary>
    public object? ContextInsights { get; init; }

    /// <summary>Ordered list of question IDs served during the adaptive session.</summary>
    public IReadOnlyList<string>? AdaptivePath { get; init; }

    /// <summary>AI follow-up questions, answers, and resolved tensions. Null if no follow-up was run.</summary>
    public object? AiFollowUp { get; init; }

    /// <summary>Algorithm confidence per dimension (0–100). Low = AI follow-up targeted it.</summary>
    public object? DimensionConfidence { get; init; }
}
