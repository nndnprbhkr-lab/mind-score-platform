using System.Text.Json;
using System.Text.Json.Serialization;
using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Static seed data for the Career Fit Assessment.
/// 18 scenario questions — no age-band filter (AgeBandId = null) so all users receive them.
///
/// ── Cluster codes ──────────────────────────────────────────────────────────
///   BUILDER · ANALYST · LEADER · CREATOR · CAREGIVER · COMMUNICATOR · ENTREPRENEUR · OPERATOR
///
/// ── Question GUID range ────────────────────────────────────────────────────
///   00000000-0000-0000-0003-XXXXXXXXXXXX  (001–018)
///
/// ── ScenarioOptionsJson shape ──────────────────────────────────────────────
///   [ { "text": "...", "clusterImpact": { "BUILDER": 5, "ANALYST": 2 } }, … ]
///   Each question has exactly 4 options.
/// </summary>
internal static class CareerFitSeed
{
    private static readonly JsonSerializerOptions _json =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    internal static readonly Guid TestId = new("00000000-0000-0000-0000-000000000002");

    internal static readonly Test Test = new()
    {
        Id           = TestId,
        Name         = "Career Fit Assessment",
        CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
    };

    // ── Helpers ───────────────────────────────────────────────────────────────

    private sealed record Opt(string Text, Dictionary<string, int> ClusterImpact);

    private static string Opts(params Opt[] options)
        => JsonSerializer.Serialize(options, _json);

    private static Guid Q(int n) => new($"00000000-0000-0000-0003-{n:000000000000}");

    // ── Questions ─────────────────────────────────────────────────────────────

    internal static readonly Question[] Questions =
    [
        // Q1 — Work environment
        new()
        {
            Id               = Q(1),
            TestId           = TestId,
            Code             = "CF_01",
            Order            = 1,
            QuestionType     = QuestionType.Scenario,
            Text             = "Your ideal work setup energises you most when you are...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Building something concrete — a product, system, or solution that works.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 2 }),
                new("Digging into data and uncovering insights that inform strategy.",
                    new() { ["ANALYST"] = 5, ["OPERATOR"] = 2 }),
                new("Leading people toward a shared goal and watching them grow.",
                    new() { ["LEADER"] = 5, ["COMMUNICATOR"] = 2 }),
                new("Creating something original that changes how people feel or think.",
                    new() { ["CREATOR"] = 5, ["ENTREPRENEUR"] = 2 })
            ),
        },

        // Q2 — Approaching a new challenge
        new()
        {
            Id               = Q(2),
            TestId           = TestId,
            Code             = "CF_02",
            Order            = 2,
            QuestionType     = QuestionType.Scenario,
            Text             = "When a brand-new challenge lands on your desk, your first instinct is to...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Dive in, experiment, and iterate fast.",
                    new() { ["ENTREPRENEUR"] = 5, ["BUILDER"] = 3 }),
                new("Research thoroughly before committing to a direction.",
                    new() { ["ANALYST"] = 5, ["OPERATOR"] = 3 }),
                new("Rally the team and divide responsibilities across people.",
                    new() { ["LEADER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Consider carefully how it will affect the people involved.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 2 })
            ),
        },

        // Q3 — Proudest achievement
        new()
        {
            Id               = Q(3),
            TestId           = TestId,
            Code             = "CF_03",
            Order            = 3,
            QuestionType     = QuestionType.Scenario,
            Text             = "The achievement that would make you most proud is...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Shipping a product or system that millions of people rely on every day.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 2 }),
                new("Discovering an insight that completely changed a strategy or market.",
                    new() { ["ANALYST"] = 5, ["ENTREPRENEUR"] = 3 }),
                new("Watching someone you mentored become a leader in their own right.",
                    new() { ["CAREGIVER"] = 5, ["LEADER"] = 4 }),
                new("Creating a piece of work that shifted culture or moved public opinion.",
                    new() { ["CREATOR"] = 5, ["COMMUNICATOR"] = 3 })
            ),
        },

