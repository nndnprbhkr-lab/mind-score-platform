using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Results;

[ApiController]
[Route("api/results")]
[Authorize]
public sealed class ResultsController : ControllerBase
{
    private readonly IResultService _results;

    public ResultsController(IResultService results) => _results = results;

    [HttpGet]
    public async Task<IActionResult> GetMine(CancellationToken cancellationToken)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _results.GetByUserIdAsync(userId, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _results.GetByIdAsync(id, userId, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{id:guid}/follow-up")]
    public async Task<IActionResult> SubmitFollowUp(
        Guid id, [FromBody] SubmitFollowUpDto dto, CancellationToken cancellationToken)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _results.SubmitFollowUpAsync(id, userId, dto, cancellationToken);
        return Ok(result);
    }
}
