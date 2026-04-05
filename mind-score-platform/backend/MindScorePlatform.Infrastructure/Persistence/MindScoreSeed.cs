using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Runtime seed for MindScore assessment data.
/// Called from Program.cs after db.Database.Migrate().
/// Idempotent — skips if questions already exist for the MindScore test.
/// </summary>
public static class MindScoreSeed
{
    internal static readonly Guid TestId = new("a1000000-0000-0000-0000-000000000001");

    /// <summary>Module definitions — deterministic GUIDs so re-seeding is safe.</summary>
    private static readonly (Guid id, string name, int order)[] ModuleDefs =
    [
        (new Guid("b1000000-0000-0000-0000-000000000001"), "Cognitive",  1),
        (new Guid("b1000000-0000-0000-0000-000000000002"), "Emotional",  2),
        (new Guid("b1000000-0000-0000-0000-000000000003"), "Focus",      3),
        (new Guid("b1000000-0000-0000-0000-000000000004"), "Decision",   4),
        (new Guid("b1000000-0000-0000-0000-000000000005"), "Resilience", 5),
    ];

    /// <summary>Age band definitions — deterministic GUIDs so re-seeding is safe.</summary>
    private static readonly (Guid id, string name, int min, int max, int order)[] AgeBandDefs =
    [
        (new Guid("c1000000-0000-0000-0000-000000000001"), "Child (6-12)",          6,  12, 1),
        (new Guid("c1000000-0000-0000-0000-000000000002"), "Teen (13-17)",          13, 17, 2),
        (new Guid("c1000000-0000-0000-0000-000000000003"), "Young Adult (18-24)",   18, 24, 3),
        (new Guid("c1000000-0000-0000-0000-000000000004"), "Adult (25-44)",         25, 44, 4),
        (new Guid("c1000000-0000-0000-0000-000000000005"), "Mature Adult (45-59)",  45, 59, 5),
        (new Guid("c1000000-0000-0000-0000-000000000006"), "Senior Adult (60+)",    60, 99, 6),
    ];

    // ── Per-module questions (6 per module, all neutral to age band) ──────────

    private static readonly (string code, string text, bool reverse)[] CognitiveQuestions =
    [
        ("COG_01",   "I can switch between tasks quickly without losing focus.",              false),
        ("COG_02",   "I often spot patterns or connections others seem to miss.",             false),
        ("COG_03_R", "I find it hard to organise my thoughts when under pressure.",          true),
        ("COG_04",   "I enjoy solving complex problems that require sustained thinking.",     false),
        ("COG_05_R", "I tend to overlook details when I am working quickly.",                true),
        ("COG_06",   "I can hold several pieces of information in mind at once.",            false),
    ];

    private static readonly (string code, string text, bool reverse)[] EmotionalQuestions =
    [
        ("EMO_01",   "I can identify what I am feeling even when it is difficult to name.",  false),
        ("EMO_02",   "I stay calm and composed when people around me are stressed.",         false),
        ("EMO_03_R", "I sometimes act on strong emotions before thinking things through.",   true),
        ("EMO_04",   "I can empathise with others even when I disagree with them.",          false),
        ("EMO_05_R", "I find it hard to bounce back quickly after being upset.",             true),
        ("EMO_06",   "I am aware of how my mood affects the people around me.",             false),
    ];

    private static readonly (string code, string text, bool reverse)[] FocusQuestions =
    [
        ("FOC_01",   "I can maintain deep concentration for extended periods.",              false),
        ("FOC_02",   "I notice when my mind has wandered and quickly refocus.",              false),
        ("FOC_03_R", "I am easily distracted by background noise or activity.",              true),
        ("FOC_04",   "I can work effectively in busy or unpredictable environments.",        false),
        ("FOC_05_R", "I often find myself doing one thing while thinking about another.",    true),
        ("FOC_06",   "I finish tasks without needing to restart due to loss of focus.",      false),
    ];

    private static readonly (string code, string text, bool reverse)[] DecisionQuestions =
    [
        ("DEC_01",   "I weigh pros and cons carefully before making important decisions.",   false),
        ("DEC_02",   "I feel comfortable making decisions with incomplete information.",     false),
        ("DEC_03_R", "I often second-guess decisions I have already made.",                  true),
        ("DEC_04",   "I can commit to a course of action and follow through consistently.",  false),
        ("DEC_05_R", "I find it hard to decide when several options seem equally valid.",    true),
        ("DEC_06",   "My decisions tend to align well with my long-term goals.",            false),
    ];

    private static readonly (string code, string text, bool reverse)[] ResilienceQuestions =
    [
        ("RES_01",   "I recover from setbacks without dwelling on them for long.",           false),
        ("RES_02",   "I see challenges as opportunities to learn and grow.",                 false),
        ("RES_03_R", "Stressful situations leave me feeling drained for days.",              true),
        ("RES_04",   "I maintain a sense of purpose even when things go wrong.",             false),
        ("RES_05_R", "I tend to catastrophise when faced with uncertainty.",                 true),
        ("RES_06",   "I adapt my approach when my original plan is not working.",            false),
    ];

