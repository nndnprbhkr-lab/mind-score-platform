namespace MindScorePlatform.Domain.Enums;

/// <summary>
/// The context a user declares at the start of an assessment.
/// Drives question selection, report framing, and insight generation.
/// </summary>
public enum AssessmentContext
{
    /// <summary>Standard personality discovery — no specific life context.</summary>
    General = 0,

    /// <summary>Career decision-making, role fit, work environment analysis.</summary>
    Career = 1,

    /// <summary>Relationship dynamics, attachment patterns, communication style.</summary>
    Relationships = 2,

    /// <summary>Leadership growth, team impact, influence and derailer awareness.</summary>
    Leadership = 3,

    /// <summary>Personal development, values alignment, shadow work, growth patterns.</summary>
    PersonalDevelopment = 4
}
