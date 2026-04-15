using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Application.Interfaces;

public interface IQuestionRepository
{
    Task<IReadOnlyList<Question>> GetByTestIdAsync(
        Guid testId,
        CancellationToken cancellationToken,
        Guid? ageBandId = null,
        AssessmentContext context = AssessmentContext.General);

    Task<Question?> GetByCodeAsync(Guid testId, string code, CancellationToken cancellationToken);

    Task AddAsync(Question question, CancellationToken cancellationToken);
}
