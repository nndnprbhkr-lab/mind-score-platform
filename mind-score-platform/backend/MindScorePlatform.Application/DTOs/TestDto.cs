namespace MindScorePlatform.Application.DTOs;

public sealed record TestDto(Guid Id, string Name, DateTime CreatedAtUtc, int QuestionCount);

public sealed record CreateTestDto(string Name);
