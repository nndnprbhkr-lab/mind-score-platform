using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IResultRepository
{
    Task<IReadOnlyList<Result>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task AddOrReplaceAsync(Result result, CancellationToken cancellationToken);

    Task UpdateAfterFollowUpAsync(
        Guid id,
        string aiFollowUpJson,
        string dimensionScoresJson,
        string insightsJson,
        string personalityType,
        string personalityName,
        string personalityEmoji,
        string personalityTagline,
        CancellationToken cancellationToken);
}
