using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IResponseService
{
    Task<ResultDto> SubmitAsync(Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken);
}
