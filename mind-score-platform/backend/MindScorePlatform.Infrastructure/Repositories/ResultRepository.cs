using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class ResultRepository : IResultRepository
{
    private readonly AppDbContext _db;

    public ResultRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Result>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => await _db.Results
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(cancellationToken);

    public Task<Result?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _db.Results.FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

    public async Task AddAsync(Result result, CancellationToken cancellationToken)
    {
        _db.Results.Add(result);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
