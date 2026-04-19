using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Services.Scoring;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Validates a submission request and delegates scoring to the appropriate
/// <see cref="IScoringPipelineFactory"/> implementation.
/// </summary>
public sealed class ResponseService : IResponseService
{
    private readonly ITestRepository          _tests;
    private readonly IScoringPipelineFactory  _factory;

    public ResponseService(ITestRepository tests, IScoringPipelineFactory factory)
    {
        _tests   = tests;
        _factory = factory;
    }

    /// <inheritdoc/>
    public async Task<ResultDto> SubmitAsync(
        Guid userId, SubmitResponsesDto dto, CancellationToken cancellationToken)
    {
        var test = await _tests.GetByIdAsync(dto.TestId, cancellationToken)
            ?? throw new KeyNotFoundException($"Test {dto.TestId} not found.");

        if (!dto.Answers.Any())
            throw new InvalidOperationException(
                "No answers were submitted. Please complete the assessment before submitting.");

        return await _factory.ExecuteAsync(userId, dto, test.Name, cancellationToken);
    }
}
