namespace MindScorePlatform.Application.DTOs;

public sealed record AuthResponseDto(Guid UserId, string Name, string Email, string AccessToken, bool IsAdmin, bool IsGuest, bool HasDob);
