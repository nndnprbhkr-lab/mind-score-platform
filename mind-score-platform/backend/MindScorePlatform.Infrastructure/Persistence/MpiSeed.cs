using MindScorePlatform.Domain.Entities;
using MindScorePlatform.Domain.Enums;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Static seed data for the MPI (MindType Profile Inventory) assessment.
/// Fixed GUIDs ensure the seed is idempotent across environments.
///
/// ── Dimensions ──────────────────────────────────────────────────────────────
///   EI  → EnergySource    high = E (Extrovert)      low = R (Introvert)
///   SN  → PerceptionMode  high = O (Observant)       low = I (Intuitive)
///   TF  → DecisionStyle   high = L (Logical)         low = V (Values)
///   JP  → LifeApproach    high = S (Structured)      low = A (Adaptive)
///   _R suffix → IsReverseScored (adjustedScore = 6 − rawValue)
///
/// ── Question GUID ranges ────────────────────────────────────────────────────
///   00000000-0000-0000-0001-XXXXXXXXXXXX  Universal anchors    (Orders 1–20)
///   00000000-0000-0000-0002-XXXXXXXXXXXX  Context-aware + branch targets
///       Career questions            Orders 21–26
///       Relationships questions     Orders 30–35
///       Leadership questions        Orders 40–45
///       PersonalDevelopment qs.     Orders 50–55
///       Branch targets (universal)  Orders 500–503
///
/// ── Context tags ────────────────────────────────────────────────────────────
///   null                         → served in ALL contexts (General)
///   ["Career"]                   → only for Career context
///   ["Relationships"]            → only for Relationships context
///   ["Leadership"]               → only for Leadership context
///   ["PersonalDevelopment"]      → only for Personal Development context
///
/// ── Adaptive branching ──────────────────────────────────────────────────────
///   EI_05 (Order 5)  → branches to EI_DEEP_R (introvert) or EI_DEEP_E (extrovert)
///   TF_05 (Order 15) → branches to TF_DEEP_V (values)    or TF_DEEP_L (logical)
///   Branch targets (Orders 500–503) sit above all context question Orders so
///   they never appear in the linear path — only reached via explicit branching.
///
/// Scale: 1 = Strongly Disagree → 5 = Strongly Agree
/// </summary>
internal static class MpiSeed
{
    internal static readonly Guid TestId = new("00000000-0000-0000-0000-000000000001");

    internal static readonly Test Test = new()
    {
        Id = TestId,
        Name = "MindType Assessment",
        CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
    };

