import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/test/providers/test_provider.dart';

class RelationshipDynamicsResultsScreen extends ConsumerWidget {
  const RelationshipDynamicsResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final test = ref.watch(testProvider);
    final result = test.result;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'No results to display.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.read(testProvider.notifier).reset();
                  context.go('/dashboard');
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    // Check if pair mode (another user has result on same test)
    final isPairMode = result.contextInsights != null &&
                       (result.contextInsights as Map<String, dynamic>?)?.containsKey('compatibilityScore') == true;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(testProvider.notifier).reset();
            context.go('/dashboard');
          },
        ),
        title: const Text('Relationship Dynamics'),
        centerTitle: true,
      ),
      body: isPairMode
          ? _PairModeView(result: result)
          : _SoloModeView(result: result),
    );
  }
}

class _SoloModeView extends StatelessWidget {
  final ResultModel result;

  const _SoloModeView({required this.result});

  @override
  Widget build(BuildContext context) {
    final insights = result.insights ?? {};

    return ResponsiveWrapper(
      mobile: (ctx) => _SoloMobileLayout(
        result: result,
        insights: insights,
      ),
      desktop: (ctx) => _SoloDesktopLayout(
        result: result,
        insights: insights,
      ),
    );
  }
}

class _SoloMobileLayout extends StatelessWidget {
  final ResultModel result;
  final Map<String, dynamic> insights;

  const _SoloMobileLayout({
    required this.result,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _HeroCard(
          emoji: result.emoji ?? '💝',
          typeName: result.typeName ?? 'Your Relationship Profile',
          typeCode: result.typeCode ?? '',
          tagline: result.tagline ?? '',
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.06, end: 0),
        const SizedBox(height: 24),
        _DimensionsGrid(dimensions: _buildDimensions())
            .animate(delay: 60.ms)
            .fadeIn(duration: 350.ms),
        const SizedBox(height: 24),
        if (insights['emotionalNeeds'] != null)
          _InsightCard(
            title: 'Your Emotional Needs',
            items: List<String>.from(insights['emotionalNeeds'] as List? ?? []),
            dotColor: AppColors.accent,
          )
              .animate(delay: 120.ms)
              .fadeIn(duration: 350.ms),
        const SizedBox(height: 16),
        if (insights['growthAreas'] != null)
          _InsightCard(
            title: 'Growth Edge',
            items: [insights['relationshipGrowthEdge'] as String? ?? ''],
            dotColor: AppColors.accentLight,
          )
              .animate(delay: 160.ms)
              .fadeIn(duration: 350.ms),
        const SizedBox(height: 16),
        if (insights['defensivePatterns'] != null)
          _InsightCard(
            title: 'Patterns to Watch',
            items: List<String>.from(insights['defensivePatterns'] as List? ?? []),
            dotColor: AppColors.highlight,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 350.ms),
      ],
    );
  }

  List<_DimensionData> _buildDimensions() {
    return [
      _DimensionData(
        name: 'Attachment Security',
        percentage: 75,
        color: AppColors.accent,
      ),
      _DimensionData(
        name: 'Conflict Engagement',
        percentage: 62,
        color: AppColors.accentLight,
      ),
      _DimensionData(
        name: 'Emotional Expression',
        percentage: 81,
        color: AppColors.highlight,
      ),
      _DimensionData(
        name: 'Love Language',
        percentage: 58,
        color: Colors.purple.shade400,
      ),
    ];
  }
}

class _SoloDesktopLayout extends StatelessWidget {
  final ResultModel result;
  final Map<String, dynamic> insights;

  const _SoloDesktopLayout({
    required this.result,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(
                  emoji: result.emoji ?? '💝',
                  typeName: result.typeName ?? 'Your Relationship Profile',
                  typeCode: result.typeCode ?? '',
                  tagline: result.tagline ?? '',
                )
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 32),
                _DimensionsGrid(dimensions: _buildDimensions())
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),
        Container(
          width: 300,
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.cardBorder)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (insights['emotionalNeeds'] != null)
                  _InsightCard(
                    title: 'Your Emotional Needs',
                    items: List<String>.from(insights['emotionalNeeds'] as List? ?? []),
                    dotColor: AppColors.accent,
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 350.ms),
                const SizedBox(height: 16),
                if (insights['growthAreas'] != null)
                  _InsightCard(
                    title: 'Growth Edge',
                    items: [insights['relationshipGrowthEdge'] as String? ?? ''],
                    dotColor: AppColors.accentLight,
                  )
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_DimensionData> _buildDimensions() {
    return [
      _DimensionData(
        name: 'Attachment Security',
        percentage: 75,
        color: AppColors.accent,
      ),
      _DimensionData(
        name: 'Conflict Engagement',
        percentage: 62,
        color: AppColors.accentLight,
      ),
      _DimensionData(
        name: 'Emotional Expression',
        percentage: 81,
        color: AppColors.highlight,
      ),
      _DimensionData(
        name: 'Love Language',
        percentage: 58,
        color: Colors.purple.shade400,
      ),
    ];
  }
}

class _PairModeView extends StatelessWidget {
  final ResultModel result;

  const _PairModeView({required this.result});

