namespace MindScorePlatform.Domain.Entities;

public sealed class Result
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid TestId { get; set; }

    public decimal Score { get; set; }

    public DateTime CreatedAtUtc { get; set; }
}
