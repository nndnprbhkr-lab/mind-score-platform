using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Infrastructure.Persistence;
using MindScorePlatform.Infrastructure.Services.RelationshipDynamicsSeed;

namespace MindScorePlatform.Infrastructure.Services.Scoring;

/// <summary>
/// Scoring pipeline for Relationship Dynamics Assessment (standalone test).
/// Solo mode: Scores 4 dimensions → derives type code → generates relationship profile.
/// Pair mode: Compares two user results → generates compatibility analysis both see.
/// </summary>
public sealed class RelationshipDynamicsScoringPipeline : ScoringPipelineBase
{
    private readonly AppDbContext _db;

    public RelationshipDynamicsScoringPipeline(
        IResponseRepository responses,
        IResultRepository results,
        IQuestionRepository questions,
        AppDbContext db)
        : base(responses, results, questions)
    {
        _db = db;
    }

    public override bool CanHandle(string testName)
    {
        return testName == "Relationship Dynamics Assessment";
    }

    public override async Task<ResultDto> ExecuteAsync(
        Guid userId,
        SubmitResponsesDto dto,
        string testName,
        CancellationToken ct)
    {
        // Load question map and persist responses
        var questions = await BuildQuestionMapAsync(dto.TestId, ct);
        await PersistResponsesAsync(userId, dto.Answers, questions, ct);

        // Convert answers to scored values
        var scoringInputs = dto.Answers
            .Where(a => questions.ContainsKey(a.QuestionId))
            .Select(a =>
            {
                var q = questions[a.QuestionId];
                var rawValue = int.Parse(a.Value);

                // Apply reversal if needed (1-5 scale, so 6 − value)
                var adjustedValue = q.IsReverseScored == true ? 6 - rawValue : rawValue;

                return new MpiResponseInput { QuestionId = q.Code, Value = adjustedValue };
            })
            .ToList();

        // Score 4 dimensions
        var dimensions = ScoreDimensions(scoringInputs);

        // Derive type code from dimension poles
        var typeCode = DeriveTypeCode(dimensions);

        // Look up type profile
        var profile = RelationshipTypeProfileLibrary.GetProfile(typeCode);

        // Calculate overall score (average of dimensions)
        var overallScore = (int)Math.Round(dimensions.Values.Average(d => d.Percentage));

        // Generate solo result
        var dimensionScoresJson = JsonSerializer.Serialize(
            dimensions.ToDictionary(
                kvp => kvp.Key,
                kvp => new { kvp.Value.Percentage, kvp.Value.DominantPole, kvp.Value.Strength }
            ),
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }
        );

