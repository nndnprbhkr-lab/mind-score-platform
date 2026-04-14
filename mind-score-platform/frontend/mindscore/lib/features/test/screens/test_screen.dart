// Active assessment test screen.
//
// Presents questions one-by-one with a Likert-scale answer selector, a
// countdown timer, and a gradient progress bar.  After the last question is
// answered the user can submit, which POSTs all answers to the backend and
// navigates to the appropriate results screen.
//
// Sub-widgets in this file:
//   _Header           — test name, question counter, timer badge.
//   _GradientProgressBar — animated fill bar showing completion percentage.
//   _QuestionCard     — question text + animated option list.
//   _OptionCard       — a single selectable answer tile.
//   _BottomBar        — auto-save indicator + Next / Submit button.
//   _NextButton       — advances to the next question.
//   _SubmitButton     — triggers final submission.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../providers/test_provider.dart';

// ─── TestScreen ───────────────────────────────────────────────────────────────

/// The main widget for the active assessment experience.
///
/// On mount, calls [TestNotifier.loadTest] via a microtask to avoid calling
/// `setState` during the first build.  All mutable state lives in
/// [TestNotifier] / [TestState]; this widget is a pure projection.
class TestScreen extends ConsumerStatefulWidget {
  /// The UUID of the assessment to load.
  final String testId;

  /// Display name shown in the header (used immediately before the API
  /// returns, so the header is never blank).
  final String testName;

  const TestScreen({
    super.key,
    required this.testId,
    this.testName = '',
  });

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  @override
  void initState() {
    super.initState();
    // Use a microtask so the first build completes before any state change.
    Future.microtask(() => ref
        .read(testProvider.notifier)
        .loadTest(widget.testId, testName: widget.testName));
  }

  /// Shows a confirmation dialog before cancelling an in-progress test.
  ///
  /// Resets [testProvider] and navigates to the dashboard only when the user
  /// explicitly confirms.
  Future<void> _confirmQuit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Test'),
        content: const Text(
            'Your progress will be lost. Are you sure you want to quit?'),
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

