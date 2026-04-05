namespace MindScorePlatform.Application.DTOs;

public sealed record MindScoreModuleResultDto(
    string ModuleName,
    double RawScore,
    double Percentile,
    double WeightedScore,
    string Label);

public sealed record MindScoreResultDto(
    Guid UserId,
    Guid AgeBandId,
    string AgeBandName,
    int OverallScore,
    string Tier,
    IReadOnlyList<MindScoreModuleResultDto> Modules);
