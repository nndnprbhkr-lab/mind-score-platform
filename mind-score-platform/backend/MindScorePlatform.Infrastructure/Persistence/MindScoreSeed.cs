using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Runtime seed for MindScore assessment data.
/// Called from Program.cs after db.Database.Migrate().
/// Uses whatever UUIDs already exist in agebands/modules tables (no hardcoded IDs).
/// Re-seeds questions whenever their AgeBandIds no longer match the current agebands table.
/// </summary>
public static class MindScoreSeed
{
    internal static readonly Guid TestId = new("a1000000-0000-0000-0000-000000000001");

    /// <summary>Module names and display order only — no hardcoded UUIDs.</summary>
    private static readonly (string name, int order)[] ModuleNames =
    [
        ("Cognitive",  1),
        ("Emotional",  2),
        ("Focus",      3),
        ("Decision",   4),
        ("Resilience", 5),
    ];

    /// <summary>Age band definitions — names/ranges only, no hardcoded UUIDs.</summary>
    private static readonly (string name, int min, int max, int order)[] AgeBandRanges =
    [
        ("Child (6-12)",         6,  12, 1),
        ("Teen (13-17)",        13,  17, 2),
        ("Young Adult (18-24)", 18,  24, 3),
        ("Adult (25-44)",       25,  44, 4),
        ("Mature Adult (45-59)",45,  59, 5),
        ("Senior Adult (60+)",  60,  99, 6),
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
        var now = DateTime.UtcNow;

        // ── Ensure schema columns exist (idempotent) ──────────────────────────
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS dateofbirth timestamp with time zone;");
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS domicile text;");
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS agebandid uuid;");

        // ── Ensure MindScore tables exist (migration was left empty) ──────────
        await db.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS normreferences (
                id uuid PRIMARY KEY,
                moduleid uuid NOT NULL REFERENCES modules(id),
                agebandid uuid NOT NULL REFERENCES agebands(id),
                mean double precision NOT NULL,
                standarddeviation double precision NOT NULL,
                samplesize integer NOT NULL,
                createdat timestamp with time zone NOT NULL
            );");
        await db.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS agebandmoduleweights (
                id uuid PRIMARY KEY,
                agebandid uuid NOT NULL REFERENCES agebands(id),
                moduleid uuid NOT NULL REFERENCES modules(id),
                weight double precision NOT NULL,
                createdat timestamp with time zone NOT NULL
            );");

        // ── Modules: insert by name if missing, then read actual IDs ─────────
        var moduleNameSet = ModuleNames.Select(m => m.name).ToHashSet();
        var existingModuleNames = await db.Modules
            .Where(m => moduleNameSet.Contains(m.Name))
            .Select(m => m.Name)
            .ToListAsync();
        foreach (var (name, order) in ModuleNames)
        {
            if (!existingModuleNames.Contains(name))
                db.Modules.Add(new Module { Id = Guid.NewGuid(), Name = name, DisplayOrder = order, IsActive = true, CreatedAt = now });
        }
        await db.SaveChangesAsync();

        var moduleIdByName = await db.Modules
            .Where(m => moduleNameSet.Contains(m.Name))
            .ToDictionaryAsync(m => m.Name, m => m.Id);

        // ── Age bands: deduplicate by (MinAge, MaxAge), keep oldest per range ─
        // Remove all but the oldest row for each (minage, maxage) pair.
        await db.Database.ExecuteSqlRawAsync(@"
            DELETE FROM agebands
            WHERE id IN (
                SELECT id FROM (
                    SELECT id,
                           ROW_NUMBER() OVER (
                               PARTITION BY minage, maxage
                               ORDER BY createdat ASC NULLS LAST, id ASC
                           ) AS rn
                    FROM agebands
                ) ranked
                WHERE rn > 1
            );");

        // Migrate any users that pointed at a deleted duplicate to the surviving row.
        await db.Database.ExecuteSqlRawAsync(@"
            UPDATE users u
            SET agebandid = survivor.id
            FROM (
                SELECT DISTINCT ON (minage, maxage) id, minage, maxage
                FROM agebands
                ORDER BY minage, maxage, createdat ASC NULLS LAST, id ASC
            ) survivor
            WHERE u.agebandid IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM agebands ab WHERE ab.id = u.agebandid);");

        // Insert any age band ranges that are still missing after deduplication.
        for (int i = 0; i < AgeBandRanges.Length; i++)
        {
            var (name, min, max, order) = AgeBandRanges[i];
            if (!await db.AgeBands.AnyAsync(a => a.MinAge == min && a.MaxAge == max))
                db.AgeBands.Add(new AgeBand { Id = Guid.NewGuid(), Name = name, MinAge = min, MaxAge = max, DisplayOrder = order, IsActive = true, CreatedAt = now });
        }
        await db.SaveChangesAsync();

        // Read the single surviving ID for each age band range.
        var ageBandIds = new Guid[AgeBandRanges.Length];
        for (int i = 0; i < AgeBandRanges.Length; i++)
        {
            var (_, min, max, _) = AgeBandRanges[i];
            ageBandIds[i] = await db.AgeBands
                .Where(a => a.MinAge == min && a.MaxAge == max)
                .Select(a => a.Id)
                .FirstAsync();
        }

        // ── MindScore test row ────────────────────────────────────────────────
        if (!await db.Tests.AnyAsync(t => t.Id == TestId))
        {
            db.Tests.Add(new Test { Id = TestId, Name = "MindScore Assessment", CreatedAtUtc = now });
            await db.SaveChangesAsync();
        }

        // ── Questions: re-seed whenever AgeBandIds are stale ─────────────────
        var validAgeBandIdSet = ageBandIds.ToHashSet();
        var existingQuestions = await db.Questions.Where(q => q.TestId == TestId).ToListAsync();
        bool questionsValid = existingQuestions.Count > 0
            && existingQuestions.All(q => q.AgeBandId.HasValue && validAgeBandIdSet.Contains(q.AgeBandId.Value));

        if (questionsValid) return;

        // Remove stale questions and all norm refs / weights (they reference the old IDs).
        if (existingQuestions.Count > 0)
        {
            db.Questions.RemoveRange(existingQuestions);
            await db.Database.ExecuteSqlRawAsync("DELETE FROM normreferences;");
            await db.Database.ExecuteSqlRawAsync("DELETE FROM agebandmoduleweights;");
            await db.SaveChangesAsync();
        }

        var moduleData = new (string name, (string code, string text, bool reverse)[] qs)[]
        {
            ("Cognitive",  CognitiveQuestions),
            ("Emotional",  EmotionalQuestions),
            ("Focus",      FocusQuestions),
            ("Decision",   DecisionQuestions),
            ("Resilience", ResilienceQuestions),
        };

        var questions = new List<Question>();
        var normRefs  = new List<NormReference>();
        var weights   = new List<AgeBandModuleWeight>();
        int globalOrder = 1;

        for (int mi = 0; mi < moduleData.Length; mi++)
        {
            var (moduleName, qs) = moduleData[mi];
            var moduleId = moduleIdByName[moduleName];

            for (int qi = 0; qi < qs.Length; qi++)
            {
                var (code, text, reverse) = qs[qi];

                for (int abi = 0; abi < ageBandIds.Length; abi++)
                {
                    questions.Add(new Question
                    {
                        Id             = Guid.NewGuid(),
                        TestId         = TestId,
                        Code           = $"{code}_AB{abi + 1}",
                        Order          = globalOrder++,
                        Text           = text,
                        ModuleId       = moduleId,
                        AgeBandId      = ageBandIds[abi],
                        IsReverseScored = reverse,
                        Weight         = 1.0m,
                        Version        = 1,
                        CreatedAtUtc   = now,
                    });
                }
            }

            foreach (var abId in ageBandIds)
            {
                normRefs.Add(new NormReference
                {
                    Id                = Guid.NewGuid(),
                    ModuleId          = moduleId,
                    AgeBandId         = abId,
                    Mean              = 50.0,
                    StandardDeviation = 15.0,
                    SampleSize        = 100,
                    CreatedAt         = now,
                });
            }

            for (int abi = 0; abi < ageBandIds.Length; abi++)
            {
                weights.Add(new AgeBandModuleWeight
                {
                    Id        = Guid.NewGuid(),
                    AgeBandId = ageBandIds[abi],
                    ModuleId  = moduleId,
                    Weight    = WeightsByAgeBand[abi][mi],
                    CreatedAt = now,
                });
            }
        }

        db.Questions.AddRange(questions);
        await db.SaveChangesAsync();

        db.NormReferences.AddRange(normRefs);
        db.AgeBandModuleWeights.AddRange(weights);
        await db.SaveChangesAsync();
    }
}
