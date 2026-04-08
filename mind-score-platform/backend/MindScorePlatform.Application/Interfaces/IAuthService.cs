using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken);

    Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken);

    Task<AuthResponseDto> GuestLoginAsync(GuestLoginRequestDto request, CancellationToken cancellationToken);

    Task UpdateDobAsync(Guid userId, DateTime dateOfBirth, CancellationToken cancellationToken);
}
