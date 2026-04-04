import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum ShareFormat { square, story, wide }

// ─── Dimension metadata (static lookup) ──────────────────────────────────────

class MpiDimensionMeta {
  final String key;
  final String emoji;
  final String name;
  final String leftPole;
  final String leftWord;
  final String rightPole;
  final String rightWord;
  final Color leftColor;
  final Color rightColor;

  const MpiDimensionMeta({
    required this.key,
    required this.emoji,
    required this.name,
    required this.leftPole,
    required this.leftWord,
    required this.rightPole,
    required this.rightWord,
    required this.leftColor,
    required this.rightColor,
  });

  static const all = [
    MpiDimensionMeta(
      key: 'EnergySource',
      emoji: '⚡',
      name: 'Energy source',
      leftPole: 'E',
      leftWord: 'Expressive',
      rightPole: 'R',
      rightWord: 'Reflective',
      leftColor: Color(0xFFFF6B9D),
      rightColor: Color(0xFFA67CF0),
    ),
    MpiDimensionMeta(
      key: 'PerceptionMode',
      emoji: '👁',
      name: 'Perception mode',
      leftPole: 'O',
      leftWord: 'Observable',
      rightPole: 'I',
      rightWord: 'Intuitive',
      leftColor: Color(0xFF5DCAA5),
      rightColor: Color(0xFFA67CF0),
    ),
    MpiDimensionMeta(
      key: 'DecisionStyle',
      emoji: '⚖️',
      name: 'Decision style',
      leftPole: 'L',
      leftWord: 'Logical',
      rightPole: 'V',
      rightWord: 'Values-led',
      leftColor: Color(0xFFF5B740),
      rightColor: Color(0xFFFF6B9D),
    ),
    MpiDimensionMeta(
      key: 'LifeApproach',
      emoji: '🗂',
      name: 'Life approach',
      leftPole: 'S',
      leftWord: 'Structured',
      rightPole: 'A',
      rightWord: 'Adaptive',
      leftColor: Color(0xFF6B35C8),
      rightColor: Color(0xFF5DCAA5),
    ),
  ];

  static MpiDimensionMeta? forKey(String key) {
    for (final m in all) {
      if (m.key == key) return m;
    }
    return null;
  }

  Color colorForPole(String pole) =>
      pole == leftPole ? leftColor : rightColor;
}

// ─── Pole descriptions ────────────────────────────────────────────────────────

const Map<String, String> kPoleDescriptions = {
  'E': 'Energised by people, action and the external world. Thinks out loud.',
  'R': 'Energised by solitude, inner reflection and deep focus. Thinks before speaking.',
  'O': 'Focuses on concrete facts, present reality and hands-on experience.',
  'I': 'Drawn to patterns, future possibilities and abstract thinking.',
  'L': 'Decides using objective data, cause-effect analysis and rational criteria.',
  'V': 'Decides based on personal values, people impact and harmony.',
  'S': 'Prefers planning, organisation, clear decisions and definite closure.',
  'A': 'Prefers flexibility, spontaneity and keeping options open.',
};

const Map<String, String> kPoleFullNames = {
  'E': 'Expressive',
  'R': 'Reflective',
  'O': 'Observable',
  'I': 'Intuitive',
  'L': 'Logical',
  'V': 'Values-led',
  'S': 'Structured',
  'A': 'Adaptive',
};

// ─── Models ───────────────────────────────────────────────────────────────────

class MpiDimensionScore {
  final double percentage;
  final String dominantPole;
  final String strength;

  const MpiDimensionScore({
    required this.percentage,
    required this.dominantPole,
    required this.strength,
  });

  factory MpiDimensionScore.fromJson(Map<String, dynamic> j) =>
      MpiDimensionScore(
        percentage: (j['percentage'] as num).toDouble(),
        dominantPole: j['dominantPole'] as String,
        strength: j['strength'] as String,
      );
}

class MpiResult {
  final String id;
  final String testId;
  final String testName;
  final int overallScore;
  final String typeCode;
  final String typeName;
  final String emoji;
  final String tagline;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> careerPaths;
  final Map<String, MpiDimensionScore> dimensions;
  final DateTime completedAt;

  const MpiResult({
    required this.id,
    required this.testId,
    required this.testName,
    required this.overallScore,
    required this.typeCode,
    required this.typeName,
    required this.emoji,
    required this.tagline,
    required this.strengths,
    required this.growthAreas,
    required this.careerPaths,
    required this.dimensions,
    required this.completedAt,
  });

  factory MpiResult.fromJson(Map<String, dynamic> j) {
    final rawDims = j['dimensionScores'] as Map<String, dynamic>? ?? {};
    final dims = rawDims.map(
      (k, v) => MapEntry(k, MpiDimensionScore.fromJson(v as Map<String, dynamic>)),
    );

    final rawInsights = j['insights'] as Map<String, dynamic>? ?? {};
    List<String> parseList(String key) =>
        (rawInsights[key] as List<dynamic>? ?? []).cast<String>();

    return MpiResult(
      id: j['id'] as String,
      testId: j['testId'] as String,
      testName: j['testName'] as String? ?? 'MPI Assessment',
      overallScore: (j['score'] as num).toInt(),
      typeCode: j['typeCode'] as String? ?? '',
      typeName: j['typeName'] as String? ?? '',
      emoji: j['emoji'] as String? ?? '🧠',
      tagline: j['tagline'] as String? ?? '',
      strengths: parseList('strengths'),
      growthAreas: parseList('growthAreas'),
      careerPaths: parseList('careerPaths'),
      dimensions: dims,
      completedAt: DateTime.parse(j['createdAtUtc'] as String),
    );
  }

  /// Derive share token from id (last 8 chars)
  String get shareToken => id.replaceAll('-', '').substring(0, 8).toUpperCase();

  /// Ordered dimensions matching MpiDimensionMeta.all order
  List<MapEntry<MpiDimensionMeta, MpiDimensionScore>> get orderedDimensions {
    return MpiDimensionMeta.all
        .where((m) => dimensions.containsKey(m.key))
        .map((m) => MapEntry(m, dimensions[m.key]!))
        .toList();
  }
}
