using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class AuthService : IAuthService
{
    private readonly IUserRepository _users;
    private readonly IJwtTokenService _jwtTokenService;

    public AuthService(IUserRepository users, IJwtTokenService jwtTokenService)
    {
        _users = users;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var existing = await _users.GetByEmailAsync(request.Email, cancellationToken);
        if (existing is not null)
        {
            throw new InvalidOperationException("Email already registered.");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = request.Email,
            PasswordHash = PasswordHasher.Hash(request.Password),
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _users.AddAsync(user, cancellationToken);

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(user.Id, user.Email, token);
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken)
    {
        var user = await _users.GetByEmailAsync(request.Email, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("Invalid credentials.");
        }

        if (!PasswordHasher.Verify(request.Password, user.PasswordHash))
        {
            throw new InvalidOperationException("Invalid credentials.");
        }

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(user.Id, user.Email, token);
    }
}
