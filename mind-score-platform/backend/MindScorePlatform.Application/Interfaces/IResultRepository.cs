using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IResultRepository
{
    Task<IReadOnlyList<Result>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task AddAsync(Result result, CancellationToken cancellationToken);
}
