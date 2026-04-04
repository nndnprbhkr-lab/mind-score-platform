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
}
