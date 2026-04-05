using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IMindScoringEngine
{
    Task<MindScoreResultDto> ScoreAsync(
        Guid userId,
        Guid ageBandId,
        IReadOnlyList<(Guid QuestionId, int Value)> responses,
        CancellationToken cancellationToken = default);
}
