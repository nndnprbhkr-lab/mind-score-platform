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

    public QuestionsController(IQuestionService questions) => _questions = questions;

    [HttpGet]
    public async Task<IActionResult> GetByTestId([FromQuery] Guid testId, CancellationToken cancellationToken)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier)
                          ?? User.FindFirstValue("sub");
        Guid? userId = Guid.TryParse(userIdClaim, out var parsed) ? parsed : null;
        var result = await _questions.GetByTestIdAsync(testId, cancellationToken, userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateQuestionDto dto, CancellationToken cancellationToken)
    {
        var result = await _questions.CreateAsync(dto, cancellationToken);
        return Created(string.Empty, result);
    }
}
