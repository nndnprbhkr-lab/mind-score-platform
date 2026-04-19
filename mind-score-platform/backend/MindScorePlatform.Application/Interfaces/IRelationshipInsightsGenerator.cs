using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.DTOs.ContextInsights;

namespace MindScorePlatform.Application.Interfaces;

/// <summary>
/// Generates relationship-context insights from MPI dimension scores.
/// Derives: attachment style, conflict style, love languages, emotional needs,
/// compatibility patterns, defensive behaviors, communication scripts, growth edge,
/// and toxic pattern vulnerabilities.
/// </summary>
public interface IRelationshipInsightsGenerator
{
    /// <summary>
    /// Generates a complete RelationshipInsightsDto from MPI dimensions and type code.
    /// </summary>
    /// <param name="typeCode">The four-letter MPI type code (e.g., RIVS, EOLS).</param>
    /// <param name="dimensions">
    /// Scored dimensions keyed by name (EnergySource, PerceptionMode,
    /// DecisionStyle, LifeApproach) with Percentage, DominantPole, Strength.
    /// </param>
    /// <returns>
    /// A RelationshipInsightsDto with all 9 insight fields populated based on
    /// the type's inherent relationship psychology.
    /// </returns>
    RelationshipInsightsDto Generate(
        string typeCode,
        IReadOnlyDictionary<string, MpiDimensionScore> dimensions);
}
