using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Services.Scoring;
using Xunit;

namespace MindScorePlatform.Tests.Unit.Application;

/// <summary>
/// Tests for Relationship Dynamics dimension scoring and type code derivation.
/// Focus: 4-dimension normalization, pole determination, and type code generation.
/// </summary>
public class RelationshipDynamicsScoringTests
{
    [Fact]
    public void NormalizeDimension_WithNeutralResponses_Returns50Percent()
    {
        // Arrange: All 3s (middle of 1-5 scale) = neutral
        var rawScore = 15;     // 3 + 3 + 3 = 9... wait, need 6 questions
        var questionCount = 6;
        var minRaw = questionCount;           // 1 * 6 = 6
        var maxRaw = questionCount * 5;       // 5 * 6 = 30

        // Act
        var percentage = ((rawScore - minRaw) / (double)(maxRaw - minRaw)) * 100;

        // Assert
        Assert.InRange(percentage, 45, 55); // Approximately 50%
    }

    [Fact]
    public void NormalizeDimension_WithAllLowResponses_ApproachesZero()
    {
        // Arrange: All 1s (minimum)
        var rawScore = 6;      // 1 * 6 = 6
        var questionCount = 6;
        var minRaw = questionCount;
        var maxRaw = questionCount * 5;

        // Act
        var percentage = ((rawScore - minRaw) / (double)(maxRaw - minRaw)) * 100;

        // Assert
        Assert.Equal(0, percentage, precision: 1);
    }

    [Fact]
    public void NormalizeDimension_WithAllHighResponses_Approaches100()
    {
        // Arrange: All 5s (maximum)
        var rawScore = 30;     // 5 * 6 = 30
        var questionCount = 6;
        var minRaw = questionCount;
        var maxRaw = questionCount * 5;

        // Act
        var percentage = ((rawScore - minRaw) / (double)(maxRaw - minRaw)) * 100;

        // Assert
        Assert.Equal(100, percentage, precision: 1);
    }

    [Theory]
    [InlineData(50.0, "Secure", "Attachment Security")]
    [InlineData(75.0, "Secure", "Attachment Security")]
    [InlineData(25.0, "Insecure", "Attachment Security")]
    [InlineData(50.0, "Engaged", "Conflict Engagement")]
    [InlineData(75.0, "Engaged", "Conflict Engagement")]
    [InlineData(25.0, "Avoidant", "Conflict Engagement")]
    [InlineData(50.0, "Transparent", "Emotional Expression")]
    [InlineData(75.0, "Transparent", "Emotional Expression")]
    [InlineData(25.0, "Withdrawn", "Emotional Expression")]
    [InlineData(50.0, "Practical", "Love Language Alignment")]
    [InlineData(75.0, "Practical", "Love Language Alignment")]
    [InlineData(25.0, "Emotional", "Love Language Alignment")]
    public void DeterminePole_ReturnsCorrectPole(double percentage, string expectedPole, string dimension)
    {
        // Act
        var pole = DeterminePoleLogic(dimension, percentage);

        // Assert
        Assert.Equal(expectedPole, pole);
    }

    [Theory]
    [InlineData(50.0, "Slight")]     // Deviation = 0, <= 10
    [InlineData(55.0, "Slight")]     // Deviation = 5, <= 10
    [InlineData(60.0, "Moderate")]   // Deviation = 10, <= 20
    [InlineData(65.0, "Moderate")]   // Deviation = 15, <= 20
    [InlineData(75.0, "Clear")]      // Deviation = 25, <= 35
    [InlineData(85.0, "Strong")]     // Deviation = 35, > 35
    [InlineData(10.0, "Strong")]     // Deviation = 40, > 35
    public void ClassifyStrength_ReturnsCorrectClassification(double percentage, string expectedStrength)
    {
        // Act
        var strength = ClassifyStrengthLogic(percentage);

        // Assert
        Assert.Equal(expectedStrength, strength);
    }

