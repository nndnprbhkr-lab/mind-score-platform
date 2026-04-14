// Data models for the MindScore cognitive assessment results.
//
// MindScore measures performance across multiple cognitive and emotional
// modules (e.g. Emotional Intelligence, Working Memory, Focus).  Results are
// normalised against age-band norms so that a user's score reflects their
// standing relative to peers in the same age group.

// ─── MindScoreModuleResult ────────────────────────────────────────────────────

/// The scored result for a single cognitive module within a MindScore assessment.
///
/// Each assessment contains several modules (defined server-side per age band).
/// The [percentile] places the user within the norm distribution for their age
/// group, while [weightedScore] is the module's contribution to the overall
/// composite score.
class MindScoreModuleResult {
  /// Display name of the cognitive module (e.g. "Emotional Intelligence").
  final String moduleName;

  /// Average raw response score (1–5 Likert scale, reverse-scored where needed).
  ///
  /// Scaled to 0–100 before percentile conversion.
  final double rawScore;

  /// User's percentile rank within their age-band norm group (1–99).
  ///
  /// A percentile of 75 means the user scored higher than 75 % of their peers.
  final double percentile;

  /// Percentile multiplied by the module's configured weight.
  ///
  /// Weighted scores are summed to produce the composite [MindScoreResult.overallScore].
  final double weightedScore;

  /// Human-readable performance label derived from [percentile]:
  /// `Exceptional` (≥90), `Strong` (≥75), `Developing` (≥50),
  /// `Emerging` (≥25), or `Foundational` (<25).
  final String label;

  const MindScoreModuleResult({
    required this.moduleName,
    required this.rawScore,
    required this.percentile,
    required this.weightedScore,
    required this.label,
  });

  /// Deserialises a [MindScoreModuleResult] from the API JSON.
  factory MindScoreModuleResult.fromJson(Map<String, dynamic> j) =>
      MindScoreModuleResult(
        moduleName:    j['moduleName']    as String,
        rawScore:      (j['rawScore']     as num).toDouble(),
        percentile:    (j['percentile']   as num).toDouble(),
        weightedScore: (j['weightedScore'] as num).toDouble(),
        label:         j['label']         as String,
      );
}

// ─── MindScoreResult ──────────────────────────────────────────────────────────

/// The complete scored result for a MindScore cognitive assessment.
///
/// Constructed client-side from a [ResultModel] whose [typeCode] is
/// `MIND_SCORE`.  Holds the overall score tier, the age-band context, and the
/// individual module breakdowns displayed in the results screen.
class MindScoreResult {
  /// Name of the age band used for norm-referencing (e.g. "18–25").
  final String ageBandName;

  /// Tier classification based on the composite score:
  /// `Elite` (≥85), `Advanced` (≥70), `Proficient` (≥55),
  /// `Developing` (≥40), or `Foundational` (<40).
  final String tier;

  /// Overall composite score (0–100), computed as the weighted sum of all
  /// module percentiles.
  final int overallScore;

  /// Individual module results, ordered as returned by the API.
  final List<MindScoreModuleResult> modules;

  const MindScoreResult({
    required this.ageBandName,
    required this.tier,
    required this.overallScore,
    required this.modules,
  });

  /// Parses a [MindScoreResult] from a [ResultModel]'s raw JSON fields.
  ///
  /// [score] is the composite score, [dimensionScores] is the JSON list of
  /// module results, and [insights] is the map containing `ageBandName` and
  /// `tier`.  [typeName] is used as a fallback tier when `insights` is absent.
  factory MindScoreResult.fromResultModel({
    required double score,
    required List<dynamic>? dimensionScores,
    required Map<String, dynamic>? insights,
    required String typeName,
  }) {
    final ageBandName = insights?['ageBandName'] as String? ?? '';
    final tier = insights?['tier'] as String? ?? typeName;
    final modules = (dimensionScores ?? [])
        .cast<Map<String, dynamic>>()
        .map(MindScoreModuleResult.fromJson)
        .toList();

    return MindScoreResult(
      ageBandName:  ageBandName,
      tier:         tier,
      overallScore: score.round(),
      modules:      modules,
    );
  }
}
