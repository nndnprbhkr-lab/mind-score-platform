using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Implements user authentication and identity management.
/// </summary>
/// <remarks>
/// <para>
/// Supports three authentication paths:
/// <list type="bullet">
///   <item><see cref="RegisterAsync"/> — new full account with email + password.</item>
///   <item><see cref="LoginAsync"/> — credential validation for existing accounts.</item>
///   <item><see cref="GuestLoginAsync"/> — ephemeral account for anonymous access.</item>
/// </list>
/// </para>
/// <para>
/// All paths that accept a date of birth delegate age-band resolution to
/// <see cref="ResolveAgeBandAsync"/> to ensure consistent assignment logic
/// and avoid duplication.
/// </para>
/// </remarks>
public sealed class AuthService : IAuthService
{
    private readonly IUserRepository   _users;
    private readonly IJwtTokenService  _jwtTokenService;
    private readonly AppDbContext      _db;

    public AuthService(
        IUserRepository users,
        IJwtTokenService jwtTokenService,
        AppDbContext db)
    {
        _users           = users;
        _jwtTokenService = jwtTokenService;
        _db              = db;
    }

    /// <inheritdoc/>
    public async Task<AuthResponseDto> RegisterAsync(
        RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var existing = await _users.GetByEmailAsync(request.Email, cancellationToken);
        if (existing is not null)
            throw new InvalidOperationException("Email already registered.");

        var ageBandId = await ResolveAgeBandAsync(request.DateOfBirth, cancellationToken);

        var user = new User
        {
            Id           = Guid.NewGuid(),
            Name         = request.Name,
            Email        = request.Email,
            PasswordHash = PasswordHasher.Hash(request.Password),
            DateOfBirth  = request.DateOfBirth.HasValue
                ? DateTime.SpecifyKind(request.DateOfBirth.Value, DateTimeKind.Utc)
                : null,
            Domicile     = request.Domicile,
            AgeBandId    = ageBandId,
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _users.AddAsync(user, cancellationToken);

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(
            user.Id, user.Name, user.Email, token,
            user.Role == "admin",
            user.IsGuest,
            user.DateOfBirth.HasValue);
    }

    /// <inheritdoc/>
    public async Task<AuthResponseDto> LoginAsync(
        LoginRequestDto request, CancellationToken cancellationToken)
    {
        var user = await _users.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new InvalidOperationException("Invalid credentials.");

        if (!PasswordHasher.Verify(request.Password, user.PasswordHash))
            throw new InvalidOperationException("Invalid credentials.");

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(
            user.Id, user.Name, user.Email, token,
            user.Role == "admin",
            user.IsGuest,
            user.DateOfBirth.HasValue);
    }

    /// <inheritdoc/>
    public async Task<AuthResponseDto> GuestLoginAsync(
        GuestLoginRequestDto request, CancellationToken cancellationToken)
    {
        var ageBandId = await ResolveAgeBandAsync(request.DateOfBirth, cancellationToken);

        var guestId = Guid.NewGuid();
        var user = new User
        {
            Id           = guestId,
            Name         = request.Name,
            // Synthetic email keeps the users table consistent without
            // requiring a real address for guest sessions.
            Email        = $"guest_{guestId}@guest.local",
            PasswordHash = PasswordHasher.Hash(Guid.NewGuid().ToString()),
            IsGuest      = true,
            DateOfBirth  = request.DateOfBirth.HasValue
                ? DateTime.SpecifyKind(request.DateOfBirth.Value, DateTimeKind.Utc)
                : null,
            AgeBandId    = ageBandId,
            CreatedAtUtc = DateTime.UtcNow,
        };

        await _users.AddAsync(user, cancellationToken);

        var token = _jwtTokenService.CreateToken(user);
        return new AuthResponseDto(
            user.Id, user.Name, user.Email, token,
            false,
            true,
            user.DateOfBirth.HasValue);
    }

    /// <inheritdoc/>
    public async Task UpdateDobAsync(
        Guid userId, DateTime dateOfBirth, CancellationToken cancellationToken)
    {
        var user = await _users.GetByIdAsync(userId, cancellationToken)
            ?? throw new KeyNotFoundException("User not found.");

        user.DateOfBirth = DateTime.SpecifyKind(dateOfBirth, DateTimeKind.Utc);
        user.AgeBandId   = await ResolveAgeBandAsync(dateOfBirth, cancellationToken);

        await _db.SaveChangesAsync(cancellationToken);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    /// <summary>
    /// Looks up the active age band for the given date of birth.
    /// </summary>
    /// <remarks>
    /// Age is calculated by comparing the calendar year plus a day-of-year
    /// correction to ensure the birthday has actually occurred in the current
    /// year before incrementing.  The band returned is the first active band
    /// whose <c>[MinAge, MaxAge]</c> range contains the computed age, ordered
    /// by <c>DisplayOrder</c>.
    /// </remarks>
    /// <param name="dateOfBirth">
    /// The date of birth to resolve, or <c>null</c> when no DOB is provided.
    /// </param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>
    /// The matching age band's ID, or <c>null</c> if no DOB was provided or
    /// no band covers the computed age.
    /// </returns>
    private async Task<Guid?> ResolveAgeBandAsync(
        DateTime? dateOfBirth, CancellationToken cancellationToken)
    {
        if (!dateOfBirth.HasValue) return null;

        var dob = dateOfBirth.Value;
        var age = DateTime.UtcNow.Year - dob.Year;
        // Subtract one year if the birthday hasn't occurred yet this year.
        if (DateTime.UtcNow.DayOfYear < dob.DayOfYear) age--;

        var ageBand = await _db.AgeBands
            .Where(a => a.IsActive && a.MinAge <= age && a.MaxAge >= age)
            .OrderBy(a => a.DisplayOrder)
            .FirstOrDefaultAsync(cancellationToken);

        return ageBand?.Id;
    }
}