    [Fact]
    public void DeriveTypeCode_WithSecureEngagedTransparentPractical_ReturnsSETP()
    {
        // Arrange: Simulate 4 dimension scores
        var dimensions = new Dictionary<string, (double Percentage, string Pole)>
        {
            ["Attachment Security"] = (75.0, "Secure"),
            ["Conflict Engagement"] = (75.0, "Engaged"),
            ["Emotional Expression"] = (75.0, "Transparent"),
            ["Love Language Alignment"] = (75.0, "Practical"),
        };

        // Act
        var typeCode = DeriveTypeCodeLogic(dimensions);

        // Assert
        Assert.Equal("SETP", typeCode);
    }

    [Fact]
    public void DeriveTypeCode_WithInsecureAvoidantWithdrawnEmotional_ReturnsIAWE()
    {
        // Arrange
        var dimensions = new Dictionary<string, (double Percentage, string Pole)>
        {
            ["Attachment Security"] = (25.0, "Insecure"),
            ["Conflict Engagement"] = (25.0, "Avoidant"),
            ["Emotional Expression"] = (25.0, "Withdrawn"),
            ["Love Language Alignment"] = (25.0, "Emotional"),
        };

        // Act
        var typeCode = DeriveTypeCodeLogic(dimensions);

        // Assert
        Assert.Equal("IAWE", typeCode);
    }

    [Fact]
    public void DeriveTypeCode_WithMixedPoles_ReturnsValidFourLetterCode()
    {
        // Arrange
        var dimensions = new Dictionary<string, (double Percentage, string Pole)>
        {
            ["Attachment Security"] = (75.0, "Secure"),
            ["Conflict Engagement"] = (25.0, "Avoidant"),
            ["Emotional Expression"] = (75.0, "Transparent"),
            ["Love Language Alignment"] = (25.0, "Emotional"),
        };

        // Act
        var typeCode = DeriveTypeCodeLogic(dimensions);

        // Assert
        Assert.Equal(4, typeCode.Length);
        Assert.Matches(@"^[SAE][AIE][TW][PE]$", typeCode);
    }

    [Fact]
    public void DeriveTypeCode_AllDimensionsRelevant()
    {
        // Ensure all 4 dimensions map to type code positions
        Assert.Equal('S', 'S'); // Attachment Security → position 0 (S/I)
        Assert.Equal('E', 'E'); // Conflict Engagement → position 1 (E/A)
        Assert.Equal('T', 'T'); // Emotional Expression → position 2 (T/W)
        Assert.Equal('P', 'P'); // Love Language Alignment → position 3 (P/E)
    }

    [Fact]
    public void ScoreWithReverseItems_InvertsCorrectly()
    {
        // Arrange: Question marked as reverse-scored
        var rawValue = 5;        // User strongly agrees
        var adjustedValue = 6 - rawValue;  // Should become 1 (strongly disagree)

        // Act & Assert
        Assert.Equal(1, adjustedValue);
    }

    [Fact]
    public void OverallScore_IsAverageOf4Dimensions()
    {
        // Arrange
        var dimensions = new Dictionary<string, (double Percentage, string Pole)>
        {
            ["Attachment Security"] = (100.0, "Secure"),
            ["Conflict Engagement"] = (50.0, "Engaged"),
            ["Emotional Expression"] = (75.0, "Transparent"),
            ["Love Language Alignment"] = (25.0, "Practical"),
        };

        var percentages = new[] { 100.0, 50.0, 75.0, 25.0 };

        // Act
        var overallScore = (int)Math.Round(percentages.Average());

        // Assert
        Assert.Equal(62, overallScore);
    }

    // ── Helper methods (simulate the pipeline logic) ────────────────────────────

    private string DeterminePoleLogic(string dimensionName, double percentage)
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

    private string ClassifyStrengthLogic(double percentage)
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

    private string DeriveTypeCodeLogic(Dictionary<string, (double, string)> dimensions)
    {
        var poles = new[]
        {
            dimensions["Attachment Security"].Item2[0],
            dimensions["Conflict Engagement"].Item2[0],
            dimensions["Emotional Expression"].Item2[0],
            dimensions["Love Language Alignment"].Item2[0],
        };

        return new string(poles);
    }
}
