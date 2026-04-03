import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ResultCard extends StatelessWidget {
  final String testTitle;
  final int score;
  final int maxScore;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime completedAt;
  final VoidCallback? onReview;

  const ResultCard({
    super.key,
    required this.testTitle,
    required this.score,
    required this.maxScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
    this.onReview,
  });

  double get _percentage => maxScore > 0 ? score / maxScore : 0;

  Color get _scoreColor {
    if (_percentage >= 0.8) return AppColors.success;
    if (_percentage >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String get _grade {
    if (_percentage >= 0.9) return 'A';
    if (_percentage >= 0.8) return 'B';
    if (_percentage >= 0.7) return 'C';
    if (_percentage >= 0.6) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (_percentage * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _grade,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: _scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$correctAnswers/$totalQuestions correct · $percent%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _scoreColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(completedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _percentage,
                      backgroundColor: AppColors.divider,
                      color: _scoreColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            if (onReview != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onReview,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
