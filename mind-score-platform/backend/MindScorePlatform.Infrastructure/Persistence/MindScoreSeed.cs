using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Runtime seed for MindScore assessment data.
/// Called from Program.cs after db.Database.Migrate().
/// All primary keys use Guid.NewGuid() — no deterministic UUIDs.
/// Seed guard skips re-seeding when data is already consistent.
/// </summary>
public static class MindScoreSeed
{
    private const string MindScoreTestName = "MindScore Assessment";

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

        // ── Schema guards (idempotent) ────────────────────────────────────────
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS dateofbirth date;");
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS domicile text;");
        await db.Database.ExecuteSqlRawAsync(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS agebandid uuid;");

        // ── Ensure auxiliary tables exist (no-op if already present) ─────────
        await db.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS normreferences (
                id uuid PRIMARY KEY,
                moduleid uuid REFERENCES modules(id),
                agebandid uuid REFERENCES agebands(id),
                mean double precision,
                standarddeviation double precision,
                samplesize integer,
                createdat timestamp without time zone DEFAULT now()
            );");
        await db.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS agebandmoduleweights (
                id uuid PRIMARY KEY,
                agebandid uuid REFERENCES agebands(id),
                moduleid uuid REFERENCES modules(id),
                weight double precision,
                createdat timestamp without time zone DEFAULT now()
            );");

        // ── Seed guard: skip entirely if data is already consistent ─────────
        var expectedModuleNames = ModuleNames.Select(m => m.name).ToList();
        var existingModules     = await db.Modules
            .Where(m => expectedModuleNames.Contains(m.Name))
            .ToListAsync();

        if (existingModules.Count == ModuleNames.Length)
        {
            var existingBands = await db.AgeBands.ToListAsync();
            bool bandsOk = AgeBandRanges.All(r =>
                existingBands.Any(b => b.MinAge == r.min && b.MaxAge == r.max));

            if (bandsOk)
            {
                var testRow = await db.Tests
                    .FirstOrDefaultAsync(t => t.Name == MindScoreTestName);

                if (testRow != null)
                {
                    int expectedQCount = ModuleNames.Length
                        * CognitiveQuestions.Length
                        * AgeBandRanges.Length;
                    int qCount = await db.Questions
                        .CountAsync(q => q.TestId == testRow.Id);

                    if (qCount == expectedQCount)
                    {
                        var validAbIds  = existingBands
                            .Where(b => AgeBandRanges.Any(r => r.min == b.MinAge && r.max == b.MaxAge))
                            .Select(b => b.Id)
                            .ToList();
                        var validModIds = existingModules.Select(m => m.Id).ToList();

                        bool allValid = !await db.Questions
                            .Where(q => q.TestId == testRow.Id)
                            .AnyAsync(q =>
                                !q.AgeBandId.HasValue || !validAbIds.Contains(q.AgeBandId.Value) ||
                                !q.ModuleId.HasValue  || !validModIds.Contains(q.ModuleId.Value));

                        if (allValid) return;
                    }
                }
            }
        }

        // ── Truncate in FK-safe order ────────────────────────────────────────
        await db.Database.ExecuteSqlRawAsync("DELETE FROM normreferences;");
        await db.Database.ExecuteSqlRawAsync("DELETE FROM agebandmoduleweights;");
        await db.Database.ExecuteSqlRawAsync("DELETE FROM modulescores;");
        await db.Database.ExecuteSqlRawAsync(
            $"DELETE FROM questions WHERE testid = (SELECT id FROM tests WHERE name = '{MindScoreTestName}');");
        await db.Database.ExecuteSqlRawAsync(
            $"DELETE FROM tests WHERE name = '{MindScoreTestName}';");
        await db.Database.ExecuteSqlRawAsync("UPDATE users SET agebandid = NULL;");
        await db.Database.ExecuteSqlRawAsync("UPDATE questions SET agebandid = NULL;");
        await db.Database.ExecuteSqlRawAsync("DELETE FROM agebands;");
        await db.Database.ExecuteSqlRawAsync("UPDATE questions SET moduleid = NULL;");
        await db.Database.ExecuteSqlRawAsync("DELETE FROM modules;");

        // Clear EF change tracker so stale cached entities don't interfere.
        db.ChangeTracker.Clear();

        // ── Re-insert modules with random UUIDs ───────────────────────────────
        var moduleList = ModuleNames
            .Select(m => new Module
            {
                Id           = Guid.NewGuid(),
                Name         = m.name,
                DisplayOrder = m.order,
                IsActive     = true,
                CreatedAt    = now,
            })
            .ToList();
        db.Modules.AddRange(moduleList);
        await db.SaveChangesAsync();
        var moduleIdByName = moduleList.ToDictionary(m => m.Name, m => m.Id);

        // ── Re-insert age bands with random UUIDs ─────────────────────────────
        var ageBandList = AgeBandRanges
            .Select(ab => new AgeBand
            {
                Id           = Guid.NewGuid(),
                Name         = ab.name,
                MinAge       = ab.min,
                MaxAge       = ab.max,
                DisplayOrder = ab.order,
                IsActive     = true,
                CreatedAt    = now,
            })
            .ToList();
        db.AgeBands.AddRange(ageBandList);
        await db.SaveChangesAsync();
        var ageBandIds = ageBandList.Select(ab => ab.Id).ToArray();

        // ── Re-assign users.agebandid based on date of birth ─────────────────
        await db.Database.ExecuteSqlRawAsync(@"
            UPDATE users
            SET agebandid = ab.id
            FROM agebands ab
            WHERE users.dateofbirth IS NOT NULL
              AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, users.dateofbirth)) BETWEEN ab.minage AND ab.maxage;");

        // ── Insert MindScore test row with random UUID ────────────────────────
        var testId = Guid.NewGuid();
        db.Tests.Add(new Test { Id = testId, Name = MindScoreTestName, CreatedAtUtc = now });
        await db.SaveChangesAsync();

        // ── Seed questions, normrefs, weights ─────────────────────────────────
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
                        Id              = Guid.NewGuid(),
                        TestId          = testId,
                        Code            = $"{code}_AB{abi + 1}",
                        Order           = globalOrder++,
                        Text            = text,
                        ModuleId        = moduleId,
                        AgeBandId       = ageBandIds[abi],
                        IsReverseScored = reverse,
                        Weight          = 1.0m,
                        Version         = 1,
                        CreatedAtUtc    = now,
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
