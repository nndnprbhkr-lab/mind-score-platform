// Active adaptive assessment screen.
//
// Presents one question at a time, driven by the stateless adaptive engine on
// the server.  The client accumulates answered history and sends it with each
// POST /api/questions/next call via [TestNotifier.nextQuestion].
//
// Supported question formats:
//   Likert   — 5-point agree/disagree scale (standard).
//   Scenario — Situational Judgment Test: story card with 4–5 concrete options.
//   FollowUp — AI-generated follow-up; rendered like Likert for now.
//
// Sub-widgets:
//   _Header              — test name, answered counter, timer badge.
//   _GradientProgressBar — animated server-driven fill bar.
//   _LikertCard          — question text + 5 Likert option tiles.
//   _ScenarioCard        — scenario text + variable option tiles.
//   _OptionTile          — shared selectable tile used by both card types.
//   _BottomBar           — auto-save indicator + Next button.
//   _NextButton          — advances to the next question (disabled if unanswered).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../providers/test_provider.dart';

// ─── Likert labels ─────────────────────────────────────────────────────────────

const _kLikertOptions = [
  '1 — Strongly Disagree',
  '2 — Disagree',
  '3 — Neutral',
  '4 — Agree',
  '5 — Strongly Agree',
];

// ─── TestScreen ───────────────────────────────────────────────────────────────

/// The main widget for the active adaptive assessment experience.
class TestScreen extends ConsumerStatefulWidget {
  final String testId;
  final String testName;

  /// The context the user selected on the previous screen.
  final AssessmentContext context;

