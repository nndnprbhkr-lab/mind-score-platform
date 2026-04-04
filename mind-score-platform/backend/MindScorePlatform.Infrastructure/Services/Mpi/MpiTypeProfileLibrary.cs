namespace MindScorePlatform.Infrastructure.Services.Mpi;

public sealed record MpiTypeProfile(
    string TypeCode,
    string TypeName,
    string Role,
    string Emoji,
    string Tagline,
    string[] Strengths,
    string[] GrowthAreas,
    string[] CareerPaths,
    string CommunicationStyle,
    string WorkStyle,
    string AccentColor);

internal static class MpiTypeProfileLibrary
{
    private static readonly Dictionary<string, MpiTypeProfile> Profiles = new()
    {
        ["EILS"] = new(
            TypeCode: "EILS",
            TypeName: "The Architect",
            Role: "Strategic Systems Builder",
            Emoji: "🏛",
            Tagline: "Visionary planners who build the frameworks others follow",
            Strengths: ["Strategic long-term thinking", "Natural system designer", "Decisive and highly organised", "Sees the big picture while managing detail"],
            GrowthAreas: ["Can be overly critical of others", "Struggles to delegate", "Needs to allow room for spontaneity"],
            CareerPaths: ["Systems Architect", "Product Strategist", "CTO / Engineering Director", "Management Consultant"],
            CommunicationStyle: "Direct and structured. Prefers written communication and detailed briefs. Dislikes small talk and values efficiency in conversation.",
            WorkStyle: "Plans thoroughly before acting. Drives projects to closure. Sets high standards for self and team.",
            AccentColor: "#6B35C8"),

        ["EILA"] = new(
            TypeCode: "EILA",
            TypeName: "The Trailblazer",
            Role: "Bold Innovator",
            Emoji: "🚀",
            Tagline: "Energetic visionaries who challenge the status quo relentlessly",
            Strengths: ["Infectious enthusiasm", "Rapid creative ideation", "Inspires action in others", "Sees opportunities others miss"],
            GrowthAreas: ["Can start more than they finish", "Impatient with process and detail", "May overlook others' feelings"],
            CareerPaths: ["Entrepreneur / Founder", "Creative Director", "Innovation Lead", "Venture Capitalist"],
            CommunicationStyle: "Animated and persuasive. Thinks out loud. Energised by brainstorming sessions and big-picture discussions.",
            WorkStyle: "Bursts of intense creative energy. Thrives in fast-moving, unstructured environments. Needs a strong detail-oriented partner.",
            AccentColor: "#FF6B9D"),

        ["EOLS"] = new(
            TypeCode: "EOLS",
            TypeName: "The Commander",
            Role: "Decisive Leader",
            Emoji: "⚡",
            Tagline: "Action-oriented leaders who deliver results through sheer will",
            Strengths: ["Bold decision-making under pressure", "Natural authority and presence", "Drives teams hard to deliver", "Cuts through ambiguity quickly"],
            GrowthAreas: ["Can be blunt to the point of alienating others", "May overlook emotional undercurrents", "Struggles to show vulnerability"],
            CareerPaths: ["CEO / Managing Director", "Operations Director", "Military / Emergency Services Leadership", "Sales Director"],
            CommunicationStyle: "Blunt, concise, and direct. Values efficiency over diplomacy. Gets frustrated by vagueness or indecision.",
            WorkStyle: "Leads from the front. Holds self and others to very high standards. Drives hard to complete objectives.",
            AccentColor: "#F5B740"),

        ["EOLA"] = new(
            TypeCode: "EOLA",
            TypeName: "The Performer",
            Role: "Dynamic Connector",
            Emoji: "🎭",
            Tagline: "Charismatic people-magnets who thrive in the spotlight",
            Strengths: ["Natural charisma and social magnetism", "Highly adaptable under pressure", "Reads the room with precision", "Energises teams and audiences"],
            GrowthAreas: ["Can avoid difficult or uncomfortable conversations", "May prioritise likability over hard truth", "Gets bored easily by routine"],
            CareerPaths: ["Sales Leader", "Public Speaker / Keynote", "Brand Ambassador", "Talent or Media Agent"],
            CommunicationStyle: "Warm, engaging, and story-driven. Thrives in group settings. Uses humour and energy to build rapport.",
            WorkStyle: "Action-oriented and people-focused. Loves variety and collaboration. Gets restless with solo or repetitive work.",
            AccentColor: "#FF6B9D"),

        ["EIVS"] = new(
            TypeCode: "EIVS",
            TypeName: "The Mentor",
            Role: "Inspiring Teacher",
            Emoji: "🌟",
            Tagline: "Empathetic guides who develop others with wisdom and warmth",
            Strengths: ["Deep empathy and emotional intelligence", "Inspiring and motivating communicator", "Naturally develops talent in others", "Creates psychological safety in teams"],
            GrowthAreas: ["Can be overly idealistic", "May avoid difficult feedback to preserve harmony", "Overextends self for others"],
            CareerPaths: ["Executive Coach", "HR / People Director", "University Professor", "Organisational Psychologist"],
            CommunicationStyle: "Warm, encouraging, and rich with stories. A natural listener. Creates space for others to open up.",
            WorkStyle: "Collaborative and people-first. Thrives when developing others. Avoids environments with high conflict or cold cultures.",
            AccentColor: "#5DCAA5"),

        ["EIVA"] = new(
            TypeCode: "EIVA",
            TypeName: "The Champion",
            Role: "People Advocate",
            Emoji: "🤝",
            Tagline: "Passionate advocates who fight for people and meaningful causes",
            Strengths: ["Exceptional people insight", "Persuasive when championing causes", "High emotional intelligence", "Builds loyal communities around shared values"],
            GrowthAreas: ["Can over-invest emotionally in others", "May ignore logical data in favour of values", "Struggles with objectivity under emotional stress"],
            CareerPaths: ["Non-profit / NGO Leader", "Therapist / Counsellor", "Community Manager", "DEI Leader"],
            CommunicationStyle: "Passionate, values-driven, and deeply personal. Can be idealistic. Avoids debate that feels like personal attack.",
            WorkStyle: "Works best when deeply aligned with personal values. Needs to believe in the mission to give full effort.",
            AccentColor: "#5DCAA5"),

        ["EOVS"] = new(
            TypeCode: "EOVS",
            TypeName: "The Host",
            Role: "Social Connector",
            Emoji: "🎪",
            Tagline: "Natural connectors who create belonging and joy wherever they go",
            Strengths: ["Instantly puts people at ease", "High emotional radar in social settings", "Remembers personal details about everyone", "Creates strong team culture"],
            GrowthAreas: ["Can prioritise harmony over necessary conflict", "May spread attention too thin across too many people", "Avoids being disliked at any cost"],
            CareerPaths: ["Event and Experience Manager", "Customer Experience Director", "PR and Communications Lead", "Hotel or Hospitality GM"],
            CommunicationStyle: "Warm, inclusive, and upbeat. Thrives in group conversations. Skilled at drawing out quieter voices.",
            WorkStyle: "Energised by people and social dynamics. Needs variety and human interaction. Depleted by solo work.",
            AccentColor: "#FF6B9D"),

        ["EOVA"] = new(
            TypeCode: "EOVA",
            TypeName: "The Entertainer",
            Role: "Joyful Energiser",
            Emoji: "✨",
            Tagline: "Spontaneous and fun-loving spirits who bring life to every room",
            Strengths: ["Infectious energy and humour", "Highly adaptable and unflappable", "Fully present in the moment", "Turns strangers into friends"],
            GrowthAreas: ["Can be impulsive", "May avoid deep emotional topics", "Struggles with long-term planning"],
            CareerPaths: ["Social Media Creator / Influencer", "Actor / Entertainer", "Events Host", "Brand Experience Designer"],
            CommunicationStyle: "Expressive, lively, and playful. Dislikes formality. Communicates through stories, jokes, and energy.",
            WorkStyle: "Needs freedom and variety. Gets bored by routine quickly. Thrives in creative, spontaneous environments.",
            AccentColor: "#FF6B9D"),

        ["RILS"] = new(
            TypeCode: "RILS",
            TypeName: "The Mastermind",
            Role: "Independent Strategist",
            Emoji: "🧩",
            Tagline: "Quiet architects of elegant solutions to complex problems",
            Strengths: ["Deep independent systems thinking", "Sees patterns and connections others miss", "Relentlessly competent and self-driven", "Sets extraordinarily high intellectual standards"],
            GrowthAreas: ["Can be dismissive of those who think differently", "Struggles with small talk and social niceties", "May be perceived as arrogant"],
            CareerPaths: ["Data Scientist / AI Researcher", "Chief Architect", "Strategic Advisor", "Academic Researcher"],
            CommunicationStyle: "Precise, minimal, and intellectually rigorous. Prefers depth over breadth. Dislikes surface-level conversation.",
            WorkStyle: "Works best in deep autonomous focus. Needs intellectual challenge to stay engaged. Has little patience for inefficiency.",
            AccentColor: "#A67CF0"),

        ["RILA"] = new(
            TypeCode: "RILA",
            TypeName: "The Visionary",
            Role: "Abstract Innovator",
            Emoji: "🔮",
            Tagline: "Imaginative explorers on the frontier of ideas and possibilities",
            Strengths: ["Highly original and unconventional thinking", "Connects distant and seemingly unrelated concepts", "Embraces complexity and ambiguity", "Natural inventor and futurist"],
            GrowthAreas: ["Can be impractical or lost in abstraction", "Struggles to move from idea to execution", "May neglect day-to-day responsibilities"],
            CareerPaths: ["UX Researcher / Design Strategist", "Inventor / Patent Holder", "Strategic Futurist Consultant", "Philosopher or Writer"],
            CommunicationStyle: "Thoughtful and abstract. Needs time to fully articulate ideas. Communicates in concepts and metaphors.",
            WorkStyle: "Follows inspiration. Needs unstructured space to think. Struggles in rigid corporate environments.",
            AccentColor: "#A67CF0"),

        ["ROLS"] = new(
            TypeCode: "ROLS",
            TypeName: "The Inspector",
            Role: "Meticulous Expert",
            Emoji: "🔍",
            Tagline: "Detail-driven perfectionists who guarantee quality and precision",
            Strengths: ["Exceptional eye for detail and inconsistency", "Highly reliable, consistent, and thorough", "Strong sense of duty and responsibility", "Excellent long-term follow-through"],
            GrowthAreas: ["Can be rigid or resistant to change", "May miss the forest for the trees", "Perceived as overly critical or inflexible"],
            CareerPaths: ["Quality Assurance Director", "Auditor / Forensic Accountant", "Legal / Compliance Officer", "Surgeon"],
            CommunicationStyle: "Precise, factual, and measured. Dislikes vagueness or ambiguity. Prefers written communication with clear structure.",
            WorkStyle: "Methodical and systematic. Follows established processes. Needs order and clarity to perform at their best.",
            AccentColor: "#6B35C8"),

        ["ROLA"] = new(
            TypeCode: "ROLA",
            TypeName: "The Craftsperson",
            Role: "Hands-on Problem Solver",
            Emoji: "🔧",
            Tagline: "Practical, adaptable doers who figure things out by doing them",
            Strengths: ["Remarkably calm in a crisis", "Natural troubleshooter with practical instincts", "Learns rapidly through direct experience", "Highly self-reliant and capable"],
            GrowthAreas: ["Can be dismissive of theory or long-term planning", "May resist committing to schedules", "Prefers action over communication"],
            CareerPaths: ["Engineer / Technician", "Surgeon / Paramedic", "Field Operations Specialist", "Special Forces / Crisis Response"],
            CommunicationStyle: "Minimal words. Prefers to demonstrate rather than explain. Highly action-oriented communication style.",
            WorkStyle: "Learns by doing. Needs concrete, practical problems to engage with. Dislikes bureaucracy.",
            AccentColor: "#F5B740"),

        ["RIVS"] = new(
            TypeCode: "RIVS",
            TypeName: "The Counsellor",
            Role: "Deep Empathy Guide",
            Emoji: "💜",
            Tagline: "Insightful, deeply caring, and quietly influential forces for good",
            Strengths: ["Exceptional and patient listener", "Reads people and emotions with rare depth", "Quietly but powerfully motivates others", "Holds deep personal values and integrity"],
            GrowthAreas: ["Can be overly private and hard to read", "May internalise stress and avoid seeking help", "Takes on too much of others' emotional pain"],
            CareerPaths: ["Clinical Psychologist", "Social Worker / Family Therapist", "Conflict Mediator / Arbitrator", "Pastoral Leader"],
            CommunicationStyle: "Gentle, thoughtful, and deeply private. Shares vulnerabilities only with deeply trusted individuals. Dislikes confrontation.",
            WorkStyle: "Needs meaningful work aligned with values. Thrives in small, trust-based teams with authentic culture.",
            AccentColor: "#5DCAA5"),

        ["RIVA"] = new(
            TypeCode: "RIVA",
            TypeName: "The Dreamer",
            Role: "Creative Idealist",
            Emoji: "🌙",
            Tagline: "Imaginative souls on a lifelong quest for meaning and beauty",
            Strengths: ["Rich, vivid inner world of ideas", "Deep personal values and moral compass", "Highly creative across multiple disciplines", "Brings profound depth and originality"],
            GrowthAreas: ["Can be overly self-critical and perfectionist", "May struggle to share ideas before they feel perfect", "Prone to getting lost in idealism"],
            CareerPaths: ["Writer / Novelist / Poet", "UX Designer / Visual Artist", "Music Composer", "Philosopher or Theologian"],
            CommunicationStyle: "Metaphorical, introspective, and poetic. Shares only with trusted people. Needs to feel psychologically safe.",
            WorkStyle: "Needs deep alignment between work and personal values. Works best with creative freedom and low conflict.",
            AccentColor: "#A67CF0"),

        ["ROVS"] = new(
            TypeCode: "ROVS",
            TypeName: "The Nurturer",
            Role: "Steadfast Supporter",
            Emoji: "🌱",
            Tagline: "Reliable, caring, practical pillars who hold everything and everyone together",
            Strengths: ["Deeply dependable and consistent", "Practical and attentive care for others", "Creates stability, harmony, and warmth", "Strong memory for people's needs and preferences"],
            GrowthAreas: ["May neglect own needs while caring for others", "Can be resistant to change and new approaches", "May avoid speaking up to preserve harmony"],
            CareerPaths: ["Nurse / Doctor / Healthcare Professional", "Primary School Teacher", "HR Business Partner", "Family or Community Support Worker"],
            CommunicationStyle: "Warm, patient, and traditional. Values harmony and avoids unnecessary conflict. Expresses care through practical acts.",
            WorkStyle: "Steady, loyal, and consistent. Thrives in stable environments with clear expectations. Deeply affected by team discord.",
            AccentColor: "#5DCAA5"),

        ["ROVA"] = new(
            TypeCode: "ROVA",
            TypeName: "The Mediator",
            Role: "Harmony Seeker",
            Emoji: "🕊",
            Tagline: "Peaceful, adaptable bridge-builders who unite what others divide",
            Strengths: ["Sees all sides of a situation with clarity", "Calms conflict naturally and effortlessly", "Accepting and non-judgemental of difference", "Creates inclusive, safe environments"],
            GrowthAreas: ["Can struggle to take a firm personal stance", "May be perceived as lacking conviction", "Avoids necessary conflict to the point of inaction"],
            CareerPaths: ["Professional Mediator / Arbitrator", "Diplomat / International Relations", "Counsellor / Social Worker", "Community Facilitator"],
            CommunicationStyle: "Gentle, inclusive, and diplomatic. Instinctively avoids taking strong sides. Skilled at reframing tension as opportunity.",
            WorkStyle: "Easygoing and collaborative. Needs a harmonious, inclusive environment. Becomes disengaged in high-conflict cultures.",
            AccentColor: "#5DCAA5"),
    };

    public static MpiTypeProfile GetProfile(string typeCode)
    {
        if (Profiles.TryGetValue(typeCode, out var profile))
            return profile;

        return Profiles
            .OrderBy(p => LevenshteinDistance(typeCode, p.Key))
            .First()
            .Value;
    }

    private static int LevenshteinDistance(string a, string b)
    {
        int[,] dp = new int[a.Length + 1, b.Length + 1];
        for (int i = 0; i <= a.Length; i++) dp[i, 0] = i;
        for (int j = 0; j <= b.Length; j++) dp[0, j] = j;
        for (int i = 1; i <= a.Length; i++)
        for (int j = 1; j <= b.Length; j++)
            dp[i, j] = a[i - 1] == b[j - 1]
                ? dp[i - 1, j - 1]
                : 1 + Math.Min(dp[i - 1, j - 1], Math.Min(dp[i - 1, j], dp[i, j - 1]));
        return dp[a.Length, b.Length];
    }
}