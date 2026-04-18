using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services.Mpi;

/// <summary>
/// Detects ambiguous ("tension") dimensions from MPI scores and computes
/// per-dimension confidence values.
/// </summary>
/// <remarks>
/// A dimension is considered ambiguous when its strength is "Slight" —
/// meaning the normalised percentage is within 10 points of the neutral
/// centre (50).  These are the dimensions most likely to benefit from
/// AI-generated follow-up questions.
///
/// Confidence is a linear mapping of the deviation from 50:
///   deviation 0  → confidence 10  (completely neutral)
///   deviation 50 → confidence 99  (fully committed to one pole)
/// </remarks>
internal static class TensionDetector
{
    internal static (List<string> Tensions, Dictionary<string, int> Confidence) Detect(
        Dictionary<string, MpiDimensionScore> dimensions)
    {
        var tensions   = new List<string>();
        var confidence = new Dictionary<string, int>();

        foreach (var (name, score) in dimensions)
        {
            var deviation = Math.Abs(score.Percentage - 50.0);
            var conf      = (int)Math.Round(10 + (deviation / 50.0) * 89);
            confidence[name] = Math.Clamp(conf, 10, 99);

            if (score.Strength == "Slight")
            {
                tensions.Add(name switch
                {
                    "EnergySource"   => "Social energy is balanced — introvert and extrovert tendencies are nearly equal",
                    "PerceptionMode" => "Information style is split — practical and imaginative tendencies are nearly equal",
                    "DecisionStyle"  => "Decision approach is ambiguous — logic and values carry near-equal weight",
                    "LifeApproach"   => "Planning preference is unresolved — structured and adaptive styles are in tension",
                    _                => $"{name} preference is near-neutral",
                });
            }
        }

        return (tensions, confidence);
    }
}
