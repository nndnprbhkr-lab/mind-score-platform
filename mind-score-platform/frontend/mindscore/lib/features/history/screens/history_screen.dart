import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/results/providers/results_provider.dart';
import '../../../widgets/result_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsState = ref.watch(resultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('History')),
      body: Builder(builder: (context) {
        if (resultsState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (resultsState.error != null) {
          return Center(
            child: Text(resultsState.error!,
                style: TextStyle(color: AppColors.error)),
          );
        }
        if (resultsState.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No test history yet.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(resultsProvider.notifier).load(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: resultsState.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final r = resultsState.results[i];
              final normalizedScore =
                  ((r.score - 1) / 4 * 100).round().clamp(0, 100);
              return ResultCard(
                testTitle: r.testName,
                score: normalizedScore,
                maxScore: 100,
                correctAnswers: normalizedScore,
                totalQuestions: 100,
                completedAt: r.createdAtUtc,
              );
            },
          ),
        );
      }),
    );
  }
}
