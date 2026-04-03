using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class TestRepository : ITestRepository
{
    private readonly AppDbContext _db;

    public TestRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Test>> GetAllAsync(CancellationToken cancellationToken)
        => await _db.Tests.OrderBy(t => t.CreatedAtUtc).ToListAsync(cancellationToken);

    public Task<Test?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _db.Tests.FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

    public async Task AddAsync(Test test, CancellationToken cancellationToken)
    {
        _db.Tests.Add(test);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