    // ── Weights per age band (sums to 1.0 per band) ───────────────────────────
    // Order: Cognitive, Emotional, Focus, Decision, Resilience

    private static readonly double[][] WeightsByAgeBand =
    [
        /* Child (6-12)         */ [0.25, 0.20, 0.25, 0.15, 0.15],
        /* Teen (13-17)         */ [0.25, 0.20, 0.20, 0.15, 0.20],
        /* Young Adult (18-24)  */ [0.20, 0.20, 0.20, 0.20, 0.20],
        /* Adult (25-44)        */ [0.20, 0.20, 0.15, 0.25, 0.20],
        /* Mature Adult (45-59) */ [0.20, 0.25, 0.15, 0.20, 0.20],
        /* Senior Adult (60+)   */ [0.15, 0.25, 0.20, 0.20, 0.20],
    ];

    public static async Task SeedAsync(AppDbContext db)
    {
        var now = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        // ── Seed modules if missing ───────────────────────────────────────────
        var existingModuleIds = await db.Modules.Select(m => m.Id).ToListAsync();
        foreach (var (id, name, order) in ModuleDefs)
        {
            if (!existingModuleIds.Contains(id))
            {
                db.Modules.Add(new Module { Id = id, Name = name, DisplayOrder = order, IsActive = true, CreatedAt = now });
            }
        }
        await db.SaveChangesAsync();

        // ── Seed age bands if missing ─────────────────────────────────────────
        var existingAgeBandIds = await db.AgeBands.Select(a => a.Id).ToListAsync();
        foreach (var (id, name, min, max, order) in AgeBandDefs)
        {
            if (!existingAgeBandIds.Contains(id))
            {
                db.AgeBands.Add(new AgeBand { Id = id, Name = name, MinAge = min, MaxAge = max, DisplayOrder = order, IsActive = true, CreatedAt = now });
            }
        }
        await db.SaveChangesAsync();

        // ── Ensure the MindScore test row exists ──────────────────────────────
        var testExists = await db.Tests.AnyAsync(t => t.Id == TestId);
        if (!testExists)
        {
            db.Tests.Add(new Test
            {
                Id = TestId,
                Name = "MindScore Assessment",
                CreatedAtUtc = now,
            });
            await db.SaveChangesAsync();
        }

        // Skip if questions already seeded
        var alreadySeeded = await db.Questions.AnyAsync(q => q.TestId == TestId);
        if (alreadySeeded) return;

        // Build lookup maps from the deterministic IDs
        var modules = ModuleDefs.ToDictionary(m => m.name, m => m.id);
        var ageBandList = AgeBandDefs.Select(a => (a.id, a.order)).ToList();

        var questions = new List<Question>();
        var normRefs = new List<NormReference>();
        var weights = new List<AgeBandModuleWeight>();

        var moduleData = new (string name, (string code, string text, bool reverse)[] qs)[]
        {
            ("Cognitive",  CognitiveQuestions),
            ("Emotional",  EmotionalQuestions),
            ("Focus",      FocusQuestions),
            ("Decision",   DecisionQuestions),
            ("Resilience", ResilienceQuestions),
        };

        int globalOrder = 1;

        for (int mi = 0; mi < moduleData.Length; mi++)
        {
            var (moduleName, qs) = moduleData[mi];
            var moduleId = modules[moduleName];

            for (int qi = 0; qi < qs.Length; qi++)
            {
                var (code, text, reverse) = qs[qi];

                // One question row per age band (6 × 5 = 30 questions per module → 180 total)
                foreach (var ab in ageBandList)
                {
                    questions.Add(new Question
                    {
                        Id = Guid.NewGuid(),
                        TestId = TestId,
                        Code = $"{code}_AB{ab.order}",
                        Order = globalOrder++,
                        Text = text,
                        ModuleId = moduleId,
                        AgeBandId = ab.id,
                        IsReverseScored = reverse,
                        Weight = 1.0m,
                        Version = 1,
                        CreatedAtUtc = now,
                    });
                }
            }

            // Norm references: one per module × age band (mean=50, sd=15, n=100)
            foreach (var ab in ageBandList)
            {
                normRefs.Add(new NormReference
                {
                    Id = Guid.NewGuid(),
                    ModuleId = moduleId,
                    AgeBandId = ab.id,
                    Mean = 50.0,
                    StandardDeviation = 15.0,
                    SampleSize = 100,
                    CreatedAt = now,
                });
            }

            // Age-band module weights
            for (int abi = 0; abi < ageBandList.Count; abi++)
            {
                weights.Add(new AgeBandModuleWeight
                {
                    Id = Guid.NewGuid(),
                    AgeBandId = ageBandList[abi].id,
                    ModuleId = moduleId,
                    Weight = WeightsByAgeBand[abi][mi],
                    CreatedAt = now,
                });
            }
        }

        db.Questions.AddRange(questions);
        db.NormReferences.AddRange(normRefs);
        db.AgeBandModuleWeights.AddRange(weights);
        await db.SaveChangesAsync();
    }
}
