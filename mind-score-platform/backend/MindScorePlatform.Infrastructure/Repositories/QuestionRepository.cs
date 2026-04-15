using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Repositories;

public sealed class QuestionRepository : IQuestionRepository
{
    private readonly AppDbContext _db;

    public QuestionRepository(AppDbContext db) => _db = db;

    /// <summary>
    /// Returns questions for a test, filtered by age band and optionally by assessment context.
    /// Context filtering: questions with no context tags (null) are shown in all contexts.
    /// Questions tagged for a specific context are only shown when that context is active.
    /// </summary>
    public async Task<IReadOnlyList<Question>> GetByTestIdAsync(
        Guid testId,
        CancellationToken cancellationToken,
        Guid? ageBandId = null,
        AssessmentContext context = AssessmentContext.General)
    {
        var query = _db.Questions.Where(q => q.TestId == testId);

        // Age band filter — show universal questions (no band) + band-specific ones
        if (ageBandId.HasValue)
            query = query.Where(q => q.AgeBandId == ageBandId.Value || !q.AgeBandId.HasValue);

        // Context filter — show universal questions (no tags) + questions tagged for this context
        // Applied in-memory after fetch because JSON array filtering is cleaner that way
        var questions = await query.OrderBy(q => q.Order).ToListAsync(cancellationToken);

        if (context != AssessmentContext.General)
        {
            var contextName = context.ToString();
            questions = questions
                .Where(q => q.ContextTagsJson == null || q.ContextTagsJson.Contains(contextName))
                .ToList();
        }

        return questions;
    }

    /// <summary>
    /// Fetches a single question by its code within a test.
    /// Used by the adaptive engine to resolve next-question branching targets.
    /// </summary>
    public async Task<Question?> GetByCodeAsync(Guid testId, string code, CancellationToken cancellationToken)
        => await _db.Questions
            .Where(q => q.TestId == testId && q.Code == code)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task AddAsync(Question question, CancellationToken cancellationToken)
    {
        _db.Questions.Add(question);
        await _db.SaveChangesAsync(cancellationToken);
    }
}
