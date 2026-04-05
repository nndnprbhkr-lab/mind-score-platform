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
            query = query.Where(q => q.AgeBandId == ageBandId.Value || q.AgeBandId == null);
        return await query.OrderBy(q => q.Order).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Question question, CancellationToken cancellationToken)
    {
        _db.Questions.Add(question);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
