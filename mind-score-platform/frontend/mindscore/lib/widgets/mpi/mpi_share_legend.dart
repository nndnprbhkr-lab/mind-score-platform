import 'package:flutter/material.dart';
import '../../core/models/mpi_models.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kBg        = Color(0xFF1a0d38);
const _kVeryMuted = Color(0xFF5a4080);

/// Compact legend strip baked into the shareable card PNG.
/// Shows only the 4 dominant poles in a 2×2 grid.
class MpiShareLegend extends StatelessWidget {
  final MpiResult result;

  const MpiShareLegend({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final pairs = result.orderedDimensions.map((e) {
      final pole = e.value.dominantPole;
      final color = e.key.colorForPole(pole);
      final word = kPoleFullNames[pole] ?? pole;
      return _PolePair(pole: pole, word: word, color: color);
    }).toList();

    if (pairs.isEmpty) return const SizedBox.shrink();

    return Container(
      color: _kBg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 5.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 0,
        children: pairs,
      ),
    );
  }
}

class _PolePair extends StatelessWidget {
  final String pole;
  final String word;
  final Color color;

  const _PolePair({
    required this.pole,
    required this.word,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '[$pole]',
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          word,
          style: const TextStyle(fontSize: 9, color: _kVeryMuted),
        ),
      ],
    );
  }
}
