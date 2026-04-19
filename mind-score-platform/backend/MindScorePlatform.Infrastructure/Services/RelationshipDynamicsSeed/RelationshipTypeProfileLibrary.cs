namespace MindScorePlatform.Infrastructure.Services.RelationshipDynamicsSeed;

/// <summary>
/// Per-type relationship psychology profiles for 16 Relationship Dynamics types.
/// Derived from 4 binary dimensions: Attachment Security, Conflict Engagement, Emotional Openness, Love Language Preference.
/// 2^4 = 16 distinct archetypes with names, emojis, and per-type relationship guidance.
/// </summary>
internal sealed class RelationshipTypeProfileLibrary
{
    internal sealed record RelationshipTypeProfile(
        // Type identifier and display
        string Code,           // SETO, SETR, etc. (4-letter code from dimension poles)
        string Name,           // Display name
        string Emoji,          // Character representation
        string Tagline,        // One-sentence description

        // Psychology breakdown
        string AttachmentLabel,
        string ConflictLabel,
        string ExpressionLabel,
        string LoveLanguageLabel,

        // Personality snapshot
        string Overview,       // 2-3 sentence personality snapshot
        IReadOnlyList<string> Strengths,
        IReadOnlyList<string> GrowthAreas,
        IReadOnlyList<string> EmotionalNeeds,
        IReadOnlyList<string> DefensivePatterns,
        string RelationshipGrowthEdge
    );

