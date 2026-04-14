// MPI (MindType Profile Inventory) data models.
//
// The MPI is a four-dimension personality model.  Each dimension has two poles
// that a user tends towards based on their Likert-scale responses.  The four
// dimensions and their poles are:
//   EnergySource  — Expressive (E) vs Reflective (R)
//   PerceptionMode — Observable (O) vs Intuitive (I)
//   DecisionStyle  — Logical (L) vs Values-led (V)
//   LifeApproach   — Structured (S) vs Adaptive (A)
//
// Combining the dominant pole from each dimension yields a 4-letter type code
// such as "EOLS" which maps to a named profile in the type library.

import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

/// The format to use when generating a shareable image of MPI results.
enum ShareFormat {
  /// 1:1 square card — suitable for Instagram / general social media.
  square,

  /// 9:16 story format — suitable for Instagram / Snapchat stories.
  story,

  /// 16:9 wide banner — suitable for Twitter / LinkedIn posts.
  wide,
}

// ─── MpiDimensionMeta ─────────────────────────────────────────────────────────

/// Static metadata describing one of the four MPI personality dimensions.
///
/// [MpiDimensionMeta.all] provides the canonical ordered list of all four
/// dimensions.  This order is used consistently across radar charts, legend
/// rows, and other dimension displays.
class MpiDimensionMeta {
  /// Internal key matching the server-side dimension name (e.g. `EnergySource`).
  final String key;

  /// Emoji icon representing the dimension in the UI.
  final String emoji;

  /// Display name shown in the legend (e.g. "Energy source").
  final String name;

  /// Single-letter code for the left pole (e.g. `E` for Expressive).
  final String leftPole;

  /// Full word for the left pole (e.g. "Expressive").
  final String leftWord;

  /// Single-letter code for the right pole (e.g. `R` for Reflective).
  final String rightPole;

  /// Full word for the right pole (e.g. "Reflective").
  final String rightWord;

  /// Accent colour for the left pole.
  final Color leftColor;

  /// Accent colour for the right pole.
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

  /// The canonical ordered list of all four MPI dimensions.
  ///
  /// The order here is the authoritative display order used by radar charts
  /// and dimension row widgets.
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

  /// Returns the [MpiDimensionMeta] for the given server-side [key], or `null`
  /// if no match is found.
  static MpiDimensionMeta? forKey(String key) {
    for (final m in all) {
      if (m.key == key) return m;
    }
    return null;
  }

  /// Returns the accent colour for the given [pole] letter.
  ///
  /// Returns [leftColor] if [pole] matches [leftPole], otherwise [rightColor].
  Color colorForPole(String pole) =>
      pole == leftPole ? leftColor : rightColor;
}

// ─── Pole description lookups ──────────────────────────────────────────────────

/// Maps each pole letter to a short behavioural description shown in tooltips.
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

/// Maps each pole letter to its full descriptive word for display purposes.
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

// ─── MpiDimensionScore ────────────────────────────────────────────────────────

/// The computed score for a single MPI personality dimension.
///
/// [percentage] represents how strongly the user expresses the left-pole
/// behaviour (0 = entirely right-pole, 100 = entirely left-pole, 50 = neutral).
/// [dominantPole] is the single letter of the pole with higher expression.
class MpiDimensionScore {
  /// Normalised score on a 0–100 scale.
  ///
  /// Values above 50 indicate the left pole is dominant; below 50, the right
  /// pole is dominant.  The distance from 50 determines [strength].
  final double percentage;

  /// The dominant pole letter for this dimension (e.g. `E`, `R`, `O`, etc.).
  final String dominantPole;

  /// Strength classification based on deviation from centre:
  /// `Slight` (≤10), `Moderate` (≤20), `Clear` (≤35), or `Strong` (>35).
  final String strength;

  const MpiDimensionScore({
    required this.percentage,
    required this.dominantPole,
    required this.strength,
  });

  /// Deserialises from API JSON, handling both camelCase and PascalCase keys
  /// for resilience against different serialisation configurations.
  factory MpiDimensionScore.fromJson(Map<String, dynamic> j) =>
      MpiDimensionScore(
        percentage:    ((j['percentage']  ?? j['Percentage'])  as num).toDouble(),
        dominantPole:  (j['dominantPole'] ?? j['DominantPole']) as String,
        strength:      (j['strength']     ?? j['Strength'])     as String,
      );
}

