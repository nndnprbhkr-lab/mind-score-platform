using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class ReportService : IReportService
{
    private readonly IReportRepository _reports;

    public ReportService(IReportRepository reports) => _reports = reports;

    public async Task<IReadOnlyList<ReportDto>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        var reports = await _reports.GetByUserIdAsync(userId, cancellationToken);
        return reports.Select(r => new ReportDto(r.Id, r.UserId, r.Title, r.Content, r.CreatedAtUtc)).ToList();
    }

    public async Task<ReportDto> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken)
    {
        var report = await _reports.GetByIdAsync(id, cancellationToken)
            ?? throw new KeyNotFoundException($"Report {id} not found.");

        if (report.UserId != userId)
            throw new UnauthorizedAccessException("Access denied.");

        return new ReportDto(report.Id, report.UserId, report.Title, report.Content, report.CreatedAtUtc);
    }
}
