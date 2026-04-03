using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface ITestRepository
{
    Task<IReadOnlyList<Test>> GetAllAsync(CancellationToken cancellationToken);
    Task<Test?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task AddAsync(Test test, CancellationToken cancellationToken);
}
