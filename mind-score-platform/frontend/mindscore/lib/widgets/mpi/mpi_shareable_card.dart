import 'package:flutter/material.dart';
import '../../core/models/mpi_models.dart';
import 'mpi_share_legend.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kDeep      = Color(0xFF150A28);
const _kBanner    = Color(0xFF2d1260);
const _kInner     = Color(0xFF2A1850);
const _kDivider   = Color(0xFF3d2070);
const _kAccent    = Color(0xFF6B35C8);
const _kLight     = Color(0xFFA67CF0);
const _kPink      = Color(0xFFFF6B9D);
const _kTeal      = Color(0xFF5DCAA5);
const _kMuted     = Color(0xFF9a85c8);
const _kVeryMuted = Color(0xFF5a4080);

/// Fixed-size card rendered to PNG for sharing.
/// Sizes are in logical pixels; pixelRatio 3 gives 3× resolution.
class MpiShareableCard extends StatelessWidget {
  final MpiResult result;
  final ShareFormat format;

  const MpiShareableCard({
    super.key,
    required this.result,
    required this.format,
  });

  Size get _logicalSize => switch (format) {
        ShareFormat.square => const Size(360, 360),
        ShareFormat.story  => const Size(360, 640),
        ShareFormat.wide   => const Size(400, 209),
      };

  @override
  Widget build(BuildContext context) {
    final size = _logicalSize;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: switch (format) {
        ShareFormat.square => _SquareLayout(result: result),
        ShareFormat.story  => _StoryLayout(result: result),
        ShareFormat.wide   => _WideLayout(result: result),
      },
    );
  }
}

// ─── Square ───────────────────────────────────────────────────────────────────

class _SquareLayout extends StatelessWidget {
  final MpiResult result;
  const _SquareLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDeep,
      child: Column(
        children: [
          // Top section
          Container(
            color: _kBanner,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                const Text(
                  'MINDSCORE · MINDTYPE',
                  style: TextStyle(
                    fontSize: 9,
                    color: _kVeryMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(result.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                const Text(
                  'PERSONALITY TYPE',
                  style: TextStyle(
                    fontSize: 8,
                    color: _kLight,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.typeName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${result.typeName} · ${result.typeCode}',
                  style: const TextStyle(fontSize: 11, color: _kPink),
                ),
                const SizedBox(height: 6),
                Text(
                  result.tagline,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kMuted,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Score pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _Pill(
                  value: '${result.overallScore}',
                  label: 'Score',
                  valueColor: _kLight,
                ),
                const SizedBox(width: 6),
                _Pill(
                  value: _topPercent(result.overallScore),
                  label: 'Ranking',
                  valueColor: _kPink,
                ),
                const SizedBox(width: 6),
                _Pill(
                  value: _strongestStrength(result),
                  label: 'Dominance',
                  valueColor: _kTeal,
                ),
              ],
            ),
          ),

          // Legend strip
          MpiShareLegend(result: result),

          // Dimension bars
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              children: result.orderedDimensions.map((e) {
                final meta = e.key;
                final score = e.value;
                final dominant = score.dominantPole;
                final color = meta.colorForPole(dominant);
                return _SmallBarRow(
                  meta: meta,
                  score: score,
                  color: color,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Strengths
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOP STRENGTHS',
                  style: TextStyle(
                    fontSize: 8,
                    color: _kLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                ...result.strengths.take(3).map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: _kAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFc8b8f0),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MindScore™',
                  style: TextStyle(fontSize: 9, color: _kVeryMuted),
                ),
                _QrPlaceholder(),
                const Text(
                  'mindscore.app',
                  style: TextStyle(fontSize: 9, color: _kAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Story ────────────────────────────────────────────────────────────────────

class _StoryLayout extends StatelessWidget {
  final MpiResult result;
  const _StoryLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDeep,
      child: Column(
        children: [
          Container(
            color: _kBanner,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              children: [
                const Text(
                  'MINDSCORE · MINDTYPE',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kVeryMuted,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(result.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                const Text(
                  'PERSONALITY TYPE',
                  style: TextStyle(
                    fontSize: 9,
                    color: _kLight,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.typeName,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.typeName} · ${result.typeCode}',
                  style: const TextStyle(fontSize: 12, color: _kPink),
                ),
                const SizedBox(height: 10),
                Text(
                  result.tagline,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Pill(value: '${result.overallScore}', label: 'Score', valueColor: _kLight),
                const SizedBox(width: 8),
                _Pill(value: _topPercent(result.overallScore), label: 'Ranking', valueColor: _kPink),
              ],
            ),
          ),

          MpiShareLegend(result: result),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: result.orderedDimensions.map((e) {
                final color = e.key.colorForPole(e.value.dominantPole);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SmallBarRow(meta: e.key, score: e.value, color: color),
                );
              }).toList(),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MindScore™', style: TextStyle(fontSize: 10, color: _kVeryMuted)),
                _QrPlaceholder(),
                const Text('mindscore.app', style: TextStyle(fontSize: 10, color: _kAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wide ─────────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final MpiResult result;
  const _WideLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDeep,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left: emoji
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 6),
              Text(
                result.typeCode,
                style: const TextStyle(
                  fontSize: 14,
                  color: _kLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Center: type + tagline
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINDSCORE MINDTYPE',
                  style: TextStyle(
                    fontSize: 8,
                    color: _kVeryMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.typeName,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.tagline,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'mindscore.app',
                  style: TextStyle(fontSize: 9, color: _kAccent),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right: score + bars
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Pill(
                  value: '${result.overallScore}',
                  label: 'Score',
                  valueColor: _kLight,
                ),
                const SizedBox(height: 8),
                ...result.orderedDimensions.map((e) {
                  final color = e.key.colorForPole(e.value.dominantPole);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SmallBarRow(meta: e.key, score: e.value, color: color),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _Pill({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: _kInner,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kDivider, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: _kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBarRow extends StatelessWidget {
  final MpiDimensionMeta meta;
  final MpiDimensionScore score;
  final Color color;

  const _SmallBarRow({
    required this.meta,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (score.percentage / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            score.dominantPole,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            meta.name,
            style: const TextStyle(fontSize: 9, color: _kVeryMuted),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(color: _kVeryMuted.withValues(alpha: 0.3)),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_kAccent, _kPink],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${score.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 9, color: _kMuted),
          ),
        ],
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1850),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(3),
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        children: List.generate(
          16,
          (i) => Container(
            color: i % 3 == 0
                ? const Color(0xFF6B35C8)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _topPercent(int score) {
  if (score >= 90) return 'Top 5%';
  if (score >= 80) return 'Top 10%';
  if (score >= 70) return 'Top 25%';
  if (score >= 60) return 'Top 50%';
  return 'Top 75%';
}

String _strongestStrength(MpiResult result) {
  if (result.dimensions.isEmpty) return '—';
  final strongest = result.dimensions.entries
      .map((e) => (e.key, (e.value.percentage - 50).abs()))
      .reduce((a, b) => a.$2 > b.$2 ? a : b);
  return result.dimensions[strongest.$1]!.strength;
}
