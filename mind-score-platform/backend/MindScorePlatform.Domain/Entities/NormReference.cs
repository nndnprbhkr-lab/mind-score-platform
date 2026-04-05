namespace MindScorePlatform.Domain.Entities;

public sealed class NormReference
{
    public Guid Id { get; set; }

    public Guid ModuleId { get; set; }

    public Guid AgeBandId { get; set; }

    public double Mean { get; set; }

    public double StandardDeviation { get; set; }

    public int SampleSize { get; set; }

    public DateTime CreatedAt { get; set; }

    public Module? Module { get; set; }

    public AgeBand? AgeBand { get; set; }
}
