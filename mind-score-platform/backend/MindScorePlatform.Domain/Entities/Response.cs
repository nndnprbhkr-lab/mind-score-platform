namespace MindScorePlatform.Domain.Entities;

public sealed class Response
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid QuestionId { get; set; }

    public string Value { get; set; } = string.Empty;

    public DateTime CreatedAtUtc { get; set; }
}
