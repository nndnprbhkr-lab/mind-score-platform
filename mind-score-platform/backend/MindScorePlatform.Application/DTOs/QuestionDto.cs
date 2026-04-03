namespace MindScorePlatform.Application.DTOs;

public sealed record QuestionDto(Guid Id, Guid TestId, string Text, int Order);

public sealed record CreateQuestionDto(Guid TestId, string Text, int Order);
