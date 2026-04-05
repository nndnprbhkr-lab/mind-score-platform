namespace MindScorePlatform.Domain.Entities;

public sealed class AgeBand
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int MinAge { get; set; }
    public int MaxAge { get; set; }
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public ICollection<Question> Questions { get; set; } = [];
}
