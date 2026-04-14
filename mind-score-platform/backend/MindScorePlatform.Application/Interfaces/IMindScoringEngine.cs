using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Scores a MindScore cognitive assessment submission for a specific user
/// and age band.
/// </summary>
/// <remarks>
/// <para>
/// The MindScore engine applies a multi-step normalisation pipeline:
/// <list type="number">
///   <item>Load questions and norm references for the given age band.</item>
///   <item>For each module: sum adjusted scores (reverse-scored items use <c>6 - value</c>).</item>
///   <item>Convert the per-module raw average to a percentile using a normal CDF
///     parameterised by the age-band norm table (mean, SD).</item>
///   <item>Composite score = Σ (percentile × module weight), clamped to [0, 100].</item>
///   <item>Map composite score to a named tier (Elite / Advanced / Proficient / Developing / Foundational).</item>
/// </list>
/// </para>
/// </remarks>
public interface IMindScoringEngine
{
    /// <summary>
    /// Scores the given responses against the age-band norms.
    /// </summary>
    /// <param name="userId">The user's ID (included in the result DTO for traceability).</param>
    /// <param name="ageBandId">The age band used to filter questions and norms.</param>
    /// <param name="responses">
    /// A list of (QuestionId, Value) tuples where Value is the raw Likert integer (1–5).
    /// </param>
    /// <param name="cancellationToken">Propagated cancellation token.</param>
    /// <returns>
    /// A <see cref="MindScoreResultDto"/> containing the overall composite score,
    /// tier, age band name, and per-module breakdowns.
    /// </returns>
    Task<MindScoreResultDto> ScoreAsync(
        Guid userId,
        Guid ageBandId,
        IReadOnlyList<(Guid QuestionId, int Value)> responses,
        CancellationToken cancellationToken = default);
}
