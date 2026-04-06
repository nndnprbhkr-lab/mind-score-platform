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

    public Task<Result?> GetByUserAndTestAsync(Guid userId, Guid testId, CancellationToken cancellationToken)
        => _db.Results.FirstOrDefaultAsync(r => r.UserId == userId && r.TestId == testId, cancellationToken);

    public async Task AddAsync(Result result, CancellationToken cancellationToken)
    {
        _db.Results.Add(result);
        await _db.SaveChangesAsync(cancellationToken);
    }

    public async Task AddOrReplaceAsync(Result result, CancellationToken cancellationToken)
    {
        await _db.Database.ExecuteSqlRawAsync(@"
            INSERT INTO results
                (id, userid, testid, score, personalitytype, personalityname,
                 personalityemoji, personalitytagline, dimensionscoresjson, insightsjson, createdatutc)
            VALUES
                ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10})
            ON CONFLICT (userid, testid) DO UPDATE SET
                id                  = EXCLUDED.id,
                score               = EXCLUDED.score,
                personalitytype     = EXCLUDED.personalitytype,
                personalityname     = EXCLUDED.personalityname,
                personalityemoji    = EXCLUDED.personalityemoji,
                personalitytagline  = EXCLUDED.personalitytagline,
                dimensionscoresjson = EXCLUDED.dimensionscoresjson,
                insightsjson        = EXCLUDED.insightsjson,
                createdatutc        = EXCLUDED.createdatutc",
            result.Id,
            result.UserId,
            result.TestId,
            result.Score,
            result.PersonalityType,
            result.PersonalityName,
            result.PersonalityEmoji,
            result.PersonalityTagline,
            result.DimensionScoresJson,
            result.InsightsJson,
            result.CreatedAtUtc);
    }
}
