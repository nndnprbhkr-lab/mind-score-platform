import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../dashboard/providers/tests_provider.dart';
import '../../results/providers/results_provider.dart';
import '../../../widgets/test_card.dart';
import '../../../widgets/result_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final testsState = ref.watch(testsProvider);
    final resultsState = ref.watch(resultsProvider);
    final isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('MindScore'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      (auth.email ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 8),
                    Text(
                      auth.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ],
              ),
              itemBuilder: (_) => [
                if (auth.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Admin Panel'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (value == 'admin') {
                  context.go(AppRoutes.adminPanel);
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 20,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(context, auth, testsState),
              const SizedBox(height: 32),
              _buildStatsRow(context, resultsState),
              const SizedBox(height: 32),
              _buildAvailableTests(context, ref, testsState),
              const SizedBox(height: 32),
              _buildRecentResults(context, resultsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, AuthState auth, TestsState testsState) {
    final theme = Theme.of(context);
    final firstTest = testsState.tests.isNotEmpty ? testsState.tests.first : null;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  auth.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: firstTest == null
                      ? null
                      : () => context.go(AppRoutes.testWithId(firstTest.id), extra: firstTest.name),
                  child: const Text('Take a Test'),
                ),
              ],
            ),
          ),
          const Icon(Icons.emoji_events_rounded,
              color: Colors.white, size: 72),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ResultsState resultsState) {
    final theme = Theme.of(context);
    final results = resultsState.results;
    final scores = results.map((r) => ((r.score - 1) / 4 * 100)).toList();
    final avgScore = scores.isEmpty
        ? null
        : (scores.reduce((a, b) => a + b) / scores.length).round();
    final bestScore = scores.isEmpty ? null : scores.reduce((a, b) => a > b ? a : b).round();

    final stats = [
      {'label': 'Tests Taken', 'value': '${results.length}', 'icon': Icons.quiz_outlined},
      {'label': 'Avg Score', 'value': avgScore != null ? '$avgScore%' : '—', 'icon': Icons.bar_chart_rounded},
      {'label': 'Best Score', 'value': bestScore != null ? '$bestScore%' : '—', 'icon': Icons.star_rounded},
      {'label': 'Streak', 'value': '—', 'icon': Icons.local_fire_department_rounded},
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 600 ? 4 : 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats.map((s) {
          final w = (constraints.maxWidth - (cols - 1) * 12) / cols;
          return SizedBox(
            width: w,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(s['icon'] as IconData,
                        color: AppColors.primary, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      s['value'] as String,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      s['label'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAvailableTests(BuildContext context, WidgetRef ref, TestsState testsState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (testsState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (testsState.error != null)
          Text(testsState.error!,
              style: TextStyle(color: AppColors.error))
        else if (testsState.tests.isEmpty)
          Text('No tests available.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
        else
          ...testsState.tests.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TestCard(
                title: t.name,
                questionCount: t.questionCount,
                durationMinutes: t.questionCount,
                onStart: () => context.go(AppRoutes.testWithId(t.id), extra: t.name),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentResults(BuildContext context, ResultsState resultsState) {
    final theme = Theme.of(context);
    final recent = resultsState.results.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Results',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (resultsState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (resultsState.error != null)
          Text(resultsState.error!,
              style: TextStyle(color: AppColors.error))
        else if (recent.isEmpty)
          Text('No results yet. Take a test to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
        else
          ...recent.asMap().entries.map((entry) {
            final r = entry.value;
            final normalizedScore = ((r.score - 1) / 4 * 100).round().clamp(0, 100);
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < recent.length - 1 ? 12 : 0),
              child: ResultCard(
                testTitle: r.testName,
                score: normalizedScore,
                maxScore: 100,
                correctAnswers: normalizedScore,
                totalQuestions: 100,
                completedAt: r.createdAtUtc,
              ),
            );
          }),
      ],
    );
  }
}
