using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Infrastructure.Persistence;
using MindScorePlatform.Infrastructure.Services.Mpi;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Scoring pipeline for MPI (MindType Profile Inventory) assessments.
/// Handles all personality-type tests — catch-all when no more specific
/// pipeline claims the test name.
/// </summary>
public sealed class MpiScoringPipeline : ScoringPipelineBase
{
    private readonly IMpiScoringEngine  _mpiEngine;
    private readonly IAiFollowUpService _aiFollowUp;
    private readonly AppDbContext       _db;

    public MpiScoringPipeline(
        IResponseRepository  responses,
        IResultRepository    results,
        IQuestionRepository  questions,
        IMpiScoringEngine    mpiEngine,
        IAiFollowUpService   aiFollowUp,
        AppDbContext         db)
        : base(responses, results, questions)
    {
        _mpiEngine  = mpiEngine;
        _aiFollowUp = aiFollowUp;
        _db         = db;
    }

    /// <summary>
    /// Catch-all — handles every test that is not claimed by a more specific pipeline.
    /// </summary>
    public override bool CanHandle(string testName) => true;

    public override async Task<ResultDto> ExecuteAsync(
        Guid userId, SubmitResponsesDto dto, string testName, CancellationToken ct)
    {
        var questionMap = await BuildQuestionMapAsync(dto.TestId, ct);

        await PersistResponsesAsync(userId, dto.Answers, questionMap, ct);

        var scoringInputs = dto.Answers
            .Where(a => questionMap.ContainsKey(a.QuestionId) && int.TryParse(a.Value, out _))
            .Select(a => new MpiResponseInput
            {
                QuestionId = questionMap[a.QuestionId].Code,
                Value      = int.Parse(a.Value),
            })
            .ToList();

        var mpiResult = _mpiEngine.Score(scoringInputs);

        var (_, confidence) = TensionDetector.Detect(mpiResult.Dimensions);

        var user = await _db.Users
            .Include(u => u.AgeBand)
            .FirstOrDefaultAsync(u => u.Id == userId, ct);
        var ageBandName = user?.AgeBand?.Name;

        var followUp = await _aiFollowUp.GenerateAsync(
            mpiResult.Dimensions, dto.Context, ageBandName, ct);

        var insightsPayload = new
        {
            strengths          = mpiResult.Strengths,
            growthAreas        = mpiResult.GrowthAreas,
            careerPaths        = mpiResult.CareerPaths,
            communicationStyle = mpiResult.CommunicationStyle,
            workStyle          = mpiResult.WorkStyle,
        };

        var result = new Result
        {
            Id                      = Guid.NewGuid(),
            UserId                  = userId,
            TestId                  = dto.TestId,
            Score                   = mpiResult.OverallScore,
            PersonalityType         = mpiResult.TypeCode,
            PersonalityName         = mpiResult.TypeName,
            PersonalityEmoji        = mpiResult.Emoji,
            PersonalityTagline      = mpiResult.Tagline,
            DimensionScoresJson     = JsonSerializer.Serialize(mpiResult.Dimensions,   ResultDtoMapper.CamelCase),
            InsightsJson            = JsonSerializer.Serialize(insightsPayload,         ResultDtoMapper.CamelCase),
            Context                 = dto.Context,
            DimensionConfidenceJson = JsonSerializer.Serialize(confidence,              ResultDtoMapper.CamelCase),
            AiFollowUpJson          = followUp is not null
                                          ? JsonSerializer.Serialize(followUp, ResultDtoMapper.CamelCase)
                                          : null,
            CreatedAtUtc            = DateTime.UtcNow,
        };

        await _results.AddOrReplaceAsync(result, ct);
        return ResultDtoMapper.ToDto(result, testName);
    }
}
