using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken);

    Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken);
}
