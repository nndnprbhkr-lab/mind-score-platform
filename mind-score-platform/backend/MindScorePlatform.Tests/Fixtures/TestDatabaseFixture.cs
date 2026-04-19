using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Infrastructure.Persistence;
using Xunit;

namespace MindScorePlatform.Tests.Fixtures;

/// <summary>
/// Provides an in-memory database context for integration testing.
/// Seeds minimal test data (test definitions, questions).
/// </summary>
public class TestDatabaseFixture : IAsyncLifetime
{
    private readonly DbContextOptions<AppDbContext> _options;
    public AppDbContext DbContext { get; private set; } = null!;

    public TestDatabaseFixture()
    {
        _options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: $"TestDb_{Guid.NewGuid()}")
            .Options;
    }

    public async Task InitializeAsync()
    {
        DbContext = new AppDbContext(_options);
        await DbContext.Database.EnsureCreatedAsync();
        await SeedTestDataAsync();
    }

    public async Task DisposeAsync()
    {
        await DbContext.DisposeAsync();
    }

    private async Task SeedTestDataAsync()
    {
        // Seed MPI Test
        var mpiTestId = Guid.Parse("00000000-0000-0000-0000-000000000001");
        if (!DbContext.Tests.Any(t => t.Id == mpiTestId))
        {
            DbContext.Tests.Add(new Test
            {
                Id = mpiTestId,
                Name = "MindType Profile Inventory",
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        // Seed Relationship Dynamics Test
        var rdTestId = Guid.Parse("00000000-0000-0000-0000-000000000004");
        if (!DbContext.Tests.Any(t => t.Id == rdTestId))
        {
            DbContext.Tests.Add(new Test
            {
                Id = rdTestId,
                Name = "Relationship Dynamics Assessment",
                CreatedAtUtc = DateTime.UtcNow,
            });

            // Seed Relationship Dynamics Questions (22 total)
            var questions = new List<Question>
            {
                // Attachment Security (6 questions)
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_01", Text = "I feel secure in my relationships", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 1, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_02", Text = "I worry about abandonment", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 2, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_03", Text = "I trust my partner completely", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 3, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_04", Text = "I feel anxious when apart from my partner", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 4, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_05", Text = "My partner's emotions affect mine deeply", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 5, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_AS_06_R", Text = "I prefer to handle problems alone", QuestionType = QuestionType.Likert, IsReverseScored = true, Order = 6, CreatedAtUtc = DateTime.UtcNow },

                // Conflict Engagement (6 questions)
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_01", Text = "I address conflicts head-on", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 7, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_02", Text = "I seek to understand my partner's perspective", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 8, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_03", Text = "I enjoy healthy debate with my partner", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 9, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_04", Text = "I see conflict as an opportunity to connect", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 10, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_05", Text = "I negotiate to find win-win solutions", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 11, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_CE_06_R", Text = "I avoid arguments to keep the peace", QuestionType = QuestionType.Likert, IsReverseScored = true, Order = 12, CreatedAtUtc = DateTime.UtcNow },

                // Emotional Expression (6 questions)
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_01", Text = "I share my feelings openly with my partner", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 13, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_02", Text = "I find it easy to be vulnerable", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 14, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_03", Text = "I express affection regularly", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 15, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_04", Text = "I tell my partner what they mean to me", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 16, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_05", Text = "I am comfortable with emotional intimacy", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 17, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_EE_06_R", Text = "I keep my emotions private", QuestionType = QuestionType.Likert, IsReverseScored = true, Order = 18, CreatedAtUtc = DateTime.UtcNow },

                // Love Language Alignment (4 questions)
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_LL_01", Text = "I show love through acts of service", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 19, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_LL_02", Text = "I express love with words of affirmation", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 20, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_LL_03", Text = "Physical touch is important for intimacy", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 21, CreatedAtUtc = DateTime.UtcNow },
                new() { Id = Guid.NewGuid(), TestId = rdTestId, Code = "RD_LL_04", Text = "I appreciate gifts as expressions of love", QuestionType = QuestionType.Likert, IsReverseScored = false, Order = 22, CreatedAtUtc = DateTime.UtcNow },
            };

            DbContext.Questions.AddRange(questions);
        }

        await DbContext.SaveChangesAsync();
    }

    public Test GetMpiTest() => DbContext.Tests.FirstOrDefault(t => t.Name.Contains("MindType")) ?? DbContext.Tests.First(t => t.Name == "MindType Assessment");

    public Test GetRelationshipDynamicsTest() => DbContext.Tests.FirstOrDefault(t => t.Name == "Relationship Dynamics Assessment") ?? DbContext.Tests.First(t => t.Name.Contains("Relationship"));

    public User CreateTestUser(string email = "test@example.com", string name = "Test User")
    {
        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            Name = name,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!"),
            IsGuest = false,
            CreatedAtUtc = DateTime.UtcNow,
        };
        DbContext.Users.Add(user);
        DbContext.SaveChanges();
        return user;
    }

    public Result CreateTestResult(Guid userId, Guid testId, string typeCode = "SETP")
    {
        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = testId,
            Score = 75,
            PersonalityType = typeCode,
            PersonalityName = "Test Type",
            PersonalityEmoji = "🎯",
            PersonalityTagline = "Test tagline",
            DimensionScoresJson = """{"Attachment Security": {"percentage": 75, "dominantPole": "Secure"}}""",
            InsightsJson = """{"emotionalNeeds": ["Connection"]}""",
            Context = AssessmentContext.General,
            CreatedAtUtc = DateTime.UtcNow,
        };
        DbContext.Results.Add(result);
        DbContext.SaveChanges();
        return result;
    }
}
