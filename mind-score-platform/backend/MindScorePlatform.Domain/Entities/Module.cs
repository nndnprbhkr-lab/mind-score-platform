namespace MindScorePlatform.Domain.Entities;

public sealed class Module
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public ICollection<Question> Questions { get; set; } = [];
    public ICollection<ModuleScore> ModuleScores { get; set; } = [];
}
