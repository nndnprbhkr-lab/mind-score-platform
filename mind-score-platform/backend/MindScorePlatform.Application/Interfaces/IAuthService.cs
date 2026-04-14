using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Defines the authentication and identity management contract for the
/// MindScore platform.
/// </summary>
public interface IAuthService
{
    /// <summary>
    /// Creates a new user account with the supplied credentials.
    /// </summary>
    /// <param name="request">Name, email, password, and optional DOB / domicile.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>An <see cref="AuthResponseDto"/> containing the JWT token and user metadata.</returns>
    /// <exception cref="InvalidOperationException">Thrown when the email is already registered.</exception>
    Task<AuthResponseDto> RegisterAsync(
        RegisterRequestDto request, CancellationToken cancellationToken);

    /// <summary>
    /// Authenticates an existing user with email and password.
    /// </summary>
    /// <param name="request">Login credentials.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>An <see cref="AuthResponseDto"/> on success.</returns>
    /// <exception cref="InvalidOperationException">Thrown when credentials are invalid.</exception>
    Task<AuthResponseDto> LoginAsync(
        LoginRequestDto request, CancellationToken cancellationToken);

    /// <summary>
    /// Creates a temporary guest account that does not require an email address.
    /// </summary>
    /// <remarks>
    /// A synthetic email is generated server-side so the user row is consistent
    /// with registered accounts.  Guest accounts have no persistent history
    /// across sessions.
    /// </remarks>
    /// <param name="request">Display name and optional date of birth.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>An <see cref="AuthResponseDto"/> for the ephemeral guest session.</returns>
    Task<AuthResponseDto> GuestLoginAsync(
        GuestLoginRequestDto request, CancellationToken cancellationToken);

    /// <summary>
    /// Records the user's date of birth and assigns the appropriate age band.
    /// </summary>
    /// <remarks>
    /// Called when a user who skipped DOB at registration attempts to start
    /// the MindScore cognitive assessment, which requires age-band normalisation.
    /// </remarks>
    /// <param name="userId">The authenticated user's ID.</param>
    /// <param name="dateOfBirth">The date of birth to record.</param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    Task UpdateDobAsync(
        Guid userId, DateTime dateOfBirth, CancellationToken cancellationToken);
}
