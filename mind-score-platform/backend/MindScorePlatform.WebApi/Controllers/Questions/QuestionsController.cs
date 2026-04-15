using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Questions;

[ApiController]
[Route("api/questions")]
[Authorize]
public sealed class QuestionsController : ControllerBase
{
    private readonly IQuestionService _questions;
    private readonly IAdaptiveQuestionService _adaptive;

    public QuestionsController(IQuestionService questions, IAdaptiveQuestionService adaptive)
    {
        _questions = questions;
        _adaptive = adaptive;
    }

    [HttpGet]
    public async Task<IActionResult> GetByTestId([FromQuery] Guid testId, CancellationToken cancellationToken)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier)
                          ?? User.FindFirstValue("sub");
        Guid? userId = Guid.TryParse(userIdClaim, out var parsed) ? parsed : null;
        var result = await _questions.GetByTestIdAsync(testId, cancellationToken, userId);
        return Ok(result);
    }

    /// <summary>
    /// Returns the next adaptive question for a session.
    /// Pass an empty <c>answeredSoFar</c> list to get the first question.
    /// When <c>IsComplete</c> is true in the response the client should proceed to submit.
    /// </summary>
    [HttpPost("next")]
    public async Task<IActionResult> GetNext(
        [FromBody] AdaptiveNextQuestionRequestDto dto,
        CancellationToken cancellationToken)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier)
                          ?? User.FindFirstValue("sub");
        Guid? userId = Guid.TryParse(userIdClaim, out var parsed) ? parsed : null;
        var result = await _adaptive.GetNextAsync(dto, userId, cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateQuestionDto dto, CancellationToken cancellationToken)
    {
        var result = await _questions.CreateAsync(dto, cancellationToken);
        return Created(string.Empty, result);
    }
}
