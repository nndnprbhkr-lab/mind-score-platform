namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Scores a set of MPI (MindType Profile Inventory) responses and returns
/// the resulting personality profile.
/// </summary>
/// <remarks>
/// The MPI engine executes a deterministic, stateless pipeline:
/// <list type="number">
///   <item><b>Reversal</b> — questions whose ID ends with <c>_R</c> are reverse-scored using <c>6 − value</c>.</item>
///   <item><b>Grouping</b> — responses are bucketed by the 2-letter dimension prefix (EI, SN, TF, JP).</item>
///   <item><b>Normalisation</b> — each bucket's sum is scaled to a 0–100 percentage.</item>
///   <item><b>Pole determination</b> — percentage ≥ 50 → left pole; &lt; 50 → right pole.</item>
///   <item><b>Strength classification</b> — deviation from 50 is mapped to Slight / Moderate / Clear / Strong.</item>
///   <item><b>Type code</b> — dominant poles are concatenated (e.g. <c>EOLS</c>).</item>
///   <item><b>Profile lookup</b> — <c>MpiTypeProfileLibrary</c> maps the type code to narrative content.</item>
/// </list>
/// </remarks>
public interface IMpiScoringEngine
{
    /// <summary>
    /// Scores the given responses and returns the complete MPI personality result.
    /// </summary>
    /// <param name="responses">
    /// Flat list of question-ID / value pairs.  Question IDs carry their dimension
    /// prefix and optional reversal suffix (e.g. <c>EI_01</c>, <c>SN_03_R</c>).
    /// </param>
    /// <returns>
    /// An <see cref="MpiResult"/> containing the type code, profile narrative,
    /// dimension scores, and computed overall score.
    /// </returns>
    MpiResult Score(List<MpiResponseInput> responses);
}

/// <summary>
/// A single raw response submitted to the MPI scoring engine.
/// </summary>
public sealed class MpiResponseInput
{
    /// <summary>
    /// The question's coded identifier, e.g. <c>EI_01</c> or <c>SN_03_R</c>.
    /// The 2-letter prefix determines the dimension; the <c>_R</c> suffix
    /// signals that the item should be reverse-scored.
    /// </summary>
    public string QuestionId { get; set; } = string.Empty;

    /// <summary>
    /// The raw Likert response value (1 = Strongly Disagree, 5 = Strongly Agree).
    /// </summary>
    public int Value { get; set; }
}

/// <summary>
/// The complete scored output of the MPI assessment engine.
/// </summary>
public sealed class MpiResult
{
    /// <summary>Four-letter personality type code (e.g. <c>EOLS</c>).</summary>
    public string TypeCode { get; set; } = string.Empty;

    /// <summary>Human-readable personality type name (e.g. "The Strategist").</summary>
    public string TypeName { get; set; } = string.Empty;

    /// <summary>The archetype role label for this type.</summary>
    public string Role { get; set; } = string.Empty;

    /// <summary>Emoji representation of this personality type.</summary>
    public string Emoji { get; set; } = string.Empty;

    /// <summary>Short motivational tagline for this personality type.</summary>
    public string Tagline { get; set; } = string.Empty;

    /// <summary>Key behavioural strengths for this type.</summary>
    public string[] Strengths { get; set; } = [];

    /// <summary>Recommended personal development areas.</summary>
    public string[] GrowthAreas { get; set; } = [];

    /// <summary>Career paths that typically suit this personality type.</summary>
    public string[] CareerPaths { get; set; } = [];

    /// <summary>Description of how this type communicates with others.</summary>
    public string CommunicationStyle { get; set; } = string.Empty;

    /// <summary>Description of how this type approaches work and tasks.</summary>
    public string WorkStyle { get; set; } = string.Empty;

    /// <summary>Brand accent colour for this type (hex string).</summary>
    public string AccentColor { get; set; } = string.Empty;

    /// <summary>
    /// Overall normalised score (0–100), computed as the average of the four
    /// dimension percentages.
    /// </summary>
    public int OverallScore { get; set; }

    /// <summary>
    /// Per-dimension scores keyed by the server-side dimension name
    /// (e.g. <c>EnergySource</c>, <c>PerceptionMode</c>).
    /// </summary>
    public Dictionary<string, MpiDimensionScore> Dimensions { get; set; } = new();

    /// <summary>UTC timestamp when the scoring was completed.</summary>
    public DateTime CompletedAt { get; set; }
}

/// <summary>
/// The computed score for one of the four MPI personality dimensions.
/// </summary>
public sealed class MpiDimensionScore
{
    /// <summary>
    /// Normalised 0–100 percentage.  Values above 50 indicate the left pole
    /// is dominant; below 50, the right pole is dominant.
    /// </summary>
    public double Percentage { get; set; }

    /// <summary>The single-letter dominant pole (e.g. <c>E</c>, <c>R</c>).</summary>
    public string DominantPole { get; set; } = string.Empty;

    /// <summary>
    /// Strength of the preference — <c>Slight</c> (≤10 deviation from 50),
    /// <c>Moderate</c> (≤20), <c>Clear</c> (≤35), or <c>Strong</c> (&gt;35).
    /// </summary>
    public string Strength { get; set; } = string.Empty;
}
