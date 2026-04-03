using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace MindScorePlatform.WebApi.Controllers;

[ApiController]
public sealed class ErrorController : ControllerBase
{
    [Route("/error")]
    public IActionResult HandleError()
    {
        var exception = HttpContext.Features.Get<IExceptionHandlerFeature>()?.Error;
        var message = exception?.Message ?? "An unexpected error occurred.";

        var statusCode = exception switch
        {
            KeyNotFoundException        => StatusCodes.Status404NotFound,
            UnauthorizedAccessException => StatusCodes.Status403Forbidden,
            InvalidOperationException   => StatusCodes.Status400BadRequest,
            _                           => StatusCodes.Status500InternalServerError,
        };

        return Problem(title: message, statusCode: statusCode);
    }
}
