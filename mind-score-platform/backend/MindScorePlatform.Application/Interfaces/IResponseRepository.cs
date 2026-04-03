using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IResponseRepository
{
    Task<IReadOnlyList<Response>> GetByUserAndTestAsync(Guid userId, Guid testId, CancellationToken cancellationToken);
    Task AddRangeAsync(IEnumerable<Response> responses, CancellationToken cancellationToken);
    Task<bool> HasUserSubmittedAsync(Guid userId, Guid testId, CancellationToken cancellationToken);
}
