// Career Fit Assessment results screen.
//
// Displays the user's primary career cluster archetype, a ranked list of all
// 8 cluster fit percentages with animated bars, and a detailed profile for the
// top cluster (strengths, growth areas, ideal roles).
//
// Data source: [testProvider] (just-submitted result) or a [ResultModel]
// passed explicitly from the history screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../../../features/test/providers/test_provider.dart';
import '../../../features/results/providers/results_provider.dart';

// ─── CareerFitResult view model ───────────────────────────────────────────────

class _ClusterScore {
  final String code;
  final String name;
  final String emoji;
  final double percentage;

  const _ClusterScore({
    required this.code,
    required this.name,
    required this.emoji,
    required this.percentage,
  });
}

class _CareerFitData {
  final String primaryCode;
  final String primaryName;
  final String primaryEmoji;
  final String primaryTagline;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> idealRoles;
  final List<_ClusterScore> allClusters;
  final double fitPercentage;

  const _CareerFitData({
    required this.primaryCode,
    required this.primaryName,
    required this.primaryEmoji,
    required this.primaryTagline,
    required this.strengths,
    required this.growthAreas,
    required this.idealRoles,
    required this.allClusters,
    required this.fitPercentage,
  });

  static _CareerFitData? fromResult(ResultModel r) {
    final insights = r.insights;
    if (insights == null) return null;

    final primary = insights['primaryCluster'] as Map<String, dynamic>?;
    final top3Raw = insights['top3Clusters'] as List<dynamic>?;
    final dimRaw  = r.dimensionScores;

    if (primary == null) return null;

    List<String> toStrings(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

    // Build ranked cluster list from dimensionScores map.
    final clusters = <_ClusterScore>[];
    if (dimRaw is Map<String, dynamic>) {
      for (final entry in dimRaw.entries) {
        final pct = (entry.value as Map<String, dynamic>?)?['percentage'];
        clusters.add(_ClusterScore(
          code:       entry.key,
          name:       _clusterName(entry.key),
          emoji:      _clusterEmoji(entry.key),
          percentage: (pct as num?)?.toDouble() ?? 0.0,
        ));
      }
      clusters.sort((a, b) => b.percentage.compareTo(a.percentage));
    }

    // Fallback: reconstruct from top3Clusters if dimensionScores is absent.
    if (clusters.isEmpty && top3Raw != null) {
      for (final raw in top3Raw) {
        final m = raw as Map<String, dynamic>;
        clusters.add(_ClusterScore(
          code:       m['code'] as String? ?? '',
          name:       m['name'] as String? ?? '',
          emoji:      m['emoji'] as String? ?? '',
          percentage: (m['fitPercentage'] as num?)?.toDouble() ?? 0.0,
        ));
      }
    }

    return _CareerFitData(
      primaryCode:    primary['code'] as String? ?? r.typeCode ?? '',
      primaryName:    primary['name'] as String? ?? r.typeName ?? '',
      primaryEmoji:   primary['emoji'] as String? ?? r.emoji ?? '',
      primaryTagline: primary['tagline'] as String? ?? r.tagline ?? '',
      strengths:      toStrings(primary['strengths']),
      growthAreas:    toStrings(primary['growthAreas']),
      idealRoles:     toStrings(primary['idealRoles']),
      allClusters:    clusters,
      fitPercentage:  r.score,
    );
  }
}

// Fallback name/emoji if dimensionScores keys don't carry them.
String _clusterName(String code) => switch (code) {
  'BUILDER'       => 'The Builder',
  'ANALYST'       => 'The Analyst',
  'LEADER'        => 'The Leader',
  'CREATOR'       => 'The Creator',
  'CAREGIVER'     => 'The Caregiver',
  'COMMUNICATOR'  => 'The Communicator',
  'ENTREPRENEUR'  => 'The Entrepreneur',
  'OPERATOR'      => 'The Operator',
  _               => code,
};

String _clusterEmoji(String code) => switch (code) {
  'BUILDER'       => '🔧',
  'ANALYST'       => '📊',
  'LEADER'        => '🎯',
  'CREATOR'       => '🎨',
  'CAREGIVER'     => '💛',
  'COMMUNICATOR'  => '🗣️',
  'ENTREPRENEUR'  => '🚀',
  'OPERATOR'      => '⚙️',
  _               => '🔍',
};

// ─── CareerFitResultsScreen ───────────────────────────────────────────────────

class CareerFitResultsScreen extends ConsumerWidget {
  final ResultModel? resultModel;

