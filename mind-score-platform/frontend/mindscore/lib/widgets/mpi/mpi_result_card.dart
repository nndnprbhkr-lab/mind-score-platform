import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/mpi_models.dart';
import '../../features/dashboard/providers/tests_provider.dart';
import '../../features/results/providers/mpi_result_provider.dart';
import 'mpi_dimension_tooltip.dart';
import 'mpi_legend_collapsible.dart';
import 'mpi_share_modal.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kOuter      = Color(0xFF1E0F3C);
const _kOuterBorder = Color(0xFF4a2080);
const _kInner      = Color(0xFF2A1850);
const _kBanner     = Color(0xFF2d1260);
const _kBannerBdr  = Color(0xFF4a2080);
const _kDeep       = Color(0xFF150A28);
const _kDivider    = Color(0xFF3d2070);
const _kAccent     = Color(0xFF6B35C8);
const _kLight      = Color(0xFFA67CF0);
const _kPink       = Color(0xFFFF6B9D);
const _kMuted      = Color(0xFF9a85c8);
const _kVeryMuted  = Color(0xFF5a4080);
const _kTeal       = Color(0xFF5DCAA5);
const _kYellow     = Color(0xFFF5B740);

// ─── Public entry point ───────────────────────────────────────────────────────

/// Watches [mpiResultProvider] and renders the result card or shimmer/empty state.
class MpiResultCardSlot extends ConsumerWidget {
  const MpiResultCardSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mpiResultProvider);
    return async.when(
      loading: () => const MpiResultCardShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) => result != null
          ? _AnimatedCard(result: result)
          : const _EmptyStateCard(),
    );
  }
}

// ─── Animation wrapper ────────────────────────────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final MpiResult result;
  const _AnimatedCard({required this.result});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MpiResultCard(result: widget.result),
      ),
    );
  }
}

// ─── Main card ────────────────────────────────────────────────────────────────

class MpiResultCard extends ConsumerStatefulWidget {
  final MpiResult result;

  const MpiResultCard({super.key, required this.result});

  @override
  ConsumerState<MpiResultCard> createState() => _MpiResultCardState();
}

