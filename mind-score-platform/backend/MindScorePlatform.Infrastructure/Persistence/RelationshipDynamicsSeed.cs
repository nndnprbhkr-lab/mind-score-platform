using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Seed data for Relationship Dynamics Assessment.
/// Standalone assessment with 4 dimensions: Attachment Security, Conflict Engagement, Emotional Expression, Love Language Alignment.
/// 22 Likert-scale questions (1-5 scale), with reverse-scored items.
/// Test GUID: 00000000-0000-0000-0000-000000000004
/// Question GUID range: 00000000-0000-0000-0004-XXXXXXXXXXXX (001–022)
/// </summary>
internal static class RelationshipDynamicsSeed
{
    internal static readonly Test Test = new()
    {
        Id = new Guid("00000000-0000-0000-0000-000000000004"),
        Name = "Relationship Dynamics Assessment",
        CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
    };

    internal static readonly List<Question> Questions =
    [
        // ATTACHMENT SECURITY DIMENSION (RD_AS_01 – RD_AS_06)
        // Measures: comfort with intimacy, fear of abandonment, autonomy comfort, conflict resilience
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000001"),
            TestId = Test.Id,
            Code = "RD_AS_01",
            Text = "I feel anxious when my partner needs space or time alone.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 1,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000002"),
            TestId = Test.Id,
            Code = "RD_AS_02",
            Text = "I feel secure and stable in my relationships.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 2,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000003"),
            TestId = Test.Id,
            Code = "RD_AS_03",
            Text = "I worry that my partner will leave me.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 3,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000004"),
            TestId = Test.Id,
            Code = "RD_AS_04",
            Text = "I am comfortable being independent in my relationship.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 4,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000005"),
            TestId = Test.Id,
            Code = "RD_AS_05",
            Text = "I need constant reassurance from my partner to feel loved.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 5,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000006"),
            TestId = Test.Id,
            Code = "RD_AS_06_R",
            Text = "I can handle disagreement without feeling the relationship is threatened.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            Order = 6,
            AgeBandId = null,
            ContextTagsJson = null,
        },

        // CONFLICT ENGAGEMENT DIMENSION (RD_CE_01 – RD_CE_06)
        // Measures: how they approach disagreement, avoidance tendency, collaboration ability
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000007"),
            TestId = Test.Id,
            Code = "RD_CE_01",
            Text = "I avoid bringing up problems because I fear conflict.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 7,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000008"),
            TestId = Test.Id,
            Code = "RD_CE_02",
            Text = "I bring up problems directly, even if it might upset my partner.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 8,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000009"),
            TestId = Test.Id,
            Code = "RD_CE_03",
            Text = "In disagreements, I try to find solutions that work for both of us.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 9,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000010"),
            TestId = Test.Id,
            Code = "RD_CE_04",
            Text = "When my partner and I disagree, I withdraw and go quiet.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 10,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000011"),
            TestId = Test.Id,
            Code = "RD_CE_05",
            Text = "I need to win arguments rather than find common ground.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 11,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000012"),
            TestId = Test.Id,
            Code = "RD_CE_06_R",
            Text = "My partner and I can discuss disagreements calmly without it becoming heated.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            Order = 12,
            AgeBandId = null,
            ContextTagsJson = null,
        },

        // EMOTIONAL EXPRESSION DIMENSION (RD_EE_01 – RD_EE_06)
        // Measures: vulnerability, sharing feelings, emotional openness, defensiveness
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000013"),
            TestId = Test.Id,
            Code = "RD_EE_01",
            Text = "I find it hard to talk about my feelings with my partner.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 13,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000014"),
            TestId = Test.Id,
            Code = "RD_EE_02",
            Text = "I can be vulnerable and open about my insecurities with my partner.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 14,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000015"),
            TestId = Test.Id,
            Code = "RD_EE_03",
            Text = "When hurt, I tend to explain why I'm right rather than express how I feel.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 15,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000016"),
            TestId = Test.Id,
            Code = "RD_EE_04",
            Text = "I share my needs and boundaries clearly with my partner.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 16,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000017"),
            TestId = Test.Id,
            Code = "RD_EE_05",
            Text = "I keep my real emotions hidden from my partner to avoid burdening them.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 17,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000018"),
            TestId = Test.Id,
            Code = "RD_EE_06_R",
            Text = "My partner knows who I really am, not just what I show on the surface.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            Order = 18,
            AgeBandId = null,
            ContextTagsJson = null,
        },

        // LOVE LANGUAGE ALIGNMENT DIMENSION (RD_LL_01 – RD_LL_04)
        // Measures: preference for different expressions of love (Acts of Service, Quality Time, Words, Physical, Gifts)
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000019"),
            TestId = Test.Id,
            Code = "RD_LL_01",
            Text = "I feel most loved when my partner helps me with practical tasks.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 19,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000020"),
            TestId = Test.Id,
            Code = "RD_LL_02",
            Text = "I need to hear words of affection and appreciation from my partner.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 20,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000021"),
            TestId = Test.Id,
            Code = "RD_LL_03",
            Text = "Quality time together, just being present, is what makes me feel connected.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 21,
            AgeBandId = null,
            ContextTagsJson = null,
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0004-000000000022"),
            TestId = Test.Id,
            Code = "RD_LL_04",
            Text = "Physical affection and touch are essential to me feeling loved.",
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Order = 22,
            AgeBandId = null,
            ContextTagsJson = null,
        },
    ];
}
