class MindScoreModuleResult {
  final String moduleName;
  final double rawScore;
  final double percentile;
  final double weightedScore;
  final String label;

  const MindScoreModuleResult({
    required this.moduleName,
    required this.rawScore,
    required this.percentile,
    required this.weightedScore,
    required this.label,
  });

  factory MindScoreModuleResult.fromJson(Map<String, dynamic> j) =>
      MindScoreModuleResult(
        moduleName: j['moduleName'] as String,
        rawScore: (j['rawScore'] as num).toDouble(),
        percentile: (j['percentile'] as num).toDouble(),
        weightedScore: (j['weightedScore'] as num).toDouble(),
        label: j['label'] as String,
      );
}

class MindScoreResult {
  final String ageBandName;
  final String tier;
  final int overallScore;
  final List<MindScoreModuleResult> modules;

  const MindScoreResult({
    required this.ageBandName,
    required this.tier,
    required this.overallScore,
    required this.modules,
  });

  /// Parse from a ResultModel's raw fields.
  /// [dimensionScores] is the list of module results.
  /// [insights] contains ageBandName and tier.
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
      ageBandName: ageBandName,
      tier: tier,
      overallScore: score.round(),
      modules: modules,
    );
  }
}
