using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Tests.Fixtures;
using Xunit;

namespace MindScorePlatform.Tests.Integration;

/// <summary>
/// Integration tests for Relationship Dynamics Assessment data persistence.
/// Tests: Result storage, pair mode detection, context insights storage.
/// </summary>
public class RelationshipDynamicsPipelineIntegrationTests : IAsyncLifetime
{
    private readonly TestDatabaseFixture _fixture = new();

    public async Task InitializeAsync() => await _fixture.InitializeAsync();
    public async Task DisposeAsync() => await _fixture.DisposeAsync();

    [Fact]
    public void RelationshipDynamicsTest_IsSeedDataValid()
    {
        // Act
        var test = _fixture.GetRelationshipDynamicsTest();

        // Assert
        Assert.NotNull(test);
        Assert.Equal("Relationship Dynamics Assessment", test.Name);
    }

    [Fact]
    public void RelationshipDynamicsTest_Has22Questions()
    {
        // Act
        var test = _fixture.GetRelationshipDynamicsTest();
        var questions = _fixture.DbContext.Questions
            .Where(q => q.TestId == test.Id)
            .ToList();

        // Assert
        Assert.Equal(22, questions.Count);
    }

    [Fact]
    public void RelationshipDynamicsQuestions_HaveCorrectDimensions()
    {
        // Act
        var test = _fixture.GetRelationshipDynamicsTest();
        var questions = _fixture.DbContext.Questions
            .Where(q => q.TestId == test.Id)
            .ToList();

        var attachmentSecurityCount = questions.Count(q => q.Code!.StartsWith("RD_AS"));
        var conflictEngagementCount = questions.Count(q => q.Code!.StartsWith("RD_CE"));
        var emotionalExpressionCount = questions.Count(q => q.Code!.StartsWith("RD_EE"));
        var loveLanguageCount = questions.Count(q => q.Code!.StartsWith("RD_LL"));

        // Assert
        Assert.Equal(6, attachmentSecurityCount);
        Assert.Equal(6, conflictEngagementCount);
        Assert.Equal(6, emotionalExpressionCount);
        Assert.Equal(4, loveLanguageCount);
    }

    [Fact]
    public void RelationshipDynamicsQuestions_HaveReverseScorings()
    {
        // Act
        var test = _fixture.GetRelationshipDynamicsTest();
        var reverseScoredQuestions = _fixture.DbContext.Questions
            .Where(q => q.TestId == test.Id && q.IsReverseScored == true)
            .ToList();

        // Assert
        Assert.NotEmpty(reverseScoredQuestions);
        Assert.All(reverseScoredQuestions, q => Assert.True(q.Code!.EndsWith("_R")));
    }

    [Fact]
    public void PairMode_CanDetectMultipleResultsPerTest()
    {
        // Arrange
        var user1 = _fixture.CreateTestUser("user1@test.com");
        var user2 = _fixture.CreateTestUser("user2@test.com");
        var test = _fixture.GetRelationshipDynamicsTest();

        var result1 = _fixture.CreateTestResult(user1.Id, test.Id, "SETP");
        var result2 = _fixture.CreateTestResult(user2.Id, test.Id, "IAWM");

        // Act
        var testResults = _fixture.DbContext.Results
            .Where(r => r.TestId == test.Id)
            .ToList();

        // Assert
        Assert.Equal(2, testResults.Count);
        Assert.Contains(user1.Id, testResults.Select(r => r.UserId));
        Assert.Contains(user2.Id, testResults.Select(r => r.UserId));
    }

    [Fact]
    public void ContextInsights_CanStoreCompatibilityData()
    {
        // Arrange
        var user = _fixture.CreateTestUser();
        var test = _fixture.GetRelationshipDynamicsTest();
        var result = _fixture.CreateTestResult(user.Id, test.Id, "SETP");

        var compatibilityJson = """{"compatibilityScore": 85, "compatibilityLevel": "High"}""";
        result.ContextInsightsJson = compatibilityJson;
        _fixture.DbContext.Results.Update(result);
        _fixture.DbContext.SaveChanges();

        // Act
        var retrieved = _fixture.DbContext.Results.Find(result.Id);

        // Assert
        Assert.NotNull(retrieved);
        Assert.Equal(compatibilityJson, retrieved.ContextInsightsJson);
    }

    [Fact]
    public void TypeCode_Represents4DimensionPoles()
    {
        // Assert: Type code should be 4 letters representing dimension poles
        var validTypeCodes = new[] { "SETP", "IAWM", "SEAM", "IATE" };

        foreach (var typeCode in validTypeCodes)
        {
            Assert.Equal(4, typeCode.Length);
            Assert.Matches(@"^[SAE][AIE][TW][PE]$", typeCode);
        }
    }

    [Fact]
    public void RelationshipDynamicsResult_StoresAllRequiredFields()
    {
        // Arrange
        var user = _fixture.CreateTestUser();
        var test = _fixture.GetRelationshipDynamicsTest();

        // Act
        var result = _fixture.CreateTestResult(user.Id, test.Id, "SETP");

        // Assert
        Assert.NotEqual(Guid.Empty, result.Id);
        Assert.Equal(user.Id, result.UserId);
        Assert.Equal(test.Id, result.TestId);
        Assert.InRange(result.Score, 0, 100);
        Assert.Equal("SETP", result.PersonalityType);
        Assert.NotEmpty(result.PersonalityName);
        Assert.NotEmpty(result.PersonalityEmoji);
        Assert.NotEmpty(result.DimensionScoresJson);
        Assert.NotEmpty(result.InsightsJson);
    }

    [Fact]
    public void MultipleResults_PerUserAndTest_AreSupported()
    {
        // Arrange: Same user, same test, different times
        var user = _fixture.CreateTestUser();
        var test = _fixture.GetRelationshipDynamicsTest();

        var result1 = _fixture.CreateTestResult(user.Id, test.Id, "SETP");
        System.Threading.Thread.Sleep(10);  // Ensure different timestamps
        var result2 = _fixture.CreateTestResult(user.Id, test.Id, "IAWM");

        // Act
        var userResults = _fixture.DbContext.Results
            .Where(r => r.UserId == user.Id && r.TestId == test.Id)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToList();

        // Assert: Latest result should be result2
        Assert.Equal(2, userResults.Count);
        Assert.Equal(result2.Id, userResults.First().Id);
    }
}
