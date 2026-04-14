using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Auth;

/// <summary>
/// API endpoints for user authentication and identity management.
/// </summary>
/// <remarks>
/// All endpoints are anonymous (no <c>[Authorize]</c>) since they are the
/// entry points for obtaining a JWT token.  Tokens are returned in the
/// <see cref="AuthResponseDto.AccessToken"/> field and must be supplied as
/// <c>Authorization: Bearer &lt;token&gt;</c> on subsequent requests.
/// </remarks>
[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly IAuthService _auth;

    public AuthController(IAuthService auth)
    {
        _auth = auth;
    }

    /// <summary>
    /// Registers a new user account and returns a JWT token on success.
    /// </summary>
    /// <param name="request">Registration payload including name, email, password, and optional DOB.</param>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register(
        [FromBody] RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.RegisterAsync(request, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Authenticates an existing user and returns a JWT token on success.
    /// </summary>
    /// <param name="request">Email and password credentials.</param>
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(
        [FromBody] LoginRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.LoginAsync(request, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Creates a temporary guest session and returns a JWT token.
    /// </summary>
    /// <remarks>
    /// Guest sessions do not require an email address.  A synthetic email
    /// is generated server-side.  Guest accounts cannot access persistent
    /// history across sessions.
    /// </remarks>
    /// <param name="request">Display name and optional date of birth.</param>
    [HttpPost("guest")]
    public async Task<ActionResult<AuthResponseDto>> GuestLogin(
        [FromBody] GuestLoginRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.GuestLoginAsync(request, cancellationToken);
        return Ok(result);
    }
}
