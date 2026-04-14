using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Persistence;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Scores a MindScore submission for a given user and age band.
/// </summary>
/// <remarks>
/// Algorithm summary:
/// <list type="number">
///   <item>Load questions (filtered by age band and submitted question IDs) and norm references.</item>
///   <item>For each module: sum adjusted scores (reverse-scored items use <c>6 − value</c>).</item>
///   <item>Convert the per-module raw average to a percentile using <see cref="NormalCdf"/>
///     parameterised by the age-band norm table (mean, SD).</item>
///   <item>Composite score = Σ (percentile × weight), clamped to [0, 100].</item>
/// </list>
/// The normal CDF is approximated using the Abramowitz &amp; Stegun polynomial
/// (equation 7.1.26, max error 1.5 × 10⁻⁷) for efficiency without requiring
/// a numeric integration library.
/// </remarks>
public sealed class MindScoringEngine : IMindScoringEngine
{
    private readonly AppDbContext _db;

    public MindScoringEngine(AppDbContext db)
    {
        _db = db;
    }

    /// <inheritdoc/>
    public async Task<MindScoreResultDto> ScoreAsync(
        Guid userId,
        Guid ageBandId,
        IReadOnlyList<(Guid QuestionId, int Value)> responses,
        CancellationToken cancellationToken = default)
    {
        // Load questions for this age band (with module info)
        var questionIds = responses.Select(r => r.QuestionId).ToHashSet();
        var questions = await _db.Questions
            .Include(q => q.Module)
            .Where(q => q.AgeBandId == ageBandId
                     && questionIds.Contains(q.Id))
            .ToListAsync(cancellationToken);

        // Load norm references for this age band
        var norms = await _db.NormReferences
            .Include(n => n.Module)
            .Where(n => n.AgeBandId == ageBandId)
            .ToListAsync(cancellationToken);

        // Load weights for this age band
        var weightRows = await _db.AgeBandModuleWeights
            .Include(w => w.Module)
            .Where(w => w.AgeBandId == ageBandId)
            .ToListAsync(cancellationToken);

        var ageBand = await _db.AgeBands.FindAsync([ageBandId], cancellationToken);
        var ageBandName = ageBand?.Name ?? "Unknown";

        var responseMap = responses.ToDictionary(r => r.QuestionId, r => r.Value);

        // Group questions by module
        var byModule = questions
            .Where(q => q.ModuleId.HasValue && q.Module != null)
            .GroupBy(q => q.Module!.Name);

        var moduleResults = new List<MindScoreModuleResultDto>();
        double compositeScore = 0;

        foreach (var group in byModule)
        {
            var moduleName = group.Key;
            double rawSum = 0;
            int count = 0;

            foreach (var q in group)
            {
                if (!responseMap.TryGetValue(q.Id, out var val)) continue;
                var adjusted = q.IsReverseScored == true ? 6 - val : val;
                rawSum += adjusted;
                count++;
            }

            if (count == 0) continue;

            var rawScore = rawSum / count; // average per question (1–5 scale)

            var norm = norms.FirstOrDefault(n => n.Module?.Name == moduleName);
            var mean = norm?.Mean ?? 50.0;
            var sd = norm?.StandardDeviation ?? 15.0;

            // Convert raw (1-5 avg) to a 0-100 scaled value before percentile
            var scaled = (rawScore - 1) / 4.0 * 100.0;
            var percentile = NormalCdf(scaled, mean, sd) * 100.0;
            percentile = Math.Clamp(percentile, 1, 99);

            var weight = weightRows.FirstOrDefault(w => w.Module?.Name == moduleName)?.Weight ?? 0.2;
            var weightedScore = percentile * weight;
            compositeScore += weightedScore;

            moduleResults.Add(new MindScoreModuleResultDto(
                moduleName,
                Math.Round(scaled, 1),
                Math.Round(percentile, 1),
                Math.Round(weightedScore, 2),
                PercentileLabel(percentile)));
        }

        var overall = (int)Math.Clamp(Math.Round(compositeScore), 0, 100);

        return new MindScoreResultDto(
            userId,
            ageBandId,
            ageBandName,
            overall,
            ScoreTier(overall),
            moduleResults);
    }

    // ── NormalCdf (Abramowitz & Stegun approximation) ─────────────────────────

    private static double NormalCdf(double x, double mean, double sd)
    {
        if (sd <= 0) return 0.5;
        var z = (x - mean) / sd;
        return 0.5 * (1 + Erf(z / Math.Sqrt(2)));
    }

    private static double Erf(double x)
    {
        // A&S 7.1.26 — max error 1.5e-7
        const double a1 = 0.254829592;
        const double a2 = -0.284496736;
        const double a3 = 1.421413741;
        const double a4 = -1.453152027;
        const double a5 = 1.061405429;
        const double p  = 0.3275911;

        var sign = x < 0 ? -1 : 1;
        x = Math.Abs(x);
        var t = 1.0 / (1.0 + p * x);
        var poly = t * (a1 + t * (a2 + t * (a3 + t * (a4 + t * a5))));
        return sign * (1 - poly * Math.Exp(-x * x));
    }

    private static string PercentileLabel(double p) => p switch
    {
        >= 90 => "Exceptional",
        >= 75 => "Strong",
        >= 50 => "Developing",
        >= 25 => "Emerging",
        _     => "Foundational",
    };

    private static string ScoreTier(int score) => score switch
    {
        >= 85 => "Elite",
        >= 70 => "Advanced",
        >= 55 => "Proficient",
        >= 40 => "Developing",
        _     => "Foundational",
    };
}
