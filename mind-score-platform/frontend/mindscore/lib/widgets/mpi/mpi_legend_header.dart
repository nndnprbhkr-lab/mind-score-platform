import 'package:flutter/material.dart';
import '../../core/models/mpi_models.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kOuter      = Color(0xFF1E0F3C);
const _kOuterBorder = Color(0xFF4a2080);
const _kInner      = Color(0xFF150A28);
const _kInnerBorder = Color(0xFF3d2070);
const _kLight      = Color(0xFFA67CF0);
const _kMuted      = Color(0xFF9a85c8);
const _kVeryMuted  = Color(0xFF5a4080);

/// Always-visible legend shown at the top of the full Results screen.
class MpiLegendHeader extends StatelessWidget {
  final MpiResult result;

  const MpiLegendHeader({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kOuter,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kOuterBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Understanding your MPI code',
            style: TextStyle(
              fontSize: 11,
              color: _kLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.6,
            children: MpiDimensionMeta.all
                .map((m) => _DimensionCell(meta: m))
                .toList(),
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kInnerBorder)),
            ),
            child: const Text(
              'The bar shows how strongly you lean toward the highlighted pole.\n'
              '50% means balanced between both sides.',
              style: TextStyle(
                fontSize: 10,
                color: _kVeryMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionCell extends StatelessWidget {
  final MpiDimensionMeta meta;

  const _DimensionCell({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _kInner,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kInnerBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(meta.emoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meta.name,
                  style: const TextStyle(fontSize: 10, color: _kMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _InlinePole(
                pole: meta.leftPole,
                word: meta.leftWord,
                color: meta.leftColor,
              ),
              const SizedBox(width: 10),
              _InlinePole(
                pole: meta.rightPole,
                word: meta.rightWord,
                color: meta.rightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlinePole extends StatelessWidget {
  final String pole;
  final String word;
  final Color color;

  const _InlinePole({
    required this.pole,
    required this.word,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pole,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          word,
          style: const TextStyle(fontSize: 10, color: _kVeryMuted),
        ),
      ],
    );
  }
}
