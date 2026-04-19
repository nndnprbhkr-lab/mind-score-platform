using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services.Mpi;

/// <summary>
/// Generates a personalised, prioritised action plan from an MPI result.
/// </summary>
/// <remarks>
/// <para>
/// Each of the four MPI dimensions maps to one concrete, actionable step.
/// The step's title and body are chosen based on the user's dominant pole
/// for that dimension, so the advice is tailored to their specific profile.
/// </para>
/// <para>
/// Steps are ranked by the magnitude of the user's deviation from the centre
/// (50 %) on each dimension.  A strong preference (e.g. 85 % Expressive)
/// surfaces the associated action higher in the list than a slight preference
/// (e.g. 55 % Expressive), because strongly-held traits have the greatest
/// impact on behaviour and therefore the greatest potential for improvement.
/// </para>
/// </remarks>
public sealed class MpiActionPlanEngine : IMpiActionPlanEngine
{
    /// <summary>
    /// Generates an ordered action plan for the given MPI result.
    /// </summary>
    /// <param name="resultId">The result ID associated with this plan.</param>
    /// <param name="typeCode">The four-letter MPI type code (informational only; routing is by dimension data).</param>
    /// <param name="dimensions">
    /// Scored dimensions keyed by name (EnergySource, PerceptionMode,
    /// DecisionStyle, LifeApproach).  Missing dimensions are skipped.
    /// </param>
    /// <returns>
    /// An <see cref="ActionPlanDto"/> with steps ordered by descending
    /// deviation from neutral — the most pronounced traits first.
    /// </returns>
    public ActionPlanDto Generate(
        Guid resultId,
        string typeCode,
        IReadOnlyDictionary<string, MpiDimensionScore> dimensions)
    {
        var steps = new List<(ActionPlanStepDto Step, double Deviation)>();

        // EnergySource — social interaction vs solitary focus.
        if (dimensions.TryGetValue("EnergySource", out var energy))
        {
            var isE = energy.DominantPole == "E";
            steps.Add((new ActionPlanStepDto
            {
                Icon  = "⚡",
                Title = isE
                    ? "Book a team brainstorm this week"
                    : "Block 90 min of deep focus daily",
                Body  = isE
                    ? "Your expressive energy peaks in group settings — schedule one collaborative session to drive a stuck problem forward."
                    : "Your reflective style means uninterrupted time is your highest-leverage resource — protect it before others fill it.",
                TraitLabel = $"EnergySource · {energy.DominantPole} · {energy.Strength}",
            }, Math.Abs(energy.Percentage - 50)));
        }

        // PerceptionMode — concrete facts vs abstract patterns.
        if (dimensions.TryGetValue("PerceptionMode", out var perception))
        {
            var isO = perception.DominantPole == "O";
            steps.Add((new ActionPlanStepDto
            {
                Icon  = "👁",
                Title = isO
                    ? "Run a quick user or data check"
                    : "Map out a 6-month possibility space",
                Body  = isO
                    ? "Before your next decision, pull one concrete data point — your observable instinct is strongest when grounded in evidence."
                    : "Give your intuitive mind room to explore: spend 30 minutes sketching futures without constraints or criticism.",
                TraitLabel = $"PerceptionMode · {perception.DominantPole} · {perception.Strength}",
            }, Math.Abs(perception.Percentage - 50)));
        }

        // DecisionStyle — objective analysis vs people-centred values.
        if (dimensions.TryGetValue("DecisionStyle", out var decision))
        {
            var isL = decision.DominantPole == "L";
            steps.Add((new ActionPlanStepDto
            {
                Icon  = "⚖️",
                Title = isL
                    ? "Present your next idea with data first"
                    : "Name the human impact in your next pitch",
                Body  = isL
                    ? "Frame your next proposal around numbers and outcomes — your logical lens lands best when the evidence leads the room."
                    : "Lead with who benefits and how — your values-led style is most persuasive when people, not process, take centre stage.",
                TraitLabel = $"DecisionStyle · {decision.DominantPole} · {decision.Strength}",
            }, Math.Abs(decision.Percentage - 50)));
        }

        // LifeApproach — structured planning vs adaptive spontaneity.
        if (dimensions.TryGetValue("LifeApproach", out var life))
        {
            var isS = life.DominantPole == "S";
            steps.Add((new ActionPlanStepDto
            {
                Icon  = "🗂",
                Title = isS
                    ? "Build a 2-week sprint plan today"
                    : "Say yes to one unplanned opportunity",
                Body  = isS
                    ? "Your structured preference thrives with a clear runway — break your biggest current goal into daily steps this afternoon."
                    : "Your adaptive strength is momentum — deliberately leave one slot this week uncommitted and follow what energises you.",
                TraitLabel = $"LifeApproach · {life.DominantPole} · {life.Strength}",
            }, Math.Abs(life.Percentage - 50)));
        }

        // Rank by deviation from neutral — strongest preferences surface first.
        var sorted = steps
            .OrderByDescending(s => s.Deviation)
            .Select(s => s.Step)
            .ToList();

        return new ActionPlanDto
        {
            ResultId = resultId,
            Steps    = sorted,
        };
    }
}
