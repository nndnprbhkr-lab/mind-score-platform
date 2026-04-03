import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TestCard extends StatelessWidget {
  final String title;
  final String description;
  final int questionCount;
  final int durationMinutes;
  final String difficulty;
  final VoidCallback onStart;

  const TestCard({
    super.key,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.durationMinutes,
    required this.difficulty,
    required this.onStart,
  });

  Color get _difficultyColor => switch (difficulty.toLowerCase()) {
        'easy' => AppColors.success,
        'medium' => AppColors.warning,
        'hard' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    difficulty,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _difficultyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetaChip(
                  icon: Icons.quiz_outlined,
                  label: '$questionCount questions',
                ),
                const SizedBox(width: 12),
                _MetaChip(
                  icon: Icons.timer_outlined,
                  label: '$durationMinutes min',
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