  @override
  Widget build(BuildContext context) {
    final contextInsights = result.contextInsights as Map<String, dynamic>? ?? {};

    return ResponsiveWrapper(
      mobile: (ctx) => _PairMobileLayout(result: result, contextInsights: contextInsights),
      desktop: (ctx) => _PairDesktopLayout(result: result, contextInsights: contextInsights),
    );
  }
}

class _PairMobileLayout extends StatelessWidget {
  final ResultModel result;
  final Map<String, dynamic> contextInsights;

  const _PairMobileLayout({
    required this.result,
    required this.contextInsights,
  });

  @override
  Widget build(BuildContext context) {
    final compatScore = contextInsights['compatibilityScore'] as int? ?? 0;
    final compatLevel = contextInsights['compatibilityLevel'] as String? ?? 'Unknown';
    final conflictRisk = contextInsights['conflictCycleRisk'] as String? ?? '';
    final repairScripts = contextInsights['repairScripts'] as List? ?? [];
    final blindSpot1 = contextInsights['blindSpot1'] as String? ?? '';
    final blindSpot2 = contextInsights['blindSpot2'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _CompatibilityCard(score: compatScore, level: compatLevel)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 24),
        _ConflictCycleCard(risk: conflictRisk)
            .animate(delay: 60.ms)
            .fadeIn(duration: 350.ms),
        const SizedBox(height: 24),
        _BlindSpotsCard(blindSpot1: blindSpot1, blindSpot2: blindSpot2)
            .animate(delay: 120.ms)
            .fadeIn(duration: 350.ms),
        const SizedBox(height: 24),
        if (repairScripts.isNotEmpty)
          _RepairScriptsCard(scripts: repairScripts)
              .animate(delay: 160.ms)
              .fadeIn(duration: 350.ms),
      ],
    );
  }
}

class _PairDesktopLayout extends StatelessWidget {
  final ResultModel result;
  final Map<String, dynamic> contextInsights;

  const _PairDesktopLayout({
    required this.result,
    required this.contextInsights,
  });

  @override
  Widget build(BuildContext context) {
    final compatScore = contextInsights['compatibilityScore'] as int? ?? 0;
    final compatLevel = contextInsights['compatibilityLevel'] as String? ?? 'Unknown';
    final conflictRisk = contextInsights['conflictCycleRisk'] as String? ?? '';
    final repairScripts = contextInsights['repairScripts'] as List? ?? [];
    final blindSpot1 = contextInsights['blindSpot1'] as String? ?? '';
    final blindSpot2 = contextInsights['blindSpot2'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompatibilityCard(score: compatScore, level: compatLevel)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                _ConflictCycleCard(risk: conflictRisk)
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),
        Container(
          width: 300,
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.cardBorder)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BlindSpotsCard(blindSpot1: blindSpot1, blindSpot2: blindSpot2)
                    .animate(delay: 120.ms)
                    .fadeIn(duration: 350.ms),
                const SizedBox(height: 24),
                if (repairScripts.isNotEmpty)
                  _RepairScriptsCard(scripts: repairScripts)
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Component Widgets ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String emoji;
  final String typeName;
  final String typeCode;
  final String tagline;

  const _HeroCard({
    required this.emoji,
    required this.typeName,
    required this.typeCode,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accent, AppColors.highlight],
                      ).createShader(bounds),
                      child: Text(
                        typeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (typeCode.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                        ),
                        child: Text(
                          typeCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accentLight,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (tagline.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              tagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DimensionData {
  final String name;
  final double percentage;
  final Color color;

  _DimensionData({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

class _DimensionsGrid extends StatelessWidget {
  final List<_DimensionData> dimensions;

  const _DimensionsGrid({required this.dimensions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dimensions.map((dim) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dim.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${dim.percentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: dim.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: dim.percentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(dim.color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color dotColor;

  const _InsightCard({
    required this.title,
    required this.items,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
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

class _CompatibilityCard extends StatelessWidget {
  final int score;
  final String level;

  const _CompatibilityCard({required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (level.contains('High') || level.contains('Excellent')) {
      scoreColor = Colors.green;
    } else if (level.contains('Good')) {
      scoreColor = Colors.amber;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compatibility',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  level,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
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

class _ConflictCycleCard extends StatelessWidget {
  final String risk;

  const _ConflictCycleCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Conflict Cycle Risk',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            risk,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlindSpotsCard extends StatelessWidget {
  final String blindSpot1;
  final String blindSpot2;

  const _BlindSpotsCard({required this.blindSpot1, required this.blindSpot2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blind Spots',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (blindSpot1.isNotEmpty) ...[
            Text(
              blindSpot1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (blindSpot2.isNotEmpty)
            Text(
              blindSpot2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }
}

class _RepairScriptsCard extends StatelessWidget {
  final List<dynamic> scripts;

  const _RepairScriptsCard({required this.scripts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.highlight, size: 20),
              const SizedBox(width: 8),
              Text(
                'Repair Scripts',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...scripts.map<Widget>((script) {
            final scriptMap = script as Map<String, dynamic>?;
            final situation = scriptMap?['situation'] as String? ?? '';
            final scriptText = scriptMap?['script'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    situation,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scriptText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
