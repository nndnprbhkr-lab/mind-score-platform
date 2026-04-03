using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class ReportRepository : IReportRepository
{
    private readonly AppDbContext _db;

    public ReportRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Report>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => await _db.Reports
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(cancellationToken);

    public Task<Report?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _db.Reports.FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

    public async Task AddAsync(Report report, CancellationToken cancellationToken)
    {
        _db.Reports.Add(report);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