    internal static readonly Question[] Questions =
    [
        // ────────────────────────────────────────────────────────────────────
        // UNIVERSAL ANCHORS — served in all contexts (ContextTagsJson = null)
        // Orders 1–20 form the linear backbone of the General context.
        // ────────────────────────────────────────────────────────────────────

        // ── EnergySource (EI) ────────────────────────────────────────────────
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
            IsReverseScored = true,
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
            IsReverseScored = true,
            Text = "I find large gatherings draining, even when I enjoy the people there.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        // Branching: extreme introvert (1–2) → EI_DEEP_R; extreme extrovert (4–5) → EI_DEEP_E
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000005"),
            TestId = TestId,
            Code = "EI_05",
            Order = 5,
            Text = "I think better when I'm talking ideas through with someone rather than sitting with them alone.",
            BranchingRulesJson = @"{""conditions"":[{""answerRange"":[1,2],""nextQuestionCode"":""EI_DEEP_R""},{""answerRange"":[4,5],""nextQuestionCode"":""EI_DEEP_E""}]}",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ── PerceptionMode (SN) ──────────────────────────────────────────────
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
            IsReverseScored = true,
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
            IsReverseScored = true,
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

        // ── DecisionStyle (TF) ───────────────────────────────────────────────
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
            IsReverseScored = true,
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
            IsReverseScored = true,
            Text = "I consider how my decisions will affect the feelings of the people involved.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        // Branching: extreme values (1–2) → TF_DEEP_V; extreme logical (4–5) → TF_DEEP_L
        new()
        {
            Id = new Guid("00000000-0000-0000-0001-000000000015"),
            TestId = TestId,
            Code = "TF_05",
            Order = 15,
            Text = "I prefer a well-reasoned argument over an emotional appeal when making up my mind.",
            BranchingRulesJson = @"{""conditions"":[{""answerRange"":[1,2],""nextQuestionCode"":""TF_DEEP_V""},{""answerRange"":[4,5],""nextQuestionCode"":""TF_DEEP_L""}]}",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ── LifeApproach (JP) ────────────────────────────────────────────────
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
            IsReverseScored = true,
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
            IsReverseScored = true,
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

        // ────────────────────────────────────────────────────────────────────
        // BLOCK A — Universal Branch Targets (Orders 500–503)
        // Not in the linear path — only served when EI_05 or TF_05 branches.
        // ContextTagsJson = null → eligible in all contexts.
        // High Order values ensure these never appear during linear fallback.
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000001"),
            TestId = TestId,
            Code = "EI_DEEP_E",
            Order = 500,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Text = "When I need to recharge, I gravitate toward busy social events rather than spending time alone.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000002"),
            TestId = TestId,
            Code = "EI_DEEP_R",
            Order = 501,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            Text = "Extended periods of solitude feel essential to my wellbeing, even when life is going well.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000003"),
            TestId = TestId,
            Code = "TF_DEEP_L",
            Order = 502,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            Text = "When solving problems, I focus on root causes and system efficiency rather than who is affected.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000004"),
            TestId = TestId,
            Code = "TF_DEEP_V",
            Order = 503,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            Text = "The emotional impact of a decision on others weighs more heavily on me than its logical merits.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK B — Career Likert (Orders 21–24)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000005"),
            TestId = TestId,
            Code = "EI_CAR_01",
            Order = 21,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Career""]",
            Text = "Collaborative brainstorming sessions at work leave me more energized than focused solo work.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000006"),
            TestId = TestId,
            Code = "SN_CAR_01_R",
            Order = 22,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""Career""]",
            Text = "I often find myself pitching future possibilities at work rather than refining existing processes.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000007"),
            TestId = TestId,
            Code = "TF_CAR_01_R",
            Order = 23,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""Career""]",
            Text = "When workplace decisions affect team morale, I weight personal impact over operational logic.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000008"),
            TestId = TestId,
            Code = "JP_CAR_01",
            Order = 24,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Career""]",
            Text = "I plan my workweek in detail and resist changes to my scheduled priorities.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK C — Career Scenarios (Orders 25–26)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000009"),
            TestId = TestId,
            Code = "SCEN_CAR_01",
            Order = 25,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Career""]",
            Text = "Your team has been asked to recommend a new approach for an ongoing project, but the brief is vague and stakeholders disagree on priorities. You have one week before presenting a proposal, and your manager has delegated the decision to the team. How do you most naturally engage with this situation?",
            ScenarioOptionsJson = @"[{""text"":""Call a working meeting first thing, gather everyone's views aloud, and push the group toward a shared direction through open discussion."",""traitMappings"":{""EnergySource"":5,""LifeApproach"":4}},{""text"":""Research how similar teams solved comparable problems, gather concrete data, and draft a detailed proposal based on what has worked before."",""traitMappings"":{""PerceptionMode"":5,""LifeApproach"":4}},{""text"":""Spend time alone thinking through emerging patterns, then share a conceptual framework exploring possibilities the team may not have considered yet."",""traitMappings"":{""EnergySource"":2,""PerceptionMode"":1}},{""text"":""Check in individually with teammates to understand how each is affected, then propose an approach balancing the group's emotional and practical needs."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":3}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000010"),
            TestId = TestId,
            Code = "SCEN_CAR_02",
            Order = 26,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Career""]",
            Text = "Two important projects are due the same week and you cannot fully deliver both to your usual standard. Your manager leaves the trade-off to you, and neither project has an obvious priority. You have a full day before you need to commit to a plan. What is your most likely response?",
            ScenarioOptionsJson = @"[{""text"":""Build a detailed hour-by-hour schedule that protects the non-negotiable deadlines first, then scope down the lower-impact project to fit within remaining hours."",""traitMappings"":{""LifeApproach"":5,""DecisionStyle"":4}},{""text"":""Talk it through with both project stakeholders to understand what each needs emotionally, then propose a middle path everyone can accept."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":4}},{""text"":""Keep both options open and adapt day by day, trusting I can shift attention as each project's actual urgency becomes clearer."",""traitMappings"":{""LifeApproach"":1,""PerceptionMode"":2}},{""text"":""Map the underlying system — who needs what, by when, and why — then make the most logically efficient cut even if it disappoints someone."",""traitMappings"":{""DecisionStyle"":5,""PerceptionMode"":4}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK D — Relationships Likert (Orders 30–33)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000011"),
            TestId = TestId,
            Code = "EI_REL_01",
            Order = 30,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Relationships""]",
            Text = "I stay energized after long social gatherings with close friends, even when they run late.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000012"),
            TestId = TestId,
            Code = "SN_REL_01_R",
            Order = 31,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""Relationships""]",
            Text = "I often sense unspoken meanings in a partner's words before I notice the literal facts.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000013"),
            TestId = TestId,
            Code = "TF_REL_01",
            Order = 32,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Relationships""]",
            Text = "During relationship conflicts, I focus on identifying what is objectively fair rather than comforting feelings first.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000014"),
            TestId = TestId,
            Code = "JP_REL_01_R",
            Order = 33,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""Relationships""]",
            Text = "I prefer spontaneous plans with close people over keeping fixed routines or scheduled commitments.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK E — Relationships Scenarios (Orders 34–35)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000015"),
            TestId = TestId,
            Code = "SCEN_REL_01",
            Order = 34,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Relationships""]",
            Text = "A close friend has grown distant over the past month, cancelling plans and giving short replies. You do not know the cause, and when you last asked, they deflected. You are starting to feel hurt and uncertain whether to press further. What do you most likely do next?",
            ScenarioOptionsJson = @"[{""text"":""Suggest meeting in person to talk it through openly — you process through conversation and would rather hash it out than sit with uncertainty."",""traitMappings"":{""EnergySource"":5,""LifeApproach"":4}},{""text"":""Sit with the situation for several days, noticing patterns in their behaviour and replaying past interactions before deciding how to respond."",""traitMappings"":{""EnergySource"":1,""PerceptionMode"":4}},{""text"":""Focus on what you can logically observe — their actions, not assumed intent — and wait for concrete information before investing emotional energy."",""traitMappings"":{""DecisionStyle"":5,""PerceptionMode"":4}},{""text"":""Send a warm, open message acknowledging you sense something is off and making space for whatever they need to share."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":3}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000016"),
            TestId = TestId,
            Code = "SCEN_REL_02",
            Order = 35,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Relationships""]",
            Text = "Your partner has been offered a career opportunity that would require you both to relocate within three months. The move is exciting for them but disruptive for your own career and social life. A decision is needed this weekend. How do you most naturally engage?",
            ScenarioOptionsJson = @"[{""text"":""Work through a written pros-and-cons analysis covering finances, career trajectories, and logistics — decide based on which option objectively maximizes combined outcomes."",""traitMappings"":{""DecisionStyle"":5,""LifeApproach"":4}},{""text"":""Have a long, feelings-first conversation — what it means for each of you, what fears are surfacing — and let the emotional truth lead."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":4}},{""text"":""Hold off committing either way, stay open, and see what new information or intuition emerges over the next couple of weeks."",""traitMappings"":{""LifeApproach"":1,""PerceptionMode"":2}},{""text"":""Take time alone to imagine both futures vividly, then share the deeper patterns and possibilities you noticed before deciding together."",""traitMappings"":{""EnergySource"":1,""PerceptionMode"":1}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK F — Leadership Likert (Orders 40–43)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000017"),
            TestId = TestId,
            Code = "EI_LEA_01",
            Order = 40,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Leadership""]",
            Text = "As a leader, I prefer visible front-line roles that involve speaking to large groups and rallying people.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000018"),
            TestId = TestId,
            Code = "SN_LEA_01",
            Order = 41,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Leadership""]",
            Text = "When leading, I rely on concrete performance data and track records rather than long-term vision statements.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000019"),
            TestId = TestId,
            Code = "TF_LEA_01_R",
            Order = 42,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""Leadership""]",
            Text = "When leading, I weigh each team member's personal circumstances more heavily than strict performance standards.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000020"),
            TestId = TestId,
            Code = "JP_LEA_01",
            Order = 43,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""Leadership""]",
            Text = "I set clear goals, milestones, and deadlines for my team and hold people firmly to them.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK G — Leadership Scenarios (Orders 44–45)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000021"),
            TestId = TestId,
            Code = "SCEN_LEA_01",
            Order = 44,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Leadership""]",
            Text = "A previously high-performing team member has missed three consecutive deadlines and is withdrawing in meetings. Other teammates are starting to pick up the slack and grumble quietly. You have not yet spoken directly with the person, and a quarterly review is two weeks away. How do you proceed?",
            ScenarioOptionsJson = @"[{""text"":""Schedule a direct one-on-one this week, lay out the performance facts clearly, and agree on measurable expectations with firm deadlines."",""traitMappings"":{""DecisionStyle"":5,""LifeApproach"":5}},{""text"":""Create space for an open conversation focused on how they are doing as a person — something is likely going on beneath the surface."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":4}},{""text"":""Observe quietly for another week, gather more data points and context from others, then decide once the pattern is clearer."",""traitMappings"":{""EnergySource"":2,""PerceptionMode"":4}},{""text"":""Hold a team discussion about workload and shared standards, letting the group itself shape how to address the drift."",""traitMappings"":{""EnergySource"":5,""LifeApproach"":3}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000022"),
            TestId = TestId,
            Code = "SCEN_LEA_02",
            Order = 45,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""Leadership""]",
            Text = "Your team must choose between two strategic directions for the next quarter, each with incomplete information. One is a proven safe bet with modest gains; the other is an unfamiliar opportunity with bigger potential upside and real risk. A recommendation is due by Friday. How do you approach the choice?",
            ScenarioOptionsJson = @"[{""text"":""Convene a cross-functional working group, debate both options openly in a full-day session, and push toward a shared decision through rapid group dialogue."",""traitMappings"":{""EnergySource"":5,""LifeApproach"":4}},{""text"":""Commission a deep dive into historical data and comparable cases, then recommend the option the evidence most concretely supports."",""traitMappings"":{""PerceptionMode"":5,""DecisionStyle"":4}},{""text"":""Pick the unfamiliar opportunity — the pattern feels right, the upside matters, and waiting for full certainty will cost momentum."",""traitMappings"":{""PerceptionMode"":1,""LifeApproach"":2}},{""text"":""Consider how each option affects the team's wellbeing and growth, and pick the one people can believe in and commit to."",""traitMappings"":{""DecisionStyle"":1,""EnergySource"":3}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK H — Personal Development Likert (Orders 50–53)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000023"),
            TestId = TestId,
            Code = "EI_PD_01_R",
            Order = 50,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "My most meaningful personal growth happens during extended solitude rather than in groups or conversations.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000024"),
            TestId = TestId,
            Code = "SN_PD_01",
            Order = 51,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "I prefer tracking concrete habits and measurable progress over exploring abstract themes about who I am becoming.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000025"),
            TestId = TestId,
            Code = "TF_PD_01",
            Order = 52,
            QuestionType = QuestionType.Likert,
            IsReverseScored = false,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "When reflecting on myself, I diagnose what is inefficient or irrational rather than sitting with emotions first.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000026"),
            TestId = TestId,
            Code = "JP_PD_01_R",
            Order = 53,
            QuestionType = QuestionType.Likert,
            IsReverseScored = true,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "I let my personal growth unfold organically rather than committing to structured routines or plans.",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },

        // ────────────────────────────────────────────────────────────────────
        // BLOCK I — Personal Development Scenarios (Orders 54–55)
        // ────────────────────────────────────────────────────────────────────
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000027"),
            TestId = TestId,
            Code = "SCEN_PD_01",
            Order = 54,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "You have been feeling stuck in a recurring personal pattern — one that surfaces in work, relationships, and your own self-talk. You have noticed it clearly this week and know you want to address it. You have a free weekend ahead to work on it. What do you most naturally reach for?",
            ScenarioOptionsJson = @"[{""text"":""Journal alone for hours, mapping connections between current behaviours and deeper themes you have been noticing over the past months."",""traitMappings"":{""EnergySource"":1,""PerceptionMode"":1}},{""text"":""Reach out to a trusted friend or coach, talk it through aloud, and let the conversation surface what you could not see alone."",""traitMappings"":{""EnergySource"":5,""DecisionStyle"":2}},{""text"":""Build a structured weekend plan — specific reading, specific exercises, specific reflection prompts — and work through it step by step."",""traitMappings"":{""LifeApproach"":5,""DecisionStyle"":4}},{""text"":""Research proven frameworks for this kind of pattern, identify the mechanism causing it, and design a logical intervention to test."",""traitMappings"":{""DecisionStyle"":5,""PerceptionMode"":4}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
        new()
        {
            Id = new Guid("00000000-0000-0000-0002-000000000028"),
            TestId = TestId,
            Code = "SCEN_PD_02",
            Order = 55,
            QuestionType = QuestionType.Scenario,
            ContextTagsJson = @"[""PersonalDevelopment""]",
            Text = "You have decided to make a significant lifestyle change — a new sleep schedule, exercise routine, and reading practice — starting next month. You have three weeks to prepare. You know from experience that some change strategies work better for you than others. How do you set yourself up?",
            ScenarioOptionsJson = @"[{""text"":""Write a detailed weekly plan with specific times, metrics, and milestones, then commit publicly to maintain accountability through clear structure."",""traitMappings"":{""LifeApproach"":5,""DecisionStyle"":4}},{""text"":""Start loosely, see what feels right in practice, and adapt the approach as you go without committing to a rigid plan."",""traitMappings"":{""LifeApproach"":1,""PerceptionMode"":2}},{""text"":""Research behaviour-change science, identify the mechanisms most likely to work for someone like you, and design a system based on evidence."",""traitMappings"":{""PerceptionMode"":5,""DecisionStyle"":5}},{""text"":""Involve close friends or a group — shared energy, public commitment, and social reinforcement are what actually make things stick for you."",""traitMappings"":{""EnergySource"":5,""DecisionStyle"":2}}]",
            CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
        },
    ];
}
