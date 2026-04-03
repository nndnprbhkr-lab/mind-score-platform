namespace MindScorePlatform.Application.DTOs;

public sealed record ReportDto(Guid Id, Guid UserId, string Title, string Content, DateTime CreatedAtUtc);
