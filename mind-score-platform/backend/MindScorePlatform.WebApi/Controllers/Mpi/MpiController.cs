using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Mpi;

public sealed record MpiScoreRequest(Guid TestId, List<MpiResponseInput> Responses);

[ApiController]
[Route("api/mpi")]
[Authorize]
public sealed class MpiController : ControllerBase
{
    private readonly IMpiScoringEngine _engine;

    public MpiController(IMpiScoringEngine engine) => _engine = engine;

    [HttpPost("score")]
    public IActionResult Score([FromBody] MpiScoreRequest request)
    {
        var result = _engine.Score(request.Responses);
        return Ok(result);
    }
}
