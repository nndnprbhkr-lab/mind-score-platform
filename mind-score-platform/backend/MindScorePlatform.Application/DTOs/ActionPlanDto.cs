namespace MindScorePlatform.Application.DTOs;

public sealed class ActionPlanStepDto
{
    public string Icon { get; init; } = string.Empty;
    public string Title { get; init; } = string.Empty;
    public string Body { get; init; } = string.Empty;
    public string TraitLabel { get; init; } = string.Empty;
}

public sealed class ActionPlanDto
{
    public Guid ResultId { get; init; }
    public IReadOnlyList<ActionPlanStepDto> Steps { get; init; } = [];
}
