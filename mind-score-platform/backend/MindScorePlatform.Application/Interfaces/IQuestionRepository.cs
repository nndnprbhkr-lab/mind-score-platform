using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IQuestionRepository
{
    Task<IReadOnlyList<Question>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken);
    Task AddAsync(Question question, CancellationToken cancellationToken);
}