        // Q4 — End of great workday
        new()
        {
            Id               = Q(4),
            TestId           = TestId,
            Code             = "CF_04",
            Order            = 4,
            QuestionType     = QuestionType.Scenario,
            Text             = "At the end of a great workday, you feel best when you have...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Built, shipped, or fixed something real and tangible.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 2 }),
                new("Solved a complex puzzle or learned something genuinely unexpected.",
                    new() { ["ANALYST"] = 5, ["CREATOR"] = 2 }),
                new("Helped someone navigate a genuinely difficult situation.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Inspired a room, closed a deal, or led a high-stakes conversation.",
                    new() { ["COMMUNICATOR"] = 5, ["LEADER"] = 3 })
            ),
        },

        // Q5 — Team roadblock
        new()
        {
            Id               = Q(5),
            TestId           = TestId,
            Code             = "CF_05",
            Order            = 5,
            QuestionType     = QuestionType.Scenario,
            Text             = "When your team hits a serious roadblock, you tend to...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Engineer a technical workaround or a creative patch.",
                    new() { ["BUILDER"] = 5, ["ANALYST"] = 3 }),
                new("Step up, make a call, and rally everyone forward.",
                    new() { ["LEADER"] = 5, ["ENTREPRENEUR"] = 4 }),
                new("Uncover the human issue that is really blocking progress.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Throw out the old plan and reimagine the approach entirely.",
                    new() { ["CREATOR"] = 5, ["ENTREPRENEUR"] = 3 })
            ),
        },

        // Q6 — Decision-making style
        new()
        {
            Id               = Q(6),
            TestId           = TestId,
            Code             = "CF_06",
            Order            = 6,
            QuestionType     = QuestionType.Scenario,
            Text             = "When it comes to making important decisions, you typically...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Trust the data — you build models and pressure-test options first.",
                    new() { ["ANALYST"] = 5, ["OPERATOR"] = 3 }),
                new("Trust your gut and move before the picture is fully clear.",
                    new() { ["ENTREPRENEUR"] = 5, ["CREATOR"] = 3 }),
                new("Build consensus — a decision everyone owns beats a perfect top-down call.",
                    new() { ["LEADER"] = 5, ["CAREGIVER"] = 3 }),
                new("Filter through values — what is right, not just what is optimal.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 2 })
            ),
        },

        // Q7 — Dream project
        new()
        {
            Id               = Q(7),
            TestId           = TestId,
            Code             = "CF_07",
            Order            = 7,
            QuestionType     = QuestionType.Scenario,
            Text             = "If you could pick your next project, your dream would be...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Designing and building a complex technical system from scratch.",
                    new() { ["BUILDER"] = 5, ["ANALYST"] = 3 }),
                new("Launching a brand-new business or product from zero to market.",
                    new() { ["ENTREPRENEUR"] = 5, ["CREATOR"] = 3 }),
                new("Coaching a high-potential team to peak performance.",
                    new() { ["LEADER"] = 5, ["CAREGIVER"] = 4 }),
                new("Creating a product experience that genuinely delights people.",
                    new() { ["CREATOR"] = 5, ["BUILDER"] = 3 })
            ),
        },

        // Q8 — Time management
        new()
        {
            Id               = Q(8),
            TestId           = TestId,
            Code             = "CF_08",
            Order            = 8,
            QuestionType     = QuestionType.Scenario,
            Text             = "When managing your time and workflow, you...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Follow structured plans and resist unscheduled interruptions.",
                    new() { ["OPERATOR"] = 5, ["ANALYST"] = 3 }),
                new("Stay fluid and re-prioritise constantly based on what matters most right now.",
                    new() { ["ENTREPRENEUR"] = 5, ["LEADER"] = 3 }),
                new("Block long stretches for deep, uninterrupted thinking.",
                    new() { ["ANALYST"] = 5, ["BUILDER"] = 4 }),
                new("Leave room for spontaneous collaboration and idea exchange.",
                    new() { ["COMMUNICATOR"] = 5, ["CREATOR"] = 3 })
            ),
        },

        // Q9 — Something breaks
        new()
        {
            Id               = Q(9),
            TestId           = TestId,
            Code             = "CF_09",
            Order            = 9,
            QuestionType     = QuestionType.Scenario,
            Text             = "When something fails or breaks badly at work, you...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Diagnose the root cause systematically before touching anything.",
                    new() { ["ANALYST"] = 5, ["BUILDER"] = 3 }),
                new("Build a fix fast and put safeguards in place to prevent recurrence.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 4 }),
                new("Coordinate the response — communicate, assign roles, manage stakeholders.",
                    new() { ["LEADER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Focus first on the people impacted and how to make things right for them.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 })
            ),
        },

        // Q10 — Type of impact
        new()
        {
            Id               = Q(10),
            TestId           = TestId,
            Code             = "CF_10",
            Order            = 10,
            QuestionType     = QuestionType.Scenario,
            Text             = "The type of impact you care most about creating is...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Infrastructure or systems that scale and outlast their creator.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 3 }),
                new("Revenue growth, market leadership, or a thriving business.",
                    new() { ["ENTREPRENEUR"] = 5, ["ANALYST"] = 2 }),
                new("Improving someone's health, confidence, or life trajectory.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Shifting how people think, feel, or experience the world around them.",
                    new() { ["CREATOR"] = 5, ["COMMUNICATOR"] = 4 })
            ),
        },

        // Q11 — Learning style
        new()
        {
            Id               = Q(11),
            TestId           = TestId,
            Code             = "CF_11",
            Order            = 11,
            QuestionType     = QuestionType.Scenario,
            Text             = "When learning something completely new, you prefer to...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Study documentation, research, and theory before taking action.",
                    new() { ["ANALYST"] = 5, ["OPERATOR"] = 3 }),
                new("Jump in and learn entirely by doing — mistakes included.",
                    new() { ["BUILDER"] = 5, ["ENTREPRENEUR"] = 4 }),
                new("Watch an expert do it, then teach it to someone else to lock it in.",
                    new() { ["COMMUNICATOR"] = 5, ["LEADER"] = 3 }),
                new("Learn alongside a mentor who gives real-time personalised feedback.",
                    new() { ["CAREGIVER"] = 3, ["LEADER"] = 3, ["COMMUNICATOR"] = 4 })
            ),
        },

        // Q12 — New responsibility
        new()
        {
            Id               = Q(12),
            TestId           = TestId,
            Code             = "CF_12",
            Order            = 12,
            QuestionType     = QuestionType.Scenario,
            Text             = "When handed a significant new responsibility, your first move is to...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Map out a clear plan with milestones, owners, and dependencies.",
                    new() { ["OPERATOR"] = 5, ["LEADER"] = 3 }),
                new("Find the fastest path to delivering real value, even imperfectly.",
                    new() { ["ENTREPRENEUR"] = 5, ["BUILDER"] = 3 }),
                new("Explore creative angles others have not considered yet.",
                    new() { ["CREATOR"] = 5, ["ENTREPRENEUR"] = 3 }),
                new("Identify who you need and build a support network around the goal.",
                    new() { ["LEADER"] = 5, ["CAREGIVER"] = 3 })
            ),
        },

        // Q13 — Risk appetite
        new()
        {
            Id               = Q(13),
            TestId           = TestId,
            Code             = "CF_13",
            Order            = 13,
            QuestionType     = QuestionType.Scenario,
            Text             = "Risk and uncertainty at work make you feel...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Excited — where there is risk, there is opportunity worth seizing.",
                    new() { ["ENTREPRENEUR"] = 5, ["CREATOR"] = 3 }),
                new("Focused — you model the downside and reduce it systematically.",
                    new() { ["ANALYST"] = 5, ["OPERATOR"] = 4 }),
                new("Responsible — your priority is protecting the people involved.",
                    new() { ["CAREGIVER"] = 5, ["LEADER"] = 2 }),
                new("Curious — you see it as a creative problem waiting to be reframed.",
                    new() { ["CREATOR"] = 5, ["ENTREPRENEUR"] = 2 })
            ),
        },

        // Q14 — Colleague struggling
        new()
        {
            Id               = Q(14),
            TestId           = TestId,
            Code             = "CF_14",
            Order            = 14,
            QuestionType     = QuestionType.Scenario,
            Text             = "A colleague is visibly struggling with a tough assignment. You...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Pair up with them to debug or solve the technical challenge together.",
                    new() { ["BUILDER"] = 5, ["ANALYST"] = 3 }),
                new("Sit with them, listen deeply, and offer genuine emotional support.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Connect them to someone better positioned to help solve the problem.",
                    new() { ["COMMUNICATOR"] = 5, ["LEADER"] = 3 }),
                new("Step in, take ownership of the situation, and drive it to resolution.",
                    new() { ["LEADER"] = 5, ["ENTREPRENEUR"] = 3 })
            ),
        },

        // Q15 — All-hands excitement
        new()
        {
            Id               = Q(15),
            TestId           = TestId,
            Code             = "CF_15",
            Order            = 15,
            QuestionType     = QuestionType.Scenario,
            Text             = "At a company all-hands, you get most excited when you hear about...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("New product roadmap, engineering milestones, and technical innovations.",
                    new() { ["BUILDER"] = 5, ["ANALYST"] = 3 }),
                new("Bold business growth targets and how the company plans to win the market.",
                    new() { ["ENTREPRENEUR"] = 5, ["ANALYST"] = 2 }),
                new("Stories about employees or customers whose lives have been genuinely changed.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 4 }),
                new("Daring creative campaigns or brand moves that nobody saw coming.",
                    new() { ["CREATOR"] = 5, ["COMMUNICATOR"] = 3 })
            ),
        },

        // Q16 — Work style
        new()
        {
            Id               = Q(16),
            TestId           = TestId,
            Code             = "CF_16",
            Order            = 16,
            QuestionType     = QuestionType.Scenario,
            Text             = "The work setup where you consistently do your absolute best is...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Deep solo focus — no meetings, no interruptions, just you and the problem.",
                    new() { ["ANALYST"] = 5, ["BUILDER"] = 4 }),
                new("Fast-paced cross-functional sprints where you juggle multiple moving parts.",
                    new() { ["ENTREPRENEUR"] = 5, ["COMMUNICATOR"] = 3 }),
                new("Clear structures, accountable teams, and well-defined repeatable processes.",
                    new() { ["OPERATOR"] = 5, ["LEADER"] = 3 }),
                new("Open, diverse collaboration where great ideas can come from anywhere.",
                    new() { ["CREATOR"] = 5, ["COMMUNICATOR"] = 4 })
            ),
        },

        // Q17 — Career end goal
        new()
        {
            Id               = Q(17),
            TestId           = TestId,
            Code             = "CF_17",
            Order            = 17,
            QuestionType     = QuestionType.Scenario,
            Text             = "Looking further ahead, you would feel most fulfilled if your career led to...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("Having built products, tools, or infrastructure that millions depend on.",
                    new() { ["BUILDER"] = 5, ["ENTREPRENEUR"] = 2 }),
                new("Running your own company, fund, or investment portfolio.",
                    new() { ["ENTREPRENEUR"] = 5, ["LEADER"] = 3 }),
                new("Leading a large organisation or a mission-driven institution.",
                    new() { ["LEADER"] = 5, ["OPERATOR"] = 3 }),
                new("Being recognised as the world's leading expert in your field.",
                    new() { ["ANALYST"] = 5, ["COMMUNICATOR"] = 3 })
            ),
        },

        // Q18 — Measuring success
        new()
        {
            Id               = Q(18),
            TestId           = TestId,
            Code             = "CF_18",
            Order            = 18,
            QuestionType     = QuestionType.Scenario,
            Text             = "At the end of it all, you measure success by...",
            CreatedAtUtc     = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            ScenarioOptionsJson = Opts(
                new("What you built, shipped, or delivered that still runs reliably today.",
                    new() { ["BUILDER"] = 5, ["OPERATOR"] = 4 }),
                new("The growth in revenue, users, or market share you personally drove.",
                    new() { ["ENTREPRENEUR"] = 5, ["ANALYST"] = 2 }),
                new("The lives you changed or the problems you permanently solved for people.",
                    new() { ["CAREGIVER"] = 5, ["COMMUNICATOR"] = 3 }),
                new("The new ideas, categories, or experiences you introduced to the world.",
                    new() { ["CREATOR"] = 5, ["ENTREPRENEUR"] = 3 })
            ),
        },
    ];
}
