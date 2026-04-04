using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Auth;

[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly IAuthService _auth;

    public AuthController(IAuthService auth)
    {
        _auth = auth;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.RegisterAsync(request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.LoginAsync(request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("guest")]
    public async Task<ActionResult<AuthResponseDto>> GuestLogin([FromBody] GuestLoginRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _auth.GuestLoginAsync(request, cancellationToken);
        return Ok(result);
    }
}
