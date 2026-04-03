using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Responses;

[ApiController]
[Route("api/responses")]
[Authorize]
public sealed class ResponsesController : ControllerBase
{
    private readonly IResponseService _responses;

    public ResponsesController(IResponseService responses) => _responses = responses;

    [HttpPost("submit")]
    public async Task<IActionResult> Submit([FromBody] SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _responses.SubmitAsync(userId, dto, cancellationToken);
        return Ok(result);
    }
}
