import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mpi_models.dart';
import '../../features/results/providers/mpi_result_provider.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kBg         = Color(0xFF2A1850);
const _kBorder     = Color(0xFF4a2080);
const _kDivider    = Color(0xFF3d2070);
const _kMuted      = Color(0xFF9a85c8);
const _kVeryMuted  = Color(0xFF5a4080);

class MpiDimensionTooltip extends ConsumerWidget {
  final String dimensionKey;
  final MpiDimensionScore score;

  const MpiDimensionTooltip({
    super.key,
    required this.dimensionKey,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeDimensionTooltipProvider);
    if (active != dimensionKey) return const SizedBox.shrink();

    final meta = MpiDimensionMeta.forKey(dimensionKey);
    if (meta == null) return const SizedBox.shrink();

    final dominantName = kPoleFullNames[score.dominantPole] ?? score.dominantPole;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder, width: 0.5),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(meta.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  meta.name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Left pole row
            _PoleRow(
              pole: meta.leftPole,
              name: meta.leftWord,
              description: kPoleDescriptions[meta.leftPole] ?? '',
              color: meta.leftColor,
            ),
            const SizedBox(height: 8),

            // Right pole row
            _PoleRow(
              pole: meta.rightPole,
              name: meta.rightWord,
              description: kPoleDescriptions[meta.rightPole] ?? '',
              color: meta.rightColor,
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _kDivider)),
                ),
                child: Text(
                  'Your result: ${score.percentage.toStringAsFixed(0)}% $dominantName — ${score.strength}',
                  style: TextStyle(
                    fontSize: 10,
                    color: meta.colorForPole(score.dominantPole),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoleRow extends StatelessWidget {
  final String pole;
  final String name;
  final String description;
  final Color color;

  const _PoleRow({
    required this.pole,
    required this.name,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: Text(
            pole,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: _kMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "i" info button that toggles this dimension's tooltip.
class MpiInfoButton extends ConsumerWidget {
  final String dimensionKey;

  const MpiInfoButton({super.key, required this.dimensionKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeDimensionTooltipProvider);
    final isOpen = active == dimensionKey;

    return GestureDetector(
      onTap: () {
        ref.read(activeDimensionTooltipProvider.notifier).state =
            isOpen ? null : dimensionKey;
      },
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF6B35C8) : const Color(0xFF2A1850),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF6B35C8),
            width: 0.5,
          ),
        ),
        child: const Center(
          child: Text(
            'i',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF6B35C8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
