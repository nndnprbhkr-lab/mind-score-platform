using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IReportService
{
    Task<IReadOnlyList<ReportDto>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<ReportDto> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken);
}
