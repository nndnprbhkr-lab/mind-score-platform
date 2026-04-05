using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services.Mpi;

public sealed class MpiActionPlanEngine : IMpiActionPlanEngine
{
    public ActionPlanDto Generate(Guid resultId, string typeCode,
        IReadOnlyDictionary<string, MpiDimensionScoreData> dimensions)
    {
        var steps = new List<(ActionPlanStepDto Step, double Deviation)>();

        // EnergySource
        if (dimensions.TryGetValue("EnergySource", out var energy))
        {
            var isE = energy.DominantPole == "E";
            steps.Add((new ActionPlanStepDto
            {
                Icon = "⚡",
                Title = isE
                    ? "Book a team brainstorm this week"
                    : "Block 90 min of deep focus daily",
                Body = isE
                    ? "Your expressive energy peaks in group settings — schedule one collaborative session to drive a stuck problem forward."
                    : "Your reflective style means uninterrupted time is your highest-leverage resource — protect it before others fill it.",
                TraitLabel = $"EnergySource · {energy.DominantPole} · {energy.Strength}",
            }, Math.Abs(energy.Percentage - 50)));
        }

        // PerceptionMode
        if (dimensions.TryGetValue("PerceptionMode", out var perception))
        {
            var isO = perception.DominantPole == "O";
            steps.Add((new ActionPlanStepDto
            {
                Icon = "👁",
                Title = isO
                    ? "Run a quick user or data check"
                    : "Map out a 6-month possibility space",
                Body = isO
                    ? "Before your next decision, pull one concrete data point — your observable instinct is strongest when grounded in evidence."
                    : "Give your intuitive mind room to explore: spend 30 minutes sketching futures without constraints or criticism.",
                TraitLabel = $"PerceptionMode · {perception.DominantPole} · {perception.Strength}",
            }, Math.Abs(perception.Percentage - 50)));
        }

        // DecisionStyle
        if (dimensions.TryGetValue("DecisionStyle", out var decision))
        {
            var isL = decision.DominantPole == "L";
            steps.Add((new ActionPlanStepDto
            {
                Icon = "⚖️",
                Title = isL
                    ? "Present your next idea with data first"
                    : "Name the human impact in your next pitch",
                Body = isL
                    ? "Frame your next proposal around numbers and outcomes — your logical lens lands best when the evidence leads the room."
                    : "Lead with who benefits and how — your values-led style is most persuasive when people, not process, take centre stage.",
                TraitLabel = $"DecisionStyle · {decision.DominantPole} · {decision.Strength}",
            }, Math.Abs(decision.Percentage - 50)));
        }

        // LifeApproach
        if (dimensions.TryGetValue("LifeApproach", out var life))
        {
            var isS = life.DominantPole == "S";
            steps.Add((new ActionPlanStepDto
            {
                Icon = "🗂",
                Title = isS
                    ? "Build a 2-week sprint plan today"
                    : "Say yes to one unplanned opportunity",
                Body = isS
                    ? "Your structured preference thrives with a clear runway — break your biggest current goal into daily steps this afternoon."
                    : "Your adaptive strength is momentum — deliberately leave one slot this week uncommitted and follow what energises you.",
                TraitLabel = $"LifeApproach · {life.DominantPole} · {life.Strength}",
            }, Math.Abs(life.Percentage - 50)));
        }

        // Sort by deviation descending
        var sorted = steps
            .OrderByDescending(s => s.Deviation)
            .Select(s => s.Step)
            .ToList();

        return new ActionPlanDto
        {
            ResultId = resultId,
            Steps = sorted,
        };
    }
}
