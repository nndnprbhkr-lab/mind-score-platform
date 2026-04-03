namespace MindScorePlatform.Application.DTOs;

public sealed record ResultDto(Guid Id, Guid UserId, Guid TestId, string TestName, decimal Score, DateTime CreatedAtUtc);