  const TestScreen({
    super.key,
    required this.testId,
    this.testName = '',
    this.context = AssessmentContext.general,
  });

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(testProvider.notifier)
        .startAdaptive(widget.testId, widget.context, testName: widget.testName));
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Navigates to the correct results screen once a result is available.
  void _navigateToResults(String? typeCode) {
    if (!mounted) return;
    context.go(
      typeCode == 'MIND_SCORE'
          ? AppRoutes.mindScoreResults
          : AppRoutes.results,
    );
  }

  // ── Quit dialog ────────────────────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Navigate to results as soon as a result arrives.
    ref.listen<TestState>(testProvider, (prev, next) {
      if (next.result != null && prev?.result == null) {
        _navigateToResults(next.result!.typeCode);
      }
    });

    final test = ref.watch(testProvider);

    // ── Submission loading ─────────────────────────────────────────────────
    if (test.isSubmitted && test.result == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 20),
              Text(
                'Scoring your results…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    // ── Initial loading ────────────────────────────────────────────────────
    if (test.isLoading && test.currentQuestion == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    // ── Error ──────────────────────────────────────────────────────────────
    if (test.error != null && test.currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  test.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
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

    // ── No question (shouldn't normally reach here) ─────────────────────────
    if (test.currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final q          = test.currentQuestion!;
    final canProceed = test.selectedIndex != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              testName:         test.testName.isEmpty ? widget.testName : test.testName,
              answeredCount:    test.answeredCount,
              estimatedRemaining: test.estimatedRemaining,
              remainingSeconds: test.remainingSeconds,
              onBack:           _confirmQuit,
            ),

            _GradientProgressBar(progress: test.progress),

            // Question content — animates on each new question.
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
                    child: q.questionType == QuestionType.scenario
                        ? _ScenarioCard(
                            key:           ValueKey(q.id),
                            questionText:  q.text,
                            options: q.scenarioOptions ?? const [],
                            selectedIndex: test.selectedIndex,
                            onSelect: (i) =>
                                ref.read(testProvider.notifier).selectAnswer(i),
                          )
                        : _LikertCard(
                            key:           ValueKey(q.id),
                            questionText:  q.text,
                            selectedIndex: test.selectedIndex,
                            onSelect: (i) =>
                                ref.read(testProvider.notifier).selectAnswer(i),
                          ),
                  ),
                ),
              ),
            ),

            _BottomBar(
              canProceed:   canProceed,
              isLoading:    test.isLoading,
              onNext: canProceed
                  ? () => ref.read(testProvider.notifier).nextQuestion()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String testName;
  final int answeredCount;
  final int estimatedRemaining;
  final int remainingSeconds;
  final VoidCallback onBack;

  const _Header({
    required this.testName,
    required this.answeredCount,
    required this.estimatedRemaining,
    required this.remainingSeconds,
    required this.onBack,
  });

  String _fmt(int s) {
    final m   = s ~/ 60;
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
                  testName.isNotEmpty ? testName : 'Assessment',
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
                  'Q${answeredCount + 1}  ·  ~$estimatedRemaining left',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Countdown timer badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isLow
                  ? AppColors.error.withOpacity(0.15)
                  : AppColors.highlight.withOpacity(0.15),
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
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: 6,
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
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

// ─── _LikertCard ─────────────────────────────────────────────────────────────

/// Renders a standard 5-point Likert-scale question.
class _LikertCard extends StatelessWidget {
  final String questionText;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _LikertCard({
    super.key,
    required this.questionText,
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
            questionText,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'How much do you agree with this statement?',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ...List.generate(_kLikertOptions.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                text:       _kLikertOptions[i],
                isSelected: selectedIndex == i,
                onTap:      () => onSelect(i),
                accent:     AppColors.accent,
              )
                  .animate(delay: (i * 40).ms)
                  .fadeIn(duration: 280.ms)
                  .slideX(begin: 0.04, end: 0),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── _ScenarioCard ────────────────────────────────────────────────────────────

/// Renders a Situational Judgment Test scenario question.
///
/// The scenario text is displayed as a story card with a coloured left border,
/// followed by the selectable option tiles.
class _ScenarioCard extends StatelessWidget {
  final String questionText;

  /// Each entry is `{'text': String, 'traitMappings': Map<String, dynamic>}`.
  final List<Map<String, dynamic>> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _ScenarioCard({
    super.key,
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
          // Scenario story card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryMid,
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: AppColors.highlight, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_rounded,
                        size: 16, color: AppColors.highlight),
                    const SizedBox(width: 6),
                    Text(
                      'Situation',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms)
              .slideY(begin: -0.03, end: 0),

          const SizedBox(height: 20),

          Text(
            'What would you most likely do?',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 14),

          // Option tiles
          ...List.generate(options.length, (i) {
            final optionText = options[i]['text'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                text:       optionText,
                isSelected: selectedIndex == i,
                onTap:      () => onSelect(i),
                accent:     AppColors.highlight,
              )
                  .animate(delay: (i * 50).ms)
                  .fadeIn(duration: 280.ms)
                  .slideX(begin: 0.04, end: 0),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── _OptionTile ──────────────────────────────────────────────────────────────

/// Shared selectable answer tile used by both [_LikertCard] and [_ScenarioCard].
///
/// [accent] controls the selection highlight colour so each card type can
/// carry its own visual identity.
class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? accent.withOpacity(0.15) : AppColors.primaryMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? accent : AppColors.cardBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor:    accent.withOpacity(0.12),
          highlightColor: accent.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Radio circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape:  BoxShape.circle,
                    color:  isSelected ? accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? accent : AppColors.cardBorder,
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
                      color:      isSelected ? Colors.white : AppColors.optionText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

class _BottomBar extends StatelessWidget {
  final bool canProceed;
  final bool isLoading;
  final VoidCallback? onNext;

  const _BottomBar({
    required this.canProceed,
    required this.isLoading,
    required this.onNext,
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
          // Pulsing auto-save label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_done_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Progress saved automatically',
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

          SizedBox(
            width: double.infinity,
            child: _NextButton(
              enabled:   canProceed,
              isLoading: isLoading,
              onTap:     onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _NextButton ──────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;

  const _NextButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onTap : null,
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
