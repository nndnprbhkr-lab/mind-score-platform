using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class QuestionRepository : IQuestionRepository
{
    private readonly AppDbContext _db;

    public QuestionRepository(AppDbContext db) => _db = db;

    public async Task<IReadOnlyList<Question>> GetByTestIdAsync(Guid testId, CancellationToken cancellationToken)
        => await _db.Questions
            .Where(q => q.TestId == testId)
            .OrderBy(q => q.Order)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Question question, CancellationToken cancellationToken)
    {
        _db.Questions.Add(question);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
