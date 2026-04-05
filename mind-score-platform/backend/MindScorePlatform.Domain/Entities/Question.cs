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
    public Module? Module { get; set; }
    public AgeBand? AgeBand { get; set; }
}
