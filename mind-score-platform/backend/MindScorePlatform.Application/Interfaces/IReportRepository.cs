using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IReportRepository
{
    Task<IReadOnlyList<Report>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Report?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task AddAsync(Report report, CancellationToken cancellationToken);
}
