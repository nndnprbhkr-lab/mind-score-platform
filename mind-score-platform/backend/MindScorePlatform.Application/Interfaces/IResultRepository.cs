using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IResultRepository
{
    Task<IReadOnlyList<Result>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<Result?> GetByUserAndTestAsync(Guid userId, Guid testId, CancellationToken cancellationToken);
    Task AddAsync(Result result, CancellationToken cancellationToken);
    Task AddOrReplaceAsync(Result result, CancellationToken cancellationToken);
}
