using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IResultService
{
    Task<IReadOnlyList<ResultDto>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<ResultDto> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken);
}