class _MpiResultCardState extends ConsumerState<MpiResultCard> {
  bool _legendExpanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Container(
      decoration: BoxDecoration(
        color: _kOuter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kOuterBorder, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BannerRow(result: r),
          _DimensionsSection(
            result: r,
            legendExpanded: _legendExpanded,
            onToggleLegend: () =>
                setState(() => _legendExpanded = !_legendExpanded),
          ),
          _InsightsGrid(result: r),
          _FooterRow(result: r),
        ],
      ),
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────────

class _BannerRow extends StatelessWidget {
  final MpiResult result;
  const _BannerRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _kBanner,
        border: Border(bottom: BorderSide(color: _kBannerBdr, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji box
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF3d1d80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(result.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),

          // Type info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINDSCORE PERSONALITY INDEX',
                  style: TextStyle(
                    fontSize: 9,
                    color: _kLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.typeName,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.typeName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.tagline,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dimensions section ───────────────────────────────────────────────────────

class _DimensionsSection extends ConsumerWidget {
  final MpiResult result;
  final bool legendExpanded;
  final VoidCallback onToggleLegend;

  const _DimensionsSection({
    required this.result,
    required this.legendExpanded,
    required this.onToggleLegend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kDivider, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DIMENSION SCORES',
                style: TextStyle(
                  fontSize: 10,
                  color: _kVeryMuted,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: onToggleLegend,
                child: const Text(
                  'What do these mean?',
                  style: TextStyle(fontSize: 10, color: _kAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Collapsible legend
          MpiLegendCollapsible(
            result: result,
            isExpanded: legendExpanded,
          ),

          // Dimension bar rows
          ...result.orderedDimensions.map((e) {
            return _DimensionBarRow(
              dimensionKey: e.key.key,
              meta: e.key,
              score: e.value,
            );
          }),
        ],
      ),
    );
  }
}

class _DimensionBarRow extends ConsumerWidget {
  final String dimensionKey;
  final MpiDimensionMeta meta;
  final MpiDimensionScore score;

  const _DimensionBarRow({
    required this.dimensionKey,
    required this.meta,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dominant = score.dominantPole;
    final dominantColor = meta.colorForPole(dominant);
    final pct = (score.percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emoji
              SizedBox(
                width: 18,
                child: Text(
                  meta.emoji,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),

              // Pole labels (dominant colored, other muted)
              SizedBox(
                width: 76,
                child: Row(
                  children: [
                    Text(
                      meta.leftPole,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: dominant == meta.leftPole
                            ? dominantColor
                            : _kVeryMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/',
                      style: const TextStyle(
                          fontSize: 10, color: _kVeryMuted),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meta.rightPole,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: dominant == meta.rightPole
                            ? dominantColor
                            : _kVeryMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Gradient bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(
                          color: _kVeryMuted.withValues(alpha: 0.25),
                        ),
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
              ),

              // Percentage
              SizedBox(
                width: 36,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    '${score.percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 10, color: _kMuted),
                  ),
                ),
              ),

              // Info button
              MpiInfoButton(dimensionKey: dimensionKey),
            ],
          ),

          // Inline tooltip
          MpiDimensionTooltip(
            dimensionKey: dimensionKey,
            score: score,
          ),
        ],
      ),
    );
  }
}

// ─── Insights grid ────────────────────────────────────────────────────────────

class _InsightsGrid extends StatelessWidget {
  final MpiResult result;
  const _InsightsGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InsightColumn(
              title: 'Top strengths',
              items: result.strengths.take(3).toList(),
              dotColor: _kAccent,
            ),
          ),
          Container(width: 0.5, color: _kDivider),
          Expanded(
            child: _InsightColumn(
              title: 'Best careers',
              items: result.careerPaths.take(3).toList(),
              dotColor: _kPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color dotColor;

  const _InsightColumn({
    required this.title,
    required this.items,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: _kLight,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFc8b8f0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _FooterRow extends StatelessWidget {
  final MpiResult result;
  const _FooterRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final dt = result.completedAt;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final date = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kDivider, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            'Taken on $date · ${result.typeCode}',
            style: const TextStyle(fontSize: 11, color: _kVeryMuted),
          ),
          const Spacer(),
          _FooterButton(
            label: 'View full report',
            bg: _kInner,
            fg: _kLight,
            border: _kDivider,
            onTap: () => context.go(AppRoutes.results),
          ),
          const SizedBox(width: 8),
          _FooterButton(
            label: 'Share',
            bg: _kPink,
            fg: Colors.white,
            onTap: () => showMpiShareModal(context, result),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback onTap;

  const _FooterButton({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
          border: border != null
              ? Border.all(color: border!, width: 0.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyStateCard extends ConsumerWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tests = ref.watch(testsProvider).tests;
    final mpiTest = tests.isNotEmpty ? tests.first : null;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _kOuter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kOuterBorder, width: 0.5),
      ),
      child: Column(
        children: [
          const Text('🧠', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Discover your MPI type',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Take the personality assessment to reveal your unique cognitive profile',
            style: TextStyle(fontSize: 12, color: _kMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: mpiTest == null
                  ? null
                  : () => context.go(
                        AppRoutes.testWithId(mpiTest.id),
                        extra: mpiTest.name,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start assessment →',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer placeholder ──────────────────────────────────────────────────────

class MpiResultCardShimmer extends StatelessWidget {
  const MpiResultCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: _kOuter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kOuterBorder, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner shimmer
          Container(
            height: 100,
            color: _kBanner,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ShimmerRect(width: 56, height: 56, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShimmerRect(width: 120, height: 10, radius: 5),
                      const SizedBox(height: 8),
                      _ShimmerRect(width: 180, height: 18, radius: 5),
                      const SizedBox(height: 6),
                      _ShimmerRect(width: 140, height: 10, radius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bar shimmers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ShimmerRect(
                    width: double.infinity,
                    height: 8,
                    radius: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerRect extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerRect({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1850),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
