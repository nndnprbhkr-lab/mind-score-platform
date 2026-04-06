using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class ResponseRepository : IResponseRepository
{
    private readonly AppDbContext _db;

    public ResponseRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Response>> GetByUserAndTestAsync(
        Guid userId, Guid testId, CancellationToken cancellationToken)
    {
        var questionIds = await _db.Questions
            .Where(q => q.TestId == testId)
            .Select(q => q.Id)
            .ToListAsync(cancellationToken);

        return await _db.Responses
            .Where(r => r.UserId == userId && questionIds.Contains(r.QuestionId))
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> HasUserSubmittedAsync(
        Guid userId, Guid testId, CancellationToken cancellationToken)
    {
        var questionIds = await _db.Questions
            .Where(q => q.TestId == testId)
            .Select(q => q.Id)
            .ToListAsync(cancellationToken);

        return await _db.Responses
            .AnyAsync(r => r.UserId == userId && questionIds.Contains(r.QuestionId), cancellationToken);
    }

    public async Task AddRangeAsync(IEnumerable<Response> responses, CancellationToken cancellationToken)
    {
        _db.Responses.AddRange(responses);
        await _db.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteByUserAndQuestionsAsync(Guid userId, IEnumerable<Guid> questionIds, CancellationToken cancellationToken)
    {
        var ids = questionIds.ToList();
        if (ids.Count == 0) return;
        await _db.Responses
            .Where(r => r.UserId == userId && ids.Contains(r.QuestionId))
            .ExecuteDeleteAsync(cancellationToken);
    }
}
