import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../widgets/test_card.dart';
import '../../../widgets/result_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _mockTests = [
    {
      'title': 'Cognitive Aptitude Test',
      'description': 'Measures logical reasoning, verbal ability, and numerical skills.',
      'questions': 30,
      'duration': 25,
      'difficulty': 'Medium',
    },
    {
      'title': 'Emotional Intelligence',
      'description': 'Assesses self-awareness, empathy, and social skills.',
      'questions': 20,
      'duration': 15,
      'difficulty': 'Easy',
    },
    {
      'title': 'Critical Thinking',
      'description': 'Evaluates analytical reasoning and problem-solving ability.',
      'questions': 25,
      'duration': 30,
      'difficulty': 'Hard',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
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
              _buildWelcomeBanner(context, auth),
              const SizedBox(height: 32),
              _buildStatsRow(context),
              const SizedBox(height: 32),
              _buildAvailableTests(context),
              const SizedBox(height: 32),
              _buildRecentResults(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, AuthState auth) {
    final theme = Theme.of(context);
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
                  onPressed: () {},
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

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final stats = [
      {'label': 'Tests Taken', 'value': '12', 'icon': Icons.quiz_outlined},
      {'label': 'Avg Score', 'value': '78%', 'icon': Icons.bar_chart_rounded},
      {'label': 'Best Score', 'value': '94%', 'icon': Icons.star_rounded},
      {'label': 'Streak', 'value': '5 days', 'icon': Icons.local_fire_department_rounded},
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

  Widget _buildAvailableTests(BuildContext context) {
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
        ..._mockTests.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TestCard(
              title: t['title'] as String,
              description: t['description'] as String,
              questionCount: t['questions'] as int,
              durationMinutes: t['duration'] as int,
              difficulty: t['difficulty'] as String,
              onStart: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResults(BuildContext context) {
    final theme = Theme.of(context);
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
        ResultCard(
          testTitle: 'Cognitive Aptitude Test',
          score: 82,
          maxScore: 100,
          correctAnswers: 25,
          totalQuestions: 30,
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          onReview: () {},
        ),
        const SizedBox(height: 12),
        ResultCard(
          testTitle: 'Emotional Intelligence',
          score: 68,
          maxScore: 100,
          correctAnswers: 14,
          totalQuestions: 20,
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
          onReview: () {},
        ),
      ],
    );
  }
}
