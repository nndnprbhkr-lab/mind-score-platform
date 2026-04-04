using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Static seed data for the MPI assessment.
/// Fixed GUIDs ensure the seed is idempotent across environments.
///
/// Question codes follow the pattern: {DIMENSION}_{ORDER}[_R]
///   Prefix  → Dimension scored
///   EI      → EnergySource   (high = E / Extrovert, low = R / Introvert)
///   SN      → PerceptionMode (high = O / Observant, low = I / Intuitive)
///   TF      → DecisionStyle  (high = L / Logical,   low = V / Values)
///   JP      → LifeApproach   (high = S / Structured, low = A / Adaptive)
///   _R suffix → score is reversed (adjustedScore = 6 - value)
///
/// Scale presented to user: 1 = Strongly Disagree → 5 = Strongly Agree
/// </summary>
internal static class MpiSeed
{
    internal static readonly Guid TestId = new("00000000-0000-0000-0000-000000000001");

    internal static readonly Test Test = new()
    {
        Id = TestId,
        Name = "MPI Assessment",
        CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
    };

    internal static readonly Question[] Questions =
    [
        // ── EnergySource (EI) ─────────────────────────────────────────────
        // High score → E (draws energy from people/outside world)
        // Low score  → R (draws energy from within, needs solitude)

        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000001"),
            TestId = TestId,
            Code = "EI_01",
            Order = 1,
            Text = "I feel energised after spending time with friends or a group of people.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000002"),
            TestId = TestId,
            Code = "EI_02_R",
            Order = 2,
            Text = "After a busy social day, I need quiet time alone to feel like myself again.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000003"),
            TestId = TestId,
            Code = "EI_03",
            Order = 3,
            Text = "I enjoy starting conversations with people I've never met before.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000004"),
            TestId = TestId,
            Code = "EI_04_R",
            Order = 4,
            Text = "I find large gatherings draining, even when I enjoy the people there.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000005"),
            TestId = TestId,
            Code = "EI_05",
            Order = 5,
            Text = "I think better when I'm talking ideas through with someone rather than sitting with them alone.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ── PerceptionMode (SN) ───────────────────────────────────────────
        // High score → O (concrete, practical, observant)
        // Low score  → I (abstract, intuitive, future-focused)

        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000006"),
            TestId = TestId,
            Code = "SN_01",
            Order = 6,
            Text = "I prefer clear, step-by-step instructions over figuring things out as I go.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000007"),
            TestId = TestId,
            Code = "SN_02_R",
            Order = 7,
            Text = "I often find myself thinking about what could be, more than what currently is.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000008"),
            TestId = TestId,
            Code = "SN_03",
            Order = 8,
            Text = "I trust facts and direct experience more than gut feelings or hunches.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000009"),
            TestId = TestId,
            Code = "SN_04_R",
            Order = 9,
            Text = "I get excited by new ideas and possibilities, even when they're not fully formed yet.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000010"),
            TestId = TestId,
            Code = "SN_05",
            Order = 10,
            Text = "I focus on the task at hand rather than getting distracted by future possibilities.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ── DecisionStyle (TF) ────────────────────────────────────────────
        // High score → L (logical, objective, consistent)
        // Low score  → V (values-driven, empathic, relationship-aware)

        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000011"),
            TestId = TestId,
            Code = "TF_01",
            Order = 11,
            Text = "When solving a problem, I focus on what's logical and objective rather than what feels right.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000012"),
            TestId = TestId,
            Code = "TF_02_R",
            Order = 12,
            Text = "I find it difficult to make a decision if I know it will upset someone close to me.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000013"),
            TestId = TestId,
            Code = "TF_03",
            Order = 13,
            Text = "I believe being fair and consistent matters more than making exceptions for individuals.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000014"),
            TestId = TestId,
            Code = "TF_04_R",
            Order = 14,
            Text = "I consider how my decisions will affect the feelings of the people involved.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000015"),
            TestId = TestId,
            Code = "TF_05",
            Order = 15,
            Text = "I prefer a well-reasoned argument over an emotional appeal when making up my mind.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ── LifeApproach (JP) ─────────────────────────────────────────────
        // High score → S (structured, planned, decisive)
        // Low score  → A (adaptive, flexible, spontaneous)

        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000016"),
            TestId = TestId,
            Code = "JP_01",
            Order = 16,
            Text = "I like having a clear plan before I start a task.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000017"),
            TestId = TestId,
            Code = "JP_02_R",
            Order = 17,
            Text = "I prefer to keep my options open rather than committing to a fixed plan.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000018"),
            TestId = TestId,
            Code = "JP_03",
            Order = 18,
            Text = "I feel unsettled when plans change unexpectedly at the last minute.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000019"),
            TestId = TestId,
            Code = "JP_04_R",
            Order = 19,
            Text = "I often decide things at the last moment and feel perfectly comfortable doing so.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000020"),
            TestId = TestId,
            Code = "JP_05",
            Order = 20,
            Text = "I prefer to have things resolved and settled rather than leaving them open-ended.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
    ];
}