    private static readonly Dictionary<string, RelationshipTypeProfile> Profiles = new()
    {
        // SECURE + ENGAGED + TRANSPARENT + PRACTICAL (SETP)
        ["SETP"] = new(
            Code: "SETP", Name: "The Secure Anchor", Emoji: "⚓",
            Tagline: "You build stable partnerships through openness and practical care.",
            AttachmentLabel: "Secure", ConflictLabel: "Engaged", ExpressionLabel: "Transparent", LoveLanguageLabel: "Practical",
            Overview: "You're the foundation of healthy relationships. Secure in yourself, you engage directly with problems, share openly, and show love through actions. Partners feel safe and valued.",
            Strengths: ["Reliable and consistent", "Handles conflict constructively", "Emotionally available", "Partner feels cared for and respected"],
            GrowthAreas: ["Can seem overly practical at times", "Might underestimate emotional reassurance needs of anxious partners"],
            EmotionalNeeds: ["Mutual respect and partnership", "Reliability from partner", "Shared growth and problem-solving"],
            DefensivePatterns: ["Rarely defensive; maintains calm during conflict"],
            RelationshipGrowthEdge: "Lean into emotional expressions beyond actions. Words matter too."
        ),

        // SECURE + ENGAGED + TRANSPARENT + EMOTIONAL (SETE)
        ["SETE"] = new(
            Code: "SETE", Name: "The Secure Advocate", Emoji: "💚",
            Tagline: "You bring emotional depth and directness to your partnerships.",
            AttachmentLabel: "Secure", ConflictLabel: "Engaged", ExpressionLabel: "Transparent", LoveLanguageLabel: "Emotional",
            Overview: "You're emotionally intelligent and secure. You speak your needs clearly, engage in conflict with care, and express affection openly. Partners feel deeply known.",
            Strengths: ["Emotionally articulate", "Conflict brings you closer together", "Generous with affection and words", "Creates deep emotional bonds"],
            GrowthAreas: ["Might overwhelm reserved partners with emotional intensity", "Can take lack of verbal reciprocation personally"],
            EmotionalNeeds: ["Emotional reciprocity and openness", "Deep conversations", "Verbal affirmation from partner"],
            DefensivePatterns: ["Talks things through immediately; may push partner before they're ready"],
            RelationshipGrowthEdge: "Honor your partner's pace. Deep conversations can't be rushed."
        ),

        // SECURE + ENGAGED + RESERVED + PRACTICAL (SETRP)
        ["SETRP"] = new(
            Code: "SETRP", Name: "The Secure Builder", Emoji: "🔨",
            Tagline: "You create steady, reliable partnerships through quiet consistency.",
            AttachmentLabel: "Secure", ConflictLabel: "Engaged", ExpressionLabel: "Reserved", LoveLanguageLabel: "Practical",
            Overview: "You're secure but private. You engage thoughtfully in conflicts, show love through consistent actions, and let your reliability speak louder than words. Partners trust you completely.",
            Strengths: ["Steady and dependable", "Solves problems methodically", "Doesn't escalate conflict emotionally", "Partner knows they can count on you"],
            GrowthAreas: ["Emotional distance can make partners feel unseen", "Reserved nature might not reassure anxious partners enough"],
            EmotionalNeeds: ["Space to think and process", "Recognition of effort", "Low-drama partnership"],
            DefensivePatterns: ["Withdraws to think when hurt; slow to verbally reassure"],
            RelationshipGrowthEdge: "Your partner needs to hear from you, not just see your actions."
        ),

        // SECURE + ENGAGED + RESERVED + EMOTIONAL (SETRЕ)
        ["SETRE"] = new(
            Code: "SETRE", Name: "The Secure Counselor", Emoji: "🤝",
            Tagline: "You bring patient wisdom and steady care to relationships.",
            AttachmentLabel: "Secure", ConflictLabel: "Engaged", ExpressionLabel: "Reserved", LoveLanguageLabel: "Emotional",
            Overview: "You're secure and emotionally aware but express feelings slowly. You listen deeply, engage in conflict thoughtfully, and love with quiet intensity. Partners feel understood.",
            Strengths: ["Patient and a good listener", "Thinks before speaking in conflict", "Emotionally intelligent but not overwhelming", "Partner feels truly heard"],
            GrowthAreas: ["Partner might not realize how you feel; they need to hear it sometimes", "Can seem detached when you're actually processing internally"],
            EmotionalNeeds: ["Time to process", "Deep one-on-one connection", "Partner patience with your pacing"],
            DefensivePatterns: ["Goes quiet to reflect; takes time to express feelings"],
            RelationshipGrowthEdge: "Share your emotional journey, not just the conclusion. The process matters."
        ),

        // SECURE + AVOIDING + TRANSPARENT + PRACTICAL (SAWTP)
        ["SAWTP"] = new(
            Code: "SAWTP", Name: "The Secure Independent", Emoji: "🦅",
            Tagline: "You maintain autonomy while showing up practically for your partner.",
            AttachmentLabel: "Secure", ConflictLabel: "Avoiding", ExpressionLabel: "Transparent", LoveLanguageLabel: "Practical",
            Overview: "You're secure but conflict-averse. You avoid heated disagreements, show openness about non-conflict topics, and prove your care through actions. Partners respect your independence.",
            Strengths: ["Doesn't create unnecessary conflict", "Transparent about your boundaries", "Dependable in practical ways", "Partner feels independent too"],
            GrowthAreas: ["Unresolved issues may build resentment silently", "Avoidance can leave partner feeling unheard in serious matters"],
            EmotionalNeeds: ["Space and autonomy", "Low-conflict environment", "Practical partnership"],
            DefensivePatterns: ["Changes subject when conflict arises", "Becomes distant when issues are forced"],
            RelationshipGrowthEdge: "Avoidance is temporary. Important issues need direct conversation."
        ),

        // SECURE + AVOIDING + TRANSPARENT + EMOTIONAL (SAWTE)
        ["SAWTE"] = new(
            Code: "SAWTE", Name: "The Secure Dreamer", Emoji: "✨",
            Tagline: "You bring openness and emotional idealism while maintaining distance from conflict.",
            AttachmentLabel: "Secure", ConflictLabel: "Avoiding", ExpressionLabel: "Transparent", LoveLanguageLabel: "Emotional",
            Overview: "You're secure and emotionally open but conflict-averse. You share feelings freely, express love openly, but steer away from disagreements. Partners feel emotionally safe but unheard in conflict.",
            Strengths: ["Emotionally generous and open", "Creates warm, connected feelings", "Doesn't bring negativity", "Partner feels appreciated"],
            GrowthAreas: ["Real problems get shelved instead of solved", "Partner may feel unheard when they bring concerns"],
            EmotionalNeeds: ["Emotional warmth and appreciation", "Harmony and positivity", "Reassurance they're valued"],
            DefensivePatterns: ["Changes subject to positive topics when conflict starts", "Becomes emotionally distant if forced to engage"],
            RelationshipGrowthEdge: "You can express feelings AND handle conflict. They're both necessary."
        ),

        // SECURE + AVOIDING + RESERVED + PRACTICAL (SAWRP)
        ["SAWRP"] = new(
            Code: "SAWRP", Name: "The Secure Operator", Emoji: "⚙️",
            Tagline: "You keep relationships running smoothly through independence and reliability.",
            AttachmentLabel: "Secure", ConflictLabel: "Avoiding", ExpressionLabel: "Reserved", LoveLanguageLabel: "Practical",
            Overview: "You're secure, independent, and pragmatic. You avoid conflict and emotional expression, leading with actions and reliability. Partners trust your consistency but may feel emotionally distant.",
            Strengths: ["Extremely reliable and consistent", "Doesn't create drama", "Handles logistics and planning well", "Partner feels supported"],
            GrowthAreas: ["Very emotionally unavailable; partner may feel like a roommate", "Issues that need discussion get ignored"],
            EmotionalNeeds: ["Independence and space", "Practical partnership", "Low emotional demands"],
            DefensivePatterns: ["Complete withdrawal from emotional topics", "Retreats to tasks when emotions are raised"],
            RelationshipGrowthEdge: "Your partner needs emotional connection beyond logistics. Show up for that too."
        ),

        // SECURE + AVOIDING + RESERVED + EMOTIONAL (SAWRE)
        ["SAWRE"] = new(
            Code: "SAWRE", Name: "The Secure Watcher", Emoji: "👁️",
            Tagline: "You observe and care deeply, but from a distance.",
            AttachmentLabel: "Secure", ConflictLabel: "Avoiding", ExpressionLabel: "Reserved", LoveLanguageLabel: "Emotional",
            Overview: "You're secure, emotionally attuned, but avoid conflict and self-disclosure. You notice your partner deeply but keep distance. Partners feel seen but struggle to see you.",
            Strengths: ["Notices partner's needs and feelings", "Doesn't create conflict or drama", "Emotionally intelligent observer", "Partner feels understood"],
            GrowthAreas: ["Partner doesn't know how you feel about them", "Conflict avoidance leaves real issues unresolved", "Can seem cold despite emotional attunement"],
            EmotionalNeeds: ["Space and observation", "Deep internal emotional life (unshared)", "Minimal conflict"],
            DefensivePatterns: ["Silent withdrawal when any conflict emerges", "Never shares own emotional world"],
            RelationshipGrowthEdge: "Let your partner see inside. Your inner world matters too."
        ),

        // ANXIOUS-AVOIDANT + ENGAGED + TRANSPARENT + PRACTICAL (IETEPM)
        ["IETEPM"] = new(
            Code: "IETEPM", Name: "The Anxious Pursuer", Emoji: "🔄",
            Tagline: "You pursue connection directly, but fear the answer.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Engaged", ExpressionLabel: "Transparent", LoveLanguageLabel: "Practical",
            Overview: "You're insecure and chase closeness, but engage directly when problems arise. You're transparent about needs and show care through action. Conflict cycles are exhausting.",
            Strengths: ["Direct about your needs", "Willing to problem-solve", "Caring and action-oriented", "Wants to move forward"],
            GrowthAreas: ["Anxious pursuit pushes partners away", "Conflict engagement can become reactive and emotional", "Needs frequent reassurance"],
            EmotionalNeeds: ["Constant reassurance", "Frequent connection and contact", "Clear evidence of commitment"],
            DefensivePatterns: ["Escalates when feeling dismissed", "Pursues more intensely when partner withdraws"],
            RelationshipGrowthEdge: "Reassurance comes from consistency, not pursuit. Step back and watch."
        ),

        // ANXIOUS-AVOIDANT + ENGAGED + TRANSPARENT + EMOTIONAL (IETETE)
        ["IETETE"] = new(
            Code: "IETETE", Name: "The Anxious Advocate", Emoji: "💔",
            Tagline: "You bring emotional intensity and a desperate need to be understood.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Engaged", ExpressionLabel: "Transparent", LoveLanguageLabel: "Emotional",
            Overview: "You're insecure and crave emotional closeness. You engage intensely in conflict, express feelings openly, and love passionately. Partners feel pursued and overwhelmed.",
            Strengths: ["Deeply feeling and expressive", "Willing to engage in big conversations", "Passionate and committed", "Wants deep connection"],
            GrowthAreas: ["Emotional intensity can overwhelm reserved partners", "Conflict becomes about reassurance-seeking, not problem-solving", "May guilt partner for not reciprocating intensity"],
            EmotionalNeeds: ["Constant emotional reassurance", "Proof of love and commitment", "Deep constant connection"],
            DefensivePatterns: ["Escalates emotionally in conflict to get partner's attention", "Threatens to leave when feeling rejected"],
            RelationshipGrowthEdge: "Your intensity is real, but it's scaring away the people you want closest."
        ),

        // ANXIOUS-AVOIDANT + ENGAGED + RESERVED + PRACTICAL (IETRP)
        ["IETRP"] = new(
            Code: "IETRP", Name: "The Anxious Builder", Emoji: "🏗️",
            Tagline: "You work hard to create security but doubt you'll succeed.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Engaged", ExpressionLabel: "Reserved", LoveLanguageLabel: "Practical",
            Overview: "You're insecure but pragmatic. You engage in conflict to solve problems, show love through actions, but rarely voice your anxiety. Partners see your effort but not your doubt.",
            Strengths: ["Action-oriented and practical", "Wants to solve problems directly", "Shows care through consistent work", "Reliable despite inner doubt"],
            GrowthAreas: ["Inner anxiety not expressed makes partner unaware", "Bottled worry can suddenly explode", "Doesn't ask for reassurance directly"],
            EmotionalNeeds: ["Recognition of effort", "Subtle reassurance without asking", "Stability through consistency"],
            DefensivePatterns: ["Works harder when feeling insecure", "Explodes when effort goes unrecognized"],
            RelationshipGrowthEdge: "Ask for reassurance instead of hoping partner notices your doubt."
        ),

        // ANXIOUS-AVOIDANT + ENGAGED + RESERVED + EMOTIONAL (IETRE)
        ["IETRE"] = new(
            Code: "IETRE", Name: "The Anxious Counselor", Emoji: "💭",
            Tagline: "You care deeply but fear burdening others with your feelings.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Engaged", ExpressionLabel: "Reserved", LoveLanguageLabel: "Emotional",
            Overview: "You're insecure and emotionally attuned. You engage in conflict thoughtfully, notice partner's needs, but hide your own anxiety. Partners feel cared for but may not see your pain.",
            Strengths: ["Emotionally intelligent", "Wants to understand partner", "Engages thoughtfully in conflict", "Genuinely caring"],
            GrowthAreas: ["Hides insecurity until it explodes", "Martyrs self by not sharing own needs", "Resentment builds silently"],
            EmotionalNeeds: ["Reassurance that feelings won't burden partner", "Safe space to share fears", "Mutual emotional vulnerability"],
            DefensivePatterns: ["Over-accommodates then suddenly withdraws", "Expresses hurt through silent resentment"],
            RelationshipGrowthEdge: "Your feelings matter. Share them before resentment sets in."
        ),

        // ANXIOUS-AVOIDANT + AVOIDING + TRANSPARENT + PRACTICAL (IAWTP)
        ["IAWTP"] = new(
            Code: "IAWTP", Name: "The Avoidant Achiever", Emoji: "🎯",
            Tagline: "You're driven to build something stable, but fear getting close enough to enjoy it.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Avoiding", ExpressionLabel: "Transparent", LoveLanguageLabel: "Practical",
            Overview: "You're insecure but action-oriented. You avoid conflict and emotional depth, show love through effort, and stay transparent about your boundaries. Partners feel kept at arm's length.",
            Strengths: ["Reliable and productive", "Clear about boundaries", "Doesn't create drama", "Provides stability"],
            GrowthAreas: ["Distance keeps intimacy away", "Conflict never gets resolved", "Partner feels like they don't matter as much as tasks"],
            EmotionalNeeds: ["Space and low demands", "Practical partnership", "Recognition for work done"],
            DefensivePatterns: ["Throws himself into work when relationship gets close", "Becomes irritable if intimacy is pushed"],
            RelationshipGrowthEdge: "Closeness isn't a threat. Practice vulnerability with someone safe."
        ),

        // ANXIOUS-AVOIDANT + AVOIDING + TRANSPARENT + EMOTIONAL (IAWTE)
        ["IAWTE"] = new(
            Code: "IAWTE", Name: "The Avoidant Dreamer", Emoji: "🌙",
            Tagline: "You want closeness desperately but sabotage it when you find it.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Avoiding", ExpressionLabel: "Transparent", LoveLanguageLabel: "Emotional",
            Overview: "You're insecure and push-pull. You seek emotional connection, share openly, but flee when it gets real. You avoid conflict by disappearing. Partners are confused and hurt.",
            Strengths: ["Emotionally expressive when present", "Seeks deep connection", "Transparent about feelings when sharing", "Creative and passionate"],
            GrowthAreas: ["Sabotage patterns when things get real", "Avoidance through disappearing damages partner trust", "Hot-cold cycling is exhausting"],
            EmotionalNeeds: ["Reassurance that intimacy is safe", "Consistency that doesn't expect immediate commitment", "Permission to go slowly"],
            DefensivePatterns: ["Pursues intensely then vanishes when partner reciprocates", "Creates drama to feel in control"],
            RelationshipGrowthEdge: "You're running from yourself, not your partner. Face your fear of intimacy."
        ),

        // ANXIOUS-AVOIDANT + AVOIDING + RESERVED + PRACTICAL (IAWRP)
        ["IAWRP"] = new(
            Code: "IAWRP", Name: "The Withdrawn Operator", Emoji: "🔧",
            Tagline: "You're competent on your own, but deeply lonely.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Avoiding", ExpressionLabel: "Reserved", LoveLanguageLabel: "Practical",
            Overview: "You're insecure but self-reliant. You avoid conflict and emotional expression, show love through practical support only. Partners feel needed but not known.",
            Strengths: ["Fiercely independent and capable", "Solves problems alone", "Doesn't create conflict", "Reliable when you're around"],
            GrowthAreas: ["Extreme isolation despite wanting connection", "Never lets partner help or know you", "Appears cold and distant"],
            EmotionalNeeds: ["Practical help (paradoxically)", "Partnership without demands", "To be needed"],
            DefensivePatterns: ["Complete withdrawal when threatened", "Never discusses feelings or needs"],
            RelationshipGrowthEdge: "You don't have to do it alone. Vulnerability is strength, not weakness."
        ),

        // ANXIOUS-AVOIDANT + AVOIDING + RESERVED + EMOTIONAL (IAWRE)
        ["IAWRE"] = new(
            Code: "IAWRE", Name: "The Disorganized Dreamer", Emoji: "🌪️",
            Tagline: "You oscillate between desperate need and complete withdrawal.",
            AttachmentLabel: "Anxious-Avoidant", ConflictLabel: "Avoiding", ExpressionLabel: "Reserved", LoveLanguageLabel: "Emotional",
            Overview: "You're insecure and fearful-avoidant. You want closeness but fear it, avoid conflict by disappearing, and express emotions erratically. Relationships feel unstable and chaotic.",
            Strengths: ["Capable of deep feeling", "Seeks connection", "Self-aware when stable", "Passionate when present"],
            GrowthAreas: ["Relationship chaos from push-pull patterns", "Partner never knows which version of you will show up", "Self-sabotage when things are good"],
            EmotionalNeeds: ["Safety and predictability", "Patience with hot-cold cycling", "Professional support"],
            DefensivePatterns: ["Extreme emotional distance or clinginess with no middle ground", "Sabotages when relationship feels too real"],
            RelationshipGrowthEdge: "Work on your relationship with yourself first. Then relationships become possible."
        ),
    };

    internal static RelationshipTypeProfile GetProfile(string typeCode)
    {
        if (Profiles.TryGetValue(typeCode, out var profile))
        {
            return profile;
        }

        // Fallback: return first secure profile as safety default
        return Profiles["SETP"];
    }
}
