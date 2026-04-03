namespace MindScorePlatform.Domain.Entities;

public sealed class Question
{
    public Guid Id { get; set; }

    public Guid TestId { get; set; }

    public string Text { get; set; } = string.Empty;

    public int Order { get; set; }

    public DateTime CreatedAtUtc { get; set; }
}
