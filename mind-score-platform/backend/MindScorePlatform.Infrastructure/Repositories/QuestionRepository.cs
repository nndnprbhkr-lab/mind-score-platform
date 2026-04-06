using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class QuestionRepository : IQuestionRepository
{
    private readonly AppDbContext _db;

    public QuestionRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Question>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken, Guid? ageBandId = null)
    {
        var query = _db.Questions.Where(q => q.TestId == testId);

        if (ageBandId.HasValue)
        {
            // Resolve all age band IDs with the same age range as the user's band.
            // This handles duplicate/mismatched IDs (e.g. random-UUID vs deterministic c1000000-... rows).
            var userBand = await _db.AgeBands.FindAsync([ageBandId.Value], cancellationToken);
            if (userBand is not null)
            {
                var equivalentIds = await _db.AgeBands
                    .Where(a => a.MinAge == userBand.MinAge && a.MaxAge == userBand.MaxAge)
                    .Select(a => a.Id)
                    .ToListAsync(cancellationToken);

                query = query.Where(q => !q.AgeBandId.HasValue || equivalentIds.Contains(q.AgeBandId.Value));
            }
            else
            {
                query = query.Where(q => !q.AgeBandId.HasValue);
            }
        }

        return await query.OrderBy(q => q.Order).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Question question, CancellationToken cancellationToken)
    {
        _db.Questions.Add(question);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