  const CareerFitResultsScreen({super.key, this.resultModel});

  _CareerFitData? _resolve(WidgetRef ref) {
    ResultModel? model = resultModel;

    if (model == null) {
      final testResult = ref.watch(testProvider).result;
      if (testResult?.testName == 'Career Fit Assessment') model = testResult;
    }

    model ??= ref
        .watch(resultsProvider)
        .results
        .where((r) => r.testName == 'Career Fit Assessment')
        .firstOrNull;

    if (model == null) return null;
    return _CareerFitData.fromResult(model);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _resolve(ref);

    if (data == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.work_outline,
                  size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'No Career Fit result found.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentLight),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _AppBar(data: data),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HeroCard(data: data),
                  const SizedBox(height: 24),
                  _ClusterBars(clusters: data.allClusters),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Your Strengths',
                    icon: Icons.bolt_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    items: data.strengths,
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Growth Areas',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.accentLight,
                    items: data.growthAreas,
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Ideal Roles',
                    icon: Icons.business_center_outlined,
                    iconColor: AppColors.success,
                    items: data.idealRoles,
                    chip: true,
                  ),
                  const SizedBox(height: 32),
                  _DashboardButton(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final _CareerFitData data;
  const _AppBar({required this.data});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimary,
      floating: true,
      snap: true,
      title: const Text('Career Fit',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      centerTitle: false,
    );
  }
}

// ─── _HeroCard ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final _CareerFitData data;
  const _HeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1850), Color(0xFF1A0F3A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(data.primaryEmoji,
                  style: const TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            data.primaryName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            data.primaryTagline,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Text(
              '${data.fitPercentage.toStringAsFixed(1)}% fit',
              style: const TextStyle(
                color: AppColors.accentLight,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

// ─── _ClusterBars ─────────────────────────────────────────────────────────────

class _ClusterBars extends StatelessWidget {
  final List<_ClusterScore> clusters;
  const _ClusterBars({required this.clusters});

  static const _barColors = [
    Color(0xFF6B35C8), // 1st – accent
    Color(0xFFA67CF0), // 2nd – accentLight
    Color(0xFFFF6B9D), // 3rd – highlight
    Color(0xFF10B981), // 4th – success
    Color(0xFF3B82F6), // 5th – blue
    Color(0xFFF59E0B), // 6th – amber
    Color(0xFFEC4899), // 7th – pink
    Color(0xFF64748B), // 8th – slate
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cluster Fit Breakdown',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...clusters.asMap().entries.map((e) {
          final i       = e.key;
          final cluster = e.value;
          final color   = _barColors[i % _barColors.length];
          final frac    = (cluster.percentage / 100).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text(cluster.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cluster.name,
                        style: TextStyle(
                          color: i == 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: i == 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ]),
                    Text(
                      '${cluster.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: i == 0 ? color : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(builder: (ctx, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 6,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500 + i * 60),
                        curve: Curves.easeOut,
                        height: 6,
                        width: constraints.maxWidth * frac,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 100 + i * 50))
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.05, end: 0);
        }),
      ],
    );
  }
}

// ─── _Section ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;
  final bool chip;

  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    this.chip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (chip)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((role) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                              color: AppColors.success, fontSize: 12),
                        ),
                      ))
                  .toList(),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04, end: 0);
  }
}

// ─── _DashboardButton ─────────────────────────────────────────────────────────

class _DashboardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.go(AppRoutes.dashboard),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.home_rounded, size: 18),
        label: const Text('Back to Dashboard',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
