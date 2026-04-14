using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.WebApi.Controllers.Tests;

/// <summary>
/// API endpoints for managing and retrieving assessments.
/// </summary>
/// <remarks>
/// All endpoints require authentication (<c>[Authorize]</c>).
/// The <c>Create</c> action should additionally be restricted to admin
/// users via a policy or role check in production deployments.
/// </remarks>
[ApiController]
[Route("api/tests")]
[Authorize]
public sealed class TestsController : ControllerBase
{
    private readonly ITestService _tests;

    public TestsController(ITestService tests) => _tests = tests;

    /// <summary>
    /// Returns all available assessments with their question counts.
    /// </summary>
    /// <returns>A list of <see cref="TestDto"/> objects.</returns>
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _tests.GetAllAsync(cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Returns a single assessment by its unique identifier.
    /// </summary>
    /// <param name="id">The assessment GUID.</param>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _tests.GetByIdAsync(id, cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Creates a new assessment.  Restricted to admin users.
    /// </summary>
    /// <param name="dto">The name of the new assessment.</param>
    /// <returns>HTTP 201 Created with the new <see cref="TestDto"/> in the body.</returns>
    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateTestDto dto, CancellationToken cancellationToken)
    {
        var result = await _tests.CreateAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
}
