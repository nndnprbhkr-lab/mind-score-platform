namespace MindScorePlatform.Domain.Entities;

public sealed class ModuleScore
{
    public Guid Id { get; set; }
    public Guid TestId { get; set; }
    public Guid ModuleId { get; set; }
    public decimal RawScore { get; set; }
    public decimal Percentile { get; set; }
    public decimal WeightedScore { get; set; }
    public DateTime CreatedAt { get; set; }
    public Module? Module { get; set; }
}
