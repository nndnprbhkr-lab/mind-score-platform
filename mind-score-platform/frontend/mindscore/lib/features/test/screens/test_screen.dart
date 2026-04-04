import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../providers/test_provider.dart';

// ─── Palette shortcuts ────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6B35C8);
const _kPink = Color(0xFFFF6B9D);
const _kPurpleLight = Color(0xFFA67CF0);
const _kCardBg = Color(0xFF2A1850);
const _kCardBorder = Color(0xFF3D2070);
const _kOptionText = Color(0xFFC8B8F0);
const _kSelectedBg = Color(0x336B35C8); // rgba(107,53,200,0.2)

class TestScreen extends ConsumerStatefulWidget {
  final String testId;
  final String testName;

  const TestScreen({super.key, required this.testId, this.testName = ''});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(testProvider.notifier)
        .loadTest(widget.testId, testName: widget.testName));
  }

  Future<void> _confirmQuit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Test'),
        content:
            const Text('Your progress will be lost. Are you sure you want to quit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(testProvider.notifier).reset();
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _handleSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text(
            'Are you sure? You cannot change your answers after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _kPurple),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(testProvider.notifier).submitTest();
      if (mounted) context.go(AppRoutes.results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(testProvider);

    // ── Loading ───────────────────────────────────────────────────────────────
    if (test.isLoading && test.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: _kPurple),
        ),
      );
    }

    // ── Error ─────────────────────────────────────────────────────────────────
    if (test.error != null && test.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                test.error!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty ─────────────────────────────────────────────────────────────────
    if (test.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final current = test.questions[test.currentIndex];
    final isLast = test.currentIndex == test.questions.length - 1;
    final canProceed = current.selectedIndex != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            _Header(
              testName: test.testName.isEmpty ? widget.testName : test.testName,
              currentIndex: test.currentIndex,
              total: test.questions.length,
              remainingSeconds: test.remainingSeconds,
              onBack: _confirmQuit,
            ),

            // ── Gradient progress bar ────────────────────────────────────────
            _GradientProgressBar(progress: test.progress),

            // ── Question content ─────────────────────────────────────────────
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _QuestionCard(
                      key: ValueKey(test.currentIndex),
                      questionNumber: test.currentIndex + 1,
                      total: test.questions.length,
                      questionText: current.text,
                      options: current.options,
                      selectedIndex: current.selectedIndex,
                      onSelect: (i) => ref
                          .read(testProvider.notifier)
                          .selectAnswer(test.currentIndex, i),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom bar ───────────────────────────────────────────────────
            _BottomBar(
              isLast: isLast,
              canProceed: canProceed,
              isSubmitting: test.isLoading,
              onNext: canProceed
                  ? () => ref.read(testProvider.notifier).nextQuestion()
                  : null,
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String testName;
  final int currentIndex;
  final int total;
  final int remainingSeconds;
  final VoidCallback onBack;

  const _Header({
    required this.testName,
    required this.currentIndex,
    required this.total,
    required this.remainingSeconds,
    required this.onBack,
  });

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  bool get _isLow => remainingSeconds < 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          // Back arrow
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Quit test',
          ),

          // Title + counter (centered)
          Expanded(
            child: Column(
              children: [
                Text(
                  testName.isNotEmpty ? testName : 'Test',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentIndex + 1} of $total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Timer badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isLow
                  ? AppColors.error.withValues(alpha: 0.15)
                  : _kPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLow ? AppColors.error : _kPink,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: _isLow ? AppColors.error : _kPink,
                ),
                const SizedBox(width: 4),
                Text(
                  _fmt(remainingSeconds),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _isLow ? AppColors.error : _kPink,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

// ─────────────────────────────────────────────────────────────────────────────
// Gradient progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _GradientProgressBar extends StatelessWidget {
  final double progress;

  const _GradientProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Track
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _kCardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Fill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      height: 6,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPurple, _kPink],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}% complete',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question card
// ─────────────────────────────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final int total;
  final String questionText;
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    super.key,
    required this.questionNumber,
    required this.total,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number
          Text(
            'Question $questionNumber of $total',
            style: theme.textTheme.labelLarge?.copyWith(
              color: _kPurpleLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),

          // Question text
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          // Answer options
          ...List.generate(options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                index: i,
                text: options[i],
                isSelected: selectedIndex == i,
                onTap: () => onSelect(i),
              )
                  .animate(delay: (i * 40).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.04, end: 0),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Option card
// ─────────────────────────────────────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? _kSelectedBg : _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kPurple : _kCardBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: _kPurple.withValues(alpha: 0.12),
          highlightColor: _kPurple.withValues(alpha: 0.06),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Radio circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _kPurple : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _kPurple : _kCardBorder,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.circle,
                              size: 10, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Option text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isSelected ? Colors.white : _kOptionText,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final bool isLast;
  final bool canProceed;
  final bool isSubmitting;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isLast,
    required this.canProceed,
    required this.isSubmitting,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kCardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Auto-save status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_done_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Auto-saving your progress...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms, delay: 2400.ms),
          const SizedBox(height: 12),

          // Action button
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLast
                  ? _SubmitButton(
                      key: const ValueKey('submit'),
                      isLoading: isSubmitting,
                      onTap: canProceed ? onSubmit : null,
                    )
                  : _NextButton(
                      key: const ValueKey('next'),
                      enabled: canProceed,
                      onTap: onNext,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _NextButton({super.key, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _kCardBorder,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Next Question',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _SubmitButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _kCardBorder,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Submit Test',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
    );
  }
}
