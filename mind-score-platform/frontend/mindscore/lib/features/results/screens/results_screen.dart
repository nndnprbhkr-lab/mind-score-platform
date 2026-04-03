import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/test/providers/test_provider.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final test = ref.watch(testProvider);
    final isDesktop = Responsive.isDesktop(context);

    final total = test.questions.length;
    final answered = test.selectedAnswers.values.where((v) => v != null).length;
    // Use the backend Likert score (1–5) normalised to 0–100.
    // Falls back to completion rate when the result hasn't been returned yet.
    final backendScore = test.result?.score;
    final percent = backendScore != null
        ? (((backendScore - 1) / 4) * 100).round().clamp(0, 100)
        : (total > 0 ? (answered / total * 100).round() : 0);

    Color scoreColor;
    String grade;
    String message;
    if (percent >= 90) {
      scoreColor = AppColors.success;
      grade = 'A';
      message = 'Outstanding! Excellent work.';
    } else if (percent >= 80) {
      scoreColor = AppColors.success;
      grade = 'B';
      message = 'Great job! Keep it up.';
    } else if (percent >= 70) {
      scoreColor = AppColors.warning;
      grade = 'C';
      message = 'Good effort. Room for improvement.';
    } else if (percent >= 60) {
      scoreColor = AppColors.warning;
      grade = 'D';
      message = 'Keep practicing to improve.';
    } else {
      scoreColor = AppColors.error;
      grade = 'F';
      message = 'Review the material and try again.';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Test Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 640 : double.infinity),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildScoreCard(context, grade, percent, scoreColor, message),
                const SizedBox(height: 24),
                _buildBreakdown(context, answered, total, test),
                const SizedBox(height: 32),
                _buildActions(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, String grade, int percent,
      Color color, String message) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$percent%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: AppColors.divider,
                color: color,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdown(
      BuildContext context, int correct, int total, TestState test) {
    final theme = Theme.of(context);
    final unanswered = total - test.selectedAnswers.values.where((v) => v != null).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _BreakdownRow(
                label: 'Total Questions',
                value: '$total',
                icon: Icons.quiz_outlined,
                color: AppColors.textSecondary),
            _BreakdownRow(
                label: 'Answered',
                value: '${total - unanswered}',
                icon: Icons.check_circle_outline,
                color: AppColors.success),
            _BreakdownRow(
                label: 'Unanswered',
                value: '$unanswered',
                icon: Icons.radio_button_unchecked,
                color: AppColors.error),
            _BreakdownRow(
                label: 'Time Remaining',
                value: _formatTime(test.remainingSeconds),
                icon: Icons.timer_outlined,
                color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m}m ${sec}s';
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            ref.read(testProvider.notifier).reset();
            context.go(AppRoutes.dashboard);
          },
          icon: const Icon(Icons.dashboard_outlined),
          label: const Text('Back to Dashboard'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(testProvider.notifier).reset();
            context.go(AppRoutes.test);
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retake Test'),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
