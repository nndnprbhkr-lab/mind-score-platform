using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using Xunit;

namespace MindScorePlatform.Tests.Unit.Domain;

public class ResultTests
{
    [Fact]
    public void Result_HasValidScoreRange()
    {
        // Arrange
        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            TestId = Guid.NewGuid(),
            Score = 75.5m
        };

        // Act & Assert
        Assert.InRange(result.Score, 0m, 100m);
    }

    [Fact]
    public void Result_StoresPersonalityTypeCode()
    {
        // Arrange & Act
        var result = new Result
        {
            PersonalityType = "EOLS"
        };

        // Assert
        Assert.Equal("EOLS", result.PersonalityType);
    }

    [Theory]
    [InlineData("The Strategist")]
    [InlineData("The Analyst")]
    [InlineData("The Innovator")]
    public void Result_StoresPersonalityName(string name)
    {
        // Arrange & Act
        var result = new Result { PersonalityName = name };

        // Assert
        Assert.Equal(name, result.PersonalityName);
    }

    [Theory]
    [InlineData("🎯")]
    [InlineData("🧠")]
    [InlineData("✨")]
    public void Result_StoresPersonalityEmoji(string emoji)
    {
        // Arrange & Act
        var result = new Result { PersonalityEmoji = emoji };

        // Assert
        Assert.Equal(emoji, result.PersonalityEmoji);
    }

    [Fact]
    public void Result_StoresJsonSerializedData()
    {
        // Arrange
        var json = """{"EnergySource": 75, "PerceptionMode": 60}""";

        // Act
        var result = new Result { DimensionScoresJson = json };

        // Assert
        Assert.Equal(json, result.DimensionScoresJson);
    }

    [Fact]
    public void Result_DefaultContext_IsGeneral()
    {
        // Arrange & Act
        var result = new Result();

        // Assert
        Assert.Equal(AssessmentContext.General, result.Context);
    }

    [Fact]
    public void Result_CanSetAssessmentContext()
    {
        // Arrange & Act
        var result = new Result { Context = AssessmentContext.Career };

        // Assert
        Assert.Equal(AssessmentContext.Career, result.Context);
    }

    [Fact]
    public void Result_CanStorePairCompatibilityInsights()
    {
        // Arrange
        var compatibilityJson = """{"compatibilityScore": 85, "level": "High"}""";

        // Act
        var result = new Result { ContextInsightsJson = compatibilityJson };

        // Assert
        Assert.Equal(compatibilityJson, result.ContextInsightsJson);
    }

    [Fact]
    public void Result_TracksCreatedAtUtc()
    {
        // Arrange
        var now = DateTime.UtcNow;

        // Act
        var result = new Result { CreatedAtUtc = now };

        // Assert
        Assert.Equal(now, result.CreatedAtUtc);
    }

    [Fact]
    public void Result_CanStoreAdaptivePathJson()
    {
        // Arrange
        var pathJson = """["q1-uuid", "q2-uuid", "q3-uuid"]""";

        // Act
        var result = new Result { AdaptivePathJson = pathJson };

        // Assert
        Assert.Equal(pathJson, result.AdaptivePathJson);
    }

    [Fact]
    public void Result_CanStoreAiFollowUpJson()
    {
        // Arrange
        var followUpJson = """{"tensions": ["High Agreeableness vs High Assertiveness"], "questions": []}""";

        // Act
        var result = new Result { AiFollowUpJson = followUpJson };

        // Assert
        Assert.Equal(followUpJson, result.AiFollowUpJson);
    }

    [Fact]
    public void Result_CanStoreDimensionConfidenceJson()
    {
        // Arrange
        var confidenceJson = """{"EnergySource": 87, "PerceptionMode": 43}""";

        // Act
        var result = new Result { DimensionConfidenceJson = confidenceJson };

        // Assert
        Assert.Equal(confidenceJson, result.DimensionConfidenceJson);
    }
}
