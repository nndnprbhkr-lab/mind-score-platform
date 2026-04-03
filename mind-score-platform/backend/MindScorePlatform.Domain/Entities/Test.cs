namespace MindScorePlatform.Domain.Entities;

public sealed class Test
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public DateTime CreatedAtUtc { get; set; }
}
