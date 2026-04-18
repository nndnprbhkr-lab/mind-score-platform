using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Application.DTOs;

public sealed record AnswerDto(Guid QuestionId, string Value);

public sealed record SubmitResponsesDto(
    Guid TestId,
    IReadOnlyList<AnswerDto> Answers,
    AssessmentContext Context = AssessmentContext.General);