  /// Shows a confirmation dialog, then submits the test.
  ///
  /// After a successful submission, routes to the correct results screen based
  /// on the [ResultModel.typeCode] returned by the server:
  ///   - `MIND_SCORE` → [AppRoutes.mindScoreResults]
  ///   - anything else (MPI) → [AppRoutes.results]
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(testProvider.notifier).submitTest();
      if (mounted) {
        final tc = ref.read(testProvider).result?.typeCode;
        context.go(
          tc == 'MIND_SCORE' ? AppRoutes.mindScoreResults : AppRoutes.results,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(testProvider);

    // ── Loading ────────────────────────────────────────────────────────────
    if (test.isLoading && test.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    // ── Error ──────────────────────────────────────────────────────────────
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

    // ── Empty ──────────────────────────────────────────────────────────────
    if (test.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final current    = test.questions[test.currentIndex];
    final isLast     = test.currentIndex == test.questions.length - 1;
    final canProceed = current.selectedIndex != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Test name, question counter, countdown timer
            _Header(
              testName:         test.testName.isEmpty ? widget.testName : test.testName,
              currentIndex:     test.currentIndex,
              total:            test.questions.length,
              remainingSeconds: test.remainingSeconds,
              onBack:           _confirmQuit,
            ),

            // Gradient progress fill bar
            _GradientProgressBar(progress: test.progress),

            // Animated question card (fades/slides when question index changes)
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
                      key:            ValueKey(test.currentIndex),
                      questionNumber: test.currentIndex + 1,
                      total:          test.questions.length,
                      questionText:   current.text,
                      options:        current.options,
                      selectedIndex:  current.selectedIndex,
                      onSelect: (i) => ref
                          .read(testProvider.notifier)
                          .selectAnswer(test.currentIndex, i),
                    ),
                  ),
                ),
              ),
            ),

            // Auto-save label + Next / Submit button
            _BottomBar(
              isLast:       isLast,
              canProceed:   canProceed,
              isSubmitting: test.isLoading,
              onNext:       canProceed
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

// ─── _Header ─────────────────────────────────────────────────────────────────

/// The top bar shown during an active assessment.
///
/// Contains a back/quit button, the test name and question counter centred
/// in the middle, and a colour-coded timer badge on the right.  The timer
/// badge turns red when [remainingSeconds] drops below 60 to warn the user.
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

  /// Formats [s] seconds as `MM:SS`.
  String _fmt(int s) {
    final m   = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// `true` when fewer than 60 seconds remain — triggers the red warning state.
  bool get _isLow => remainingSeconds < 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Quit test',
          ),

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
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Timer badge — transitions colour smoothly via AnimatedContainer.
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isLow
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.highlight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLow ? AppColors.error : AppColors.highlight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: _isLow ? AppColors.error : AppColors.highlight,
                ),
                const SizedBox(width: 4),
                Text(
                  _fmt(remainingSeconds),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _isLow ? AppColors.error : AppColors.highlight,
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

// ─── _GradientProgressBar ─────────────────────────────────────────────────────

/// An animated gradient fill bar that shows how far through the test the
/// user is, plus a percentage label beneath it.
class _GradientProgressBar extends StatelessWidget {
  /// Completion fraction in the range [0.0, 1.0].
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
                    // Track (full width, unfilled)
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Fill (animated width, gradient)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      height: 6,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.highlight],
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
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── _QuestionCard ────────────────────────────────────────────────────────────

/// Displays a single question with its numbered heading and answer options.
///
/// The [key] is set to `ValueKey(currentIndex)` by the parent so that
/// [AnimatedSwitcher] produces a fade + slide transition whenever the question
/// changes.  Each option card stagger-animates in on first render.
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
          Text(
            'Question $questionNumber of $total',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.accentLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
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

          // Stagger-animate options so they cascade in from top.
          ...List.generate(options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                index:      i,
                text:       options[i],
                isSelected: selectedIndex == i,
                onTap:      () => onSelect(i),
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

// ─── _OptionCard ──────────────────────────────────────────────────────────────

/// A single selectable answer tile.
///
/// Uses [AnimatedContainer] to smoothly transition the border colour and
/// background between unselected and selected states.  The radio-circle on
/// the left provides an additional selected / unselected cue.
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
        // accentSubtle gives a visible but non-distracting selection fill.
        color: isSelected ? AppColors.accentSubtle : AppColors.primaryMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.cardBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor:    AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Radio circle indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape:  BoxShape.circle,
                    color:  isSelected ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.cardBorder,
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

                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      // Selected options use white for maximum contrast.
                      color: isSelected ? Colors.white : AppColors.optionText,
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

// ─── _BottomBar ───────────────────────────────────────────────────────────────

/// The sticky bottom bar containing an auto-save indicator and the primary
/// action button (Next or Submit).
///
/// The auto-save indicator pulses with a fade-in/out loop to reassure users
/// that their answers are being recorded.
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
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing "auto-save" reassurance label.
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

          // Swaps between Next and Submit depending on whether this is the
          // last question.  AnimatedSwitcher provides a smooth cross-fade.
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLast
                  ? _SubmitButton(
                      key:       const ValueKey('submit'),
                      isLoading: isSubmitting,
                      onTap:     canProceed ? onSubmit : null,
                    )
                  : _NextButton(
                      key:     const ValueKey('next'),
                      enabled: canProceed,
                      onTap:   onNext,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _NextButton / _SubmitButton ──────────────────────────────────────────────

/// Advances to the next question.  Disabled until the current question has
/// a selected answer.
class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _NextButton({super.key, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:         AppColors.accent,
        foregroundColor:         Colors.white,
        disabledBackgroundColor: AppColors.cardBorder,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
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

/// Submits the test.  Shows a spinner while the API request is in-flight.
/// Disabled when the last question has no selected answer.
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _SubmitButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:         AppColors.highlight,
        foregroundColor:         Colors.white,
        disabledBackgroundColor: AppColors.cardBorder,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
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
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
    );
  }
}
