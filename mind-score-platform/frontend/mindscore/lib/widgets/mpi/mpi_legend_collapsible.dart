import 'package:flutter/material.dart';
import '../../core/models/mpi_models.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kDeep       = Color(0xFF150A28);
const _kInner      = Color(0xFF1E0F3C);
const _kBorder     = Color(0xFF3d2070);
const _kAccent     = Color(0xFF6B35C8);
const _kLight      = Color(0xFFA67CF0);
const _kMuted      = Color(0xFF9a85c8);
const _kVeryMuted  = Color(0xFF5a4080);

class MpiLegendCollapsible extends StatelessWidget {
  final MpiResult result;
  final bool isExpanded;

  const MpiLegendCollapsible({
    super.key,
    required this.result,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: isExpanded ? null : 0,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: isExpanded ? _Content(result: result) : const SizedBox.shrink(),
    );
  }
}

class _Content extends StatelessWidget {
  final MpiResult result;

  const _Content({required this.result});

  String _poleFullName(String pole) => kPoleFullNames[pole] ?? pole;

  @override
  Widget build(BuildContext context) {
    // Build expanded explanation from result
    final parts = result.orderedDimensions.map((e) {
      return '${e.value.dominantPole} (${_poleFullName(e.value.dominantPole)})';
    }).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MPI dimension guide',
            style: TextStyle(
              fontSize: 11,
              color: _kLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // 2×2 grid of legend tiles
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.4,
            children: MpiDimensionMeta.all
                .map((m) => _LegendTile(meta: m))
                .toList(),
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            child: Text(
              'Your code ${result.typeCode} = $parts.\n'
              'Bar position shows strength of each preference.',
              style: const TextStyle(
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

class _LegendTile extends StatelessWidget {
  final MpiDimensionMeta meta;

  const _LegendTile({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _kInner,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(meta.emoji, style: const TextStyle(fontSize: 10)),
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
              _PolePair(
                pole: meta.leftPole,
                word: meta.leftWord,
                color: meta.leftColor,
              ),
              const SizedBox(width: 8),
              _PolePair(
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pole,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          word,
          style: const TextStyle(fontSize: 9, color: _kVeryMuted),
        ),
      ],
    );
  }
}
