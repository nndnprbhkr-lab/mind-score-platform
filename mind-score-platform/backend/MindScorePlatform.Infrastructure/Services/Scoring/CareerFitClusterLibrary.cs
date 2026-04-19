namespace MindScorePlatform.Infrastructure.Services.Scoring;

public sealed record CareerClusterProfile(
    string   Code,
    string   Name,
    string   Emoji,
    string   Tagline,
    string[] Strengths,
    string[] GrowthAreas,
    string[] IdealRoles
);

/// <summary>
/// Static library of all 8 Career Fit cluster profiles.
/// Each cluster represents a distinct work-identity archetype.
/// </summary>
public static class CareerFitClusterLibrary
{
    private static readonly Dictionary<string, CareerClusterProfile> _profiles = new()
    {
        ["BUILDER"] = new(
            Code:        "BUILDER",
            Name:        "The Builder",
            Emoji:       "🔧",
            Tagline:     "You create the systems and products the world runs on.",
            Strengths:   ["Systems thinking", "Technical problem-solving", "Attention to detail", "Execution discipline"],
            GrowthAreas: ["Communicating vision to non-technical stakeholders", "Tolerating ambiguity before a solution is clear"],
            IdealRoles:  ["Software Engineer", "Product Engineer", "Infrastructure Architect", "Manufacturing Engineer", "DevOps Engineer"]
        ),
        ["ANALYST"] = new(
            Code:        "ANALYST",
            Name:        "The Analyst",
            Emoji:       "📊",
            Tagline:     "You turn complexity into clarity through data and logic.",
            Strengths:   ["Critical thinking", "Pattern recognition", "Research depth", "Precision"],
            GrowthAreas: ["Action bias — analysis can become paralysis", "Communicating findings to non-experts"],
            IdealRoles:  ["Data Scientist", "Financial Analyst", "Research Scientist", "Strategy Consultant", "Business Intelligence Engineer"]
        ),
        ["LEADER"] = new(
            Code:        "LEADER",
            Name:        "The Leader",
            Emoji:       "🎯",
            Tagline:     "You unlock the potential of people and guide teams toward ambitious goals.",
            Strengths:   ["Strategic vision", "People development", "Decision-making under pressure", "Cross-functional alignment"],
            GrowthAreas: ["Letting go of control", "Managing upward effectively"],
            IdealRoles:  ["Engineering Manager", "Product Manager", "COO", "VP of Operations", "Startup Founder"]
        ),
        ["CREATOR"] = new(
            Code:        "CREATOR",
            Name:        "The Creator",
            Emoji:       "🎨",
            Tagline:     "You shape how the world looks, feels, and thinks.",
            Strengths:   ["Originality", "Visual and conceptual thinking", "Storytelling", "Trend-spotting"],
            GrowthAreas: ["Execution consistency", "Working within tight constraints"],
            IdealRoles:  ["UX Designer", "Brand Strategist", "Creative Director", "Content Creator", "Product Designer"]
        ),
        ["CAREGIVER"] = new(
            Code:        "CAREGIVER",
            Name:        "The Caregiver",
            Emoji:       "💛",
            Tagline:     "You invest in human wellbeing and leave people better than you found them.",
            Strengths:   ["Empathy", "Active listening", "Conflict resolution", "Trust-building"],
            GrowthAreas: ["Setting firm boundaries", "Advocating for your own needs"],
            IdealRoles:  ["HR Business Partner", "Mental Health Professional", "Teacher", "Customer Success Manager", "Social Worker"]
        ),
        ["COMMUNICATOR"] = new(
            Code:        "COMMUNICATOR",
            Name:        "The Communicator",
            Emoji:       "🗣️",
            Tagline:     "You move people through words, presence, and genuine connection.",
            Strengths:   ["Persuasion", "Relationship-building", "Storytelling", "Adaptability to different audiences"],
            GrowthAreas: ["Deep independent technical work", "Working in isolation for extended periods"],
            IdealRoles:  ["Sales Executive", "Journalist", "Public Relations Manager", "Corporate Trainer", "Marketing Lead"]
        ),
        ["ENTREPRENEUR"] = new(
            Code:        "ENTREPRENEUR",
            Name:        "The Entrepreneur",
            Emoji:       "🚀",
            Tagline:     "You thrive in ambiguity, move fast, and create value where none existed.",
            Strengths:   ["Opportunity recognition", "Risk tolerance", "Resourcefulness", "High agency"],
            GrowthAreas: ["Patience for slow-moving processes", "Delegating without micromanaging"],
            IdealRoles:  ["Startup Founder", "Product Lead", "Venture Capitalist", "Business Development Manager", "Growth Strategist"]
        ),
        ["OPERATOR"] = new(
            Code:        "OPERATOR",
            Name:        "The Operator",
            Emoji:       "⚙️",
            Tagline:     "You are the force that keeps complex organisations running reliably.",
            Strengths:   ["Process design", "Risk management", "Reliability", "Structured execution"],
            GrowthAreas: ["Embracing rapid unplanned change", "Creative ambiguity without a clear framework"],
            IdealRoles:  ["Operations Manager", "Project Manager", "Compliance Officer", "Supply Chain Manager", "Chief of Staff"]
        ),
    };

    public static CareerClusterProfile GetProfile(string code)
        => _profiles.TryGetValue(code, out var p)
            ? p
            : throw new KeyNotFoundException($"Unknown career cluster: '{code}'.");

    public static IReadOnlyDictionary<string, CareerClusterProfile> All => _profiles;
}