        var insightsJson = JsonSerializer.Serialize(
            new
            {
                typeCode = profile.Code,
                typeName = profile.Name,
                overview = profile.Overview,
                strengths = profile.Strengths,
                growthAreas = profile.GrowthAreas,
                emotionalNeeds = profile.EmotionalNeeds,
                defensivePatterns = profile.DefensivePatterns,
                relationshipGrowthEdge = profile.RelationshipGrowthEdge,
            },
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }
        );

        // Create result
        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = dto.TestId,
            Score = overallScore,
            PersonalityType = profile.Code,
            PersonalityName = profile.Name,
            PersonalityEmoji = profile.Emoji,
            PersonalityTagline = profile.Tagline,
            DimensionScoresJson = dimensionScoresJson,
            InsightsJson = insightsJson,
            Context = dto.Context,
            CreatedAtUtc = DateTime.UtcNow,
        };

        // Check for pair: if another user has a result on this test, generate pair analysis
        var partnerResult = await _db.Results
            .Where(r => r.TestId == dto.TestId && r.UserId != userId)
            .OrderByDescending(r => r.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (partnerResult != null)
        {
            // Both users have results; generate pair analysis
            var pairAnalysis = GeneratePairAnalysis(result, partnerResult);
            result.ContextInsightsJson = JsonSerializer.Serialize(
                pairAnalysis,
                new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }
            );
        }

        // Persist result
        await _results.AddOrReplaceAsync(result, ct);

        // Return DTO
        return ResultDtoMapper.ToDto(result, testName);
    }

    private Dictionary<string, MpiDimensionScore> ScoreDimensions(IReadOnlyList<MpiResponseInput> answers)
    {
        // 4 dimensions, each with ~5-6 questions
        var dimensions = new Dictionary<string, (int Raw, int Count)>
        {
            ["Attachment Security"] = (0, 0),
            ["Conflict Engagement"] = (0, 0),
            ["Emotional Expression"] = (0, 0),
            ["Love Language Alignment"] = (0, 0),
        };

        // Map question codes to dimension
        var dimensionMap = new Dictionary<string, string>
        {
            // Attachment (RD_AS_XX)
            ["RD_AS_01"] = "Attachment Security",
            ["RD_AS_02"] = "Attachment Security",
            ["RD_AS_03"] = "Attachment Security",
            ["RD_AS_04"] = "Attachment Security",
            ["RD_AS_05"] = "Attachment Security",
            ["RD_AS_06_R"] = "Attachment Security",

            // Conflict (RD_CE_XX)
            ["RD_CE_01"] = "Conflict Engagement",
            ["RD_CE_02"] = "Conflict Engagement",
            ["RD_CE_03"] = "Conflict Engagement",
            ["RD_CE_04"] = "Conflict Engagement",
            ["RD_CE_05"] = "Conflict Engagement",
            ["RD_CE_06_R"] = "Conflict Engagement",

            // Expression (RD_EE_XX)
            ["RD_EE_01"] = "Emotional Expression",
            ["RD_EE_02"] = "Emotional Expression",
            ["RD_EE_03"] = "Emotional Expression",
            ["RD_EE_04"] = "Emotional Expression",
            ["RD_EE_05"] = "Emotional Expression",
            ["RD_EE_06_R"] = "Emotional Expression",

            // Love Language (RD_LL_XX)
            ["RD_LL_01"] = "Love Language Alignment",
            ["RD_LL_02"] = "Love Language Alignment",
            ["RD_LL_03"] = "Love Language Alignment",
            ["RD_LL_04"] = "Love Language Alignment",
        };

        // Accumulate raw scores per dimension
        foreach (var answer in answers)
        {
            if (dimensionMap.TryGetValue(answer.QuestionId, out var dim))
            {
                var (raw, count) = dimensions[dim];
                dimensions[dim] = (raw + answer.Value, count + 1);
            }
        }

        // Normalize and classify
        var result = new Dictionary<string, MpiDimensionScore>();
        foreach (var (dimName, (raw, count)) in dimensions)
        {
            if (count == 0)
            {
                // Default to neutral if no questions answered
                result[dimName] = new MpiDimensionScore
                {
                    Percentage = 50.0,
                    DominantPole = DeterminePole(dimName, 50.0),
                    Strength = ClassifyStrength(50.0),
                };
                continue;
            }

            // Normalize: (raw - min) / (max - min) * 100
            // Min = count × 1, Max = count × 5
            var min = count;
            var max = count * 5;
            var pct = ((raw - min) / (double)(max - min)) * 100;

            result[dimName] = new MpiDimensionScore
            {
                Percentage = pct,
                DominantPole = DeterminePole(dimName, pct),
                Strength = ClassifyStrength(pct),
            };
        }

        return result;
    }

    private string DeterminePole(string dimensionName, double percentage)
    {
        return dimensionName switch
        {
            "Attachment Security" => percentage >= 50 ? "Secure" : "Insecure",
            "Conflict Engagement" => percentage >= 50 ? "Engaged" : "Avoidant",
            "Emotional Expression" => percentage >= 50 ? "Transparent" : "Withdrawn",
            "Love Language Alignment" => percentage >= 50 ? "Practical" : "Emotional",
            _ => "Unknown",
        };
    }

    private string ClassifyStrength(double percentage)
    {
        var deviation = Math.Abs(percentage - 50);
        return deviation switch
        {
            <= 10 => "Slight",
            <= 20 => "Moderate",
            <= 35 => "Clear",
            _ => "Strong",
        };
    }

    private string DeriveTypeCode(Dictionary<string, MpiDimensionScore> dimensions)
    {
        // Map poles to code letters
        var poles = new[]
        {
            dimensions["Attachment Security"].DominantPole[0],      // S or I
            dimensions["Conflict Engagement"].DominantPole[0],      // E or A
            dimensions["Emotional Expression"].DominantPole[0],     // T or W
            dimensions["Love Language Alignment"].DominantPole[0],  // P or E
        };

        return new string(poles);
    }

    private PairCompatibilityDto GeneratePairAnalysis(Result user1Result, Result user2Result)
    {
        var user1Type = user1Result.PersonalityType;
        var user2Type = user2Result.PersonalityType;

        // Get compatibility from matrix
        var compatibility = RelationshipPairCompatibilityMatrix.GetCompatibility(user1Type, user2Type);
        var compatScore = compatibility.Compatibility switch
        {
            "High" => 85,
            "Good" => 65,
            _ => 40,
        };

        // Parse dimension scores
        var user1Dims = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(user1Result.DimensionScoresJson) ?? new();
        var user2Dims = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(user2Result.DimensionScoresJson) ?? new();

        var dimensionComparisons = new List<DimensionComparisonDto>();
        var dimensionNames = new[] { "Attachment Security", "Conflict Engagement", "Emotional Expression", "Love Language Alignment" };

        foreach (var dimName in dimensionNames)
        {
            var s1 = user1Dims.TryGetValue(dimName, out var d1) ? (int)d1.GetProperty("percentage").GetDecimal() : 50;
            var s2 = user2Dims.TryGetValue(dimName, out var d2) ? (int)d2.GetProperty("percentage").GetDecimal() : 50;
            var gap = Math.Abs(s1 - s2);

            dimensionComparisons.Add(new DimensionComparisonDto
            {
                DimensionName = dimName,
                Partner1Score = s1,
                Partner2Score = s2,
                Gap = gap,
                GapInterpretation = gap switch
                {
                    < 15 => "You're well-aligned on this. You approach it similarly.",
                    < 30 => "Different but manageable. You complement each other.",
                    _ => "Significant difference. This is a common friction point.",
                },
            });
        }

        // Generate repair scripts (simplified for now; can be expanded)
        var repairScripts = new List<RepairScriptDto>
        {
            new RepairScriptDto
            {
                Situation = "After a disagreement",
                Script = "Take 10 minutes apart to cool down, then come back and focus on understanding each other, not winning.",
            },
            new RepairScriptDto
            {
                Situation = "When one person feels unheard",
                Script = "The listener repeats back what they heard: 'What I'm hearing is... Did I get that right?'",
            },
        };

        return new PairCompatibilityDto
        {
            CompatibilityScore = compatScore,
            CompatibilityLevel = compatibility.Compatibility,
            ConflictCycleRisk = compatibility.RiskNarrative,
            Partner1 = new PairMemberSnapshot { TypeCode = user1Type, TypeName = user1Result.PersonalityName, Emoji = user1Result.PersonalityEmoji },
            Partner2 = new PairMemberSnapshot { TypeCode = user2Type, TypeName = user2Result.PersonalityName, Emoji = user2Result.PersonalityEmoji },
            BlindSpot1 = $"You might not realize: {GetBlindSpot(user1Type, user2Type)}",
            BlindSpot2 = $"You might not realize: {GetBlindSpot(user2Type, user1Type)}",
            RepairScripts = repairScripts,
            SharedGrowthEdge = $"Together, work on: Understanding each other's attachment needs and conflict styles.",
            DimensionComparison = dimensionComparisons,
            ActionableAdvice = $"Your compatibility is {compatibility.Compatibility.ToLower()}. {compatibility.RiskNarrative}",
        };
    }

    private string GetBlindSpot(string myType, string partnerType)
    {
        // Simplified: can be expanded with per-type-pair blind spot library
        return myType[0] == 'S'
            ? "Your partner may not feel as secure as they appear. Check in on their emotional needs."
            : "Your insecurity might be showing up as push or pull. Your partner notices.";
    }
}
