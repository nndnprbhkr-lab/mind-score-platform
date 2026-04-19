using System.Text.Json;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Maps a <see cref="Result"/> entity to a <see cref="ResultDto"/>.
/// Shared by all scoring pipelines and by <see cref="ResultService"/>.
/// </summary>
internal static class ResultDtoMapper
{
    internal static readonly JsonSerializerOptions CamelCase =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    internal static ResultDto ToDto(Result result, string testName)
    {
        static JsonElement? Deserialize(string? json) =>
            string.IsNullOrEmpty(json) ? null : JsonSerializer.Deserialize<JsonElement>(json);

        static IReadOnlyList<string>? DeserializeStringList(string? json) =>
            string.IsNullOrEmpty(json)
                ? null
                : JsonSerializer.Deserialize<List<string>>(json);

        return new ResultDto
        {
            Id                  = result.Id,
            UserId              = result.UserId,
            TestId              = result.TestId,
            TestName            = testName,
            Score               = result.Score,
            TypeCode            = result.PersonalityType,
            TypeName            = result.PersonalityName,
            Emoji               = result.PersonalityEmoji,
            Tagline             = result.PersonalityTagline,
            DimensionScores     = Deserialize(result.DimensionScoresJson),
            Insights            = Deserialize(result.InsightsJson),
            Context             = result.Context,
            ContextInsights     = Deserialize(result.ContextInsightsJson),
            AdaptivePath        = DeserializeStringList(result.AdaptivePathJson),
            AiFollowUp          = Deserialize(result.AiFollowUpJson),
            DimensionConfidence = Deserialize(result.DimensionConfidenceJson),
            CreatedAtUtc        = result.CreatedAtUtc,
        };
    }
}
