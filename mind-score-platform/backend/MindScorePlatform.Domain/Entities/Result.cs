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
}
