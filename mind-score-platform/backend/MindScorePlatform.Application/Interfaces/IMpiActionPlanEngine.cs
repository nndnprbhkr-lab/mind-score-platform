using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IMpiActionPlanEngine
{
    ActionPlanDto Generate(Guid resultId, string typeCode,
        IReadOnlyDictionary<string, MpiDimensionScoreData> dimensions);
}

public sealed class MpiDimensionScoreData
{
    public double Percentage { get; init; }
    public string DominantPole { get; init; } = string.Empty;
    public string Strength { get; init; } = string.Empty;
}
