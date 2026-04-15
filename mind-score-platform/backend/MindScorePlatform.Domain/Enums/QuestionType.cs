namespace MindScorePlatform.Domain.Enums;

/// <summary>
/// The format in which a question is presented and answered.
/// </summary>
public enum QuestionType
{
    /// <summary>
    /// Standard 5-point Likert scale (Strongly Disagree → Strongly Agree).
    /// Default for all existing MPI and MindScore questions.
    /// </summary>
    Likert = 0,

    /// <summary>
    /// Situational Judgment Test (SJT) format.
    /// Presents a realistic scenario with 4–5 concrete options.
    /// Each option maps secretly to personality trait scores via ScenarioOptionsJson.
    /// Triggered for age band 18–35 and/or Career or Leadership contexts.
    /// </summary>
    Scenario = 1,

    /// <summary>
    /// AI-generated personalised follow-up question.
    /// Created dynamically by the AiFollowUpService after initial scoring.
    /// Targets detected tensions or low-confidence dimensions.
    /// </summary>
    FollowUp = 2
}
