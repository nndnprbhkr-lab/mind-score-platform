using MindScorePlatform.Application.Interfaces;

namespace MindScorePlatform.Infrastructure.Services.Mpi;

/// <summary>
/// Implements the MPI (MindType Profile Inventory) scoring algorithm.
/// </summary>
/// <remarks>
/// The engine is stateless and synchronous — it performs only in-memory
/// arithmetic with no database access.  See <see cref="IMpiScoringEngine"/>
/// for the full nine-step algorithm description.
/// </remarks>
public sealed class MpiScoringEngine : IMpiScoringEngine
{
    /// <inheritdoc/>
    public MpiResult Score(List<MpiResponseInput> responses)
    {
        // STEP 1 — REVERSAL
        var adjusted = responses.Select(r => new
        {
            r.QuestionId,
            AdjustedScore = r.QuestionId.EndsWith("_R") ? 6 - r.Value : r.Value
        }).ToList();

        // STEP 2 — DIMENSION GROUPING
        var groups = new Dictionary<string, List<int>>
        {
            ["EI"] = new(),
            ["SN"] = new(),
            ["TF"] = new(),
            ["JP"] = new(),
        };

        foreach (var item in adjusted)
        {
            var prefix = item.QuestionId.Length >= 2 ? item.QuestionId[..2] : string.Empty;
            if (groups.TryGetValue(prefix, out var bucket))
                bucket.Add(item.AdjustedScore);
        }

        // STEP 3 — RAW SCORE & NORMALISATION
        // Maps the bucket sum from [count×1, count×5] to [0, 100].
        // A bucket with no responses defaults to 50 (neutral centre).
        var percentages = new Dictionary<string, double>();
        foreach (var (prefix, scores) in groups)
        {
            if (scores.Count == 0)
            {
                percentages[prefix] = 50.0;
                continue;
            }
            int raw = scores.Sum();
            int min = scores.Count * 1;
            int max = scores.Count * 5;
            percentages[prefix] = ((double)(raw - min) / (max - min)) * 100.0;
        }

        // STEP 4 — POLE DETERMINATION
        string EIPole = percentages["EI"] >= 50 ? "E" : "R";
        string SNPole = percentages["SN"] >= 50 ? "O" : "I";
        string TFPole = percentages["TF"] >= 50 ? "L" : "V";
        string JPPole = percentages["JP"] >= 50 ? "S" : "A";

        // STEP 5 — STRENGTH CLASSIFICATION
        var dimensions = new Dictionary<string, MpiDimensionScore>
        {
            ["EnergySource"]   = new() { Percentage = percentages["EI"], DominantPole = EIPole, Strength = TensionDetector.ClassifyStrength(percentages["EI"]) },
            ["PerceptionMode"] = new() { Percentage = percentages["SN"], DominantPole = SNPole, Strength = TensionDetector.ClassifyStrength(percentages["SN"]) },
            ["DecisionStyle"]  = new() { Percentage = percentages["TF"], DominantPole = TFPole, Strength = TensionDetector.ClassifyStrength(percentages["TF"]) },
            ["LifeApproach"]   = new() { Percentage = percentages["JP"], DominantPole = JPPole, Strength = TensionDetector.ClassifyStrength(percentages["JP"]) },
        };

        // STEP 6 — TYPE CODE CONSTRUCTION
        string typeCode = EIPole + SNPole + TFPole + JPPole;

        // STEP 7 — PROFILE LOOKUP
        var profile = MpiTypeProfileLibrary.GetProfile(typeCode);

        // STEP 8 — OVERALL SCORE
        int overallScore = (int)Math.Round(percentages.Values.Average());

        // STEP 9 — BUILD RESULT
        return new MpiResult
        {
            TypeCode           = typeCode,
            TypeName           = profile.TypeName,
            Role               = profile.Role,
            Emoji              = profile.Emoji,
            Tagline            = profile.Tagline,
            Strengths          = profile.Strengths,
            GrowthAreas        = profile.GrowthAreas,
            CareerPaths        = profile.CareerPaths,
            CommunicationStyle = profile.CommunicationStyle,
            WorkStyle          = profile.WorkStyle,
            AccentColor        = profile.AccentColor,
            OverallScore       = overallScore,
            Dimensions         = dimensions,
            CompletedAt        = DateTime.UtcNow,
        };
    }
}
