using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IMpiActionPlanEngine
{
    ActionPlanDto Generate(Guid resultId, string typeCode,
        IReadOnlyDictionary<string, MpiDimensionScore> dimensions);
}
