namespace MindScorePlatform.Domain.Entities;

public sealed class AgeBandModuleWeight
{
    public Guid Id { get; set; }

    public Guid AgeBandId { get; set; }

    public Guid ModuleId { get; set; }

    /// <summary>Weight in range 0.0–1.0. Sum of weights per age band = 1.0.</summary>
    public double Weight { get; set; }

    public DateTime CreatedAt { get; set; }

    public AgeBand? AgeBand { get; set; }

    public Module? Module { get; set; }
}
