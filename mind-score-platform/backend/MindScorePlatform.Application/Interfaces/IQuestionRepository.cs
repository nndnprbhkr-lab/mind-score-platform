using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IQuestionRepository
{
    Task<IReadOnlyList<Question>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken, Guid? ageBandId = null);
    Task AddAsync(Question question, CancellationToken cancellationToken);
}
