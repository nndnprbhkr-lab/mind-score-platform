using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Services;

public sealed class AuthService : IAuthService
{
    private readonly IUserRepository _users;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly AppDbContext _db;

    public AuthService(IUserRepository users, IJwtTokenService jwtTokenService, AppDbContext db)
    {
        _users = users;
        _jwtTokenService = jwtTokenService;
        _db = db;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var existing = await _users.GetByEmailAsync(request.Email, cancellationToken);
        if (existing is not null)
        {
            throw new InvalidOperationException("Email already registered.");
        }

        Guid? ageBandId = null;
        if (request.DateOfBirth.HasValue)
        {
            var age = DateTime.UtcNow.Year - request.DateOfBirth.Value.Year;
            if (DateTime.UtcNow.DayOfYear < request.DateOfBirth.Value.DayOfYear) age--;

            var ageBand = await _db.AgeBands
                .Where(a => a.IsActive && a.MinAge <= age && a.MaxAge >= age)
                .OrderBy(a => a.DisplayOrder)
                .FirstOrDefaultAsync(cancellationToken);

            ageBandId = ageBand?.Id;
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Email = request.Email,
            PasswordHash = PasswordHasher.Hash(request.Password),
            DateOfBirth = request.DateOfBirth.HasValue
                ? DateTime.SpecifyKind(request.DateOfBirth.Value, DateTimeKind.Utc)
                : null,
            Domicile = request.Domicile,
            AgeBandId = ageBandId,
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _users.AddAsync(user, cancellationToken);

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(user.Id, user.Name, user.Email, token, user.Role == "admin", user.IsGuest);
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
        return new AuthResponseDto(user.Id, user.Name, user.Email, token, user.Role == "admin", user.IsGuest);
    }

    public async Task<AuthResponseDto> GuestLoginAsync(GuestLoginRequestDto request, CancellationToken cancellationToken)
    {
        var guestId = Guid.NewGuid();
        var user = new User
        {
            Id = guestId,
            Name = request.Name,
            Email = $"guest_{guestId}@guest.local",
            PasswordHash = PasswordHasher.Hash(Guid.NewGuid().ToString()),
            IsGuest = true,
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _users.AddAsync(user, cancellationToken);

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(user.Id, user.Name, user.Email, token, false, true);
    }
}
