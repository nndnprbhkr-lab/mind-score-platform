import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../providers/test_provider.dart';
import '../../../widgets/question_widget.dart';
import '../../../widgets/timer_widget.dart';

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(testProvider.notifier).loadTest(''));
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text(
            'Are you sure you want to submit? You cannot change answers after submission.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(testProvider.notifier).submitTest();
      context.go(AppRoutes.results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(testProvider);
    final isDesktop = Responsive.isDesktop(context);

    if (test.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (test.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final current = test.questions[test.currentIndex];
    final progress = (test.currentIndex + 1) / test.questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Question ${test.currentIndex + 1}/${test.questions.length}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Quit Test'),
              content: const Text('Your progress will be lost.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continue')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRoutes.dashboard);
                    },
                    child: const Text('Quit',
                        style: TextStyle(color: AppColors.error))),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TimerWidget(remainingSeconds: test.remainingSeconds),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 720 : double.infinity),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: QuestionWidget(
              questionNumber: test.currentIndex + 1,
              totalQuestions: test.questions.length,
              questionText: current.text,
              options: current.options,
              selectedIndex: test.selectedAnswers[test.currentIndex],
              onOptionSelected: (i) =>
                  ref.read(testProvider.notifier).selectAnswer(test.currentIndex, i),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (test.currentIndex > 0)
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(testProvider.notifier).prevQuestion(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Previous'),
                ),
              const Spacer(),
              test.currentIndex < test.questions.length - 1
                  ? FilledButton.icon(
                      onPressed: current.selectedIndex == null
                          ? null
                          : () =>
                              ref.read(testProvider.notifier).nextQuestion(),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next'),
                    )
                  : FilledButton.icon(
                      onPressed: _confirmSubmit,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Submit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
