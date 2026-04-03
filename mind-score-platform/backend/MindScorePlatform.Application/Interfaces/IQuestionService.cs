using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IQuestionService
{
    Task<IReadOnlyList<QuestionDto>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken);
    Task<QuestionDto> CreateAsync(CreateQuestionDto dto, CancellationToken cancellationToken);
}
