namespace MindScorePlatform.Application.DTOs;

public sealed record AuthResponseDto(Guid UserId, string Email, string AccessToken);