// ─── MpiResult ────────────────────────────────────────────────────────────────

/// The complete scored result for an MPI (MindType Profile Inventory) assessment.
///
/// Constructed from a [ResultModel] whose [hasMpiData] is `true`.  Provides
/// all the data needed to render the full results screen including the radar
/// chart, dimension rows, insight cards, and action plan.
class MpiResult {
  /// Unique result identifier (UUID).
  final String id;

  /// Identifier of the parent assessment.
  final String testId;

  /// Human-readable assessment name.
  final String testName;

  /// Overall normalised score (0–100), computed as the average of all four
  /// dimension percentages.
  final int overallScore;

  /// Four-letter personality type code (e.g. `EOLS`, `RISA`).
  ///
  /// Constructed by concatenating the dominant pole from each dimension in
  /// the order: EnergySource, PerceptionMode, DecisionStyle, LifeApproach.
  final String typeCode;

  /// Human-readable name for this type profile (e.g. "The Strategist").
  final String typeName;

  /// Emoji associated with this personality type.
  final String emoji;

  /// Short motivational tagline for the personality type.
  final String tagline;

  /// Key strengths associated with this personality type.
  final List<String> strengths;

  /// Areas recommended for personal development.
  final List<String> growthAreas;

  /// Career paths that typically suit this personality type.
  final List<String> careerPaths;

  /// Describes how this personality type typically communicates with others.
  final String communicationStyle;

  /// Describes how this personality type typically approaches work.
  final String workStyle;

  /// Scored results for each of the four personality dimensions, keyed by
  /// the server-side dimension name (e.g. `EnergySource`).
  final Map<String, MpiDimensionScore> dimensions;

  /// UTC timestamp when the assessment was completed.
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
    this.communicationStyle = '',
    this.workStyle = '',
    required this.dimensions,
    required this.completedAt,
  });

  /// Deserialises a full [MpiResult] from the API's JSON response.
  factory MpiResult.fromJson(Map<String, dynamic> j) {
    final rawDims = j['dimensionScores'] as Map<String, dynamic>? ?? {};
    final dims = rawDims.map(
      (k, v) => MapEntry(k, MpiDimensionScore.fromJson(v as Map<String, dynamic>)),
    );

    final rawInsights = j['insights'] as Map<String, dynamic>? ?? {};
    List<String> parseList(String key) =>
        (rawInsights[key] as List<dynamic>? ?? []).cast<String>();

    return MpiResult(
      id:                j['id'] as String,
      testId:            j['testId'] as String,
      testName:          j['testName'] as String? ?? 'MindType Assessment',
      overallScore:      (j['score'] as num).toInt(),
      typeCode:          j['typeCode'] as String? ?? '',
      typeName:          j['typeName'] as String? ?? '',
      emoji:             j['emoji'] as String? ?? '🧠',
      tagline:           j['tagline'] as String? ?? '',
      strengths:         parseList('strengths'),
      growthAreas:       parseList('growthAreas'),
      careerPaths:       parseList('careerPaths'),
      communicationStyle: rawInsights['communicationStyle'] as String? ?? '',
      workStyle:         rawInsights['workStyle'] as String? ?? '',
      dimensions:        dims,
      completedAt:       DateTime.parse(j['createdAtUtc'] as String),
    );
  }

  /// A short share token derived from the result ID.
  ///
  /// Takes the first 8 hex characters of the UUID (hyphens stripped) and
  /// upper-cases them for a compact shareable token.
  String get shareToken => id.replaceAll('-', '').substring(0, 8).toUpperCase();

  /// Returns dimensions ordered consistently with [MpiDimensionMeta.all].
  ///
  /// Only dimensions that are present in [dimensions] are included, so
  /// partial results are handled gracefully.
  List<MapEntry<MpiDimensionMeta, MpiDimensionScore>> get orderedDimensions {
    return MpiDimensionMeta.all
        .where((m) => dimensions.containsKey(m.key))
        .map((m) => MapEntry(m, dimensions[m.key]!))
        .toList();
  }
}
