using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IQuestionService
{
    Task<IReadOnlyList<QuestionDto>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken, Guid? userId = null);
    Task<QuestionDto> CreateAsync(CreateQuestionDto dto, CancellationToken cancellationToken);
}
