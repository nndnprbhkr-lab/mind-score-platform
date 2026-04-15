// Context selection screen.
//
// Shown before an adaptive MPI assessment begins.  The user picks the lens
// through which they want to be assessed — this tunes which questions are
// served by the adaptive engine and shapes the result insights returned.
//
// Five contexts are supported: General, Career, Relationships, Leadership,
// and Personal Development.  Each card shows a brand icon, a bold label,
// and a one-line description.
//
// On selection the screen navigates to /test/:testId, passing both the
// test name and the selected context index as route extras.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';

// ─── Context metadata ──────────────────────────────────────────────────────────

/// Visual metadata associated with each [AssessmentContext] value.
class _ContextMeta {
  final AssessmentContext context;
  final IconData icon;
  final Color iconColor;
  final Color cardAccent;

  const _ContextMeta({
    required this.context,
    required this.icon,
    required this.iconColor,
    required this.cardAccent,
  });
}

const _contextMetas = [
  _ContextMeta(
    context: AssessmentContext.general,
    icon: Icons.explore_rounded,
    iconColor: Color(0xFFA67CF0),
    cardAccent: Color(0xFF6B35C8),
  ),
  _ContextMeta(
    context: AssessmentContext.career,
    icon: Icons.work_rounded,
    iconColor: Color(0xFF60A5FA),
    cardAccent: Color(0xFF3B82F6),
  ),
  _ContextMeta(
    context: AssessmentContext.relationships,
    icon: Icons.favorite_rounded,
    iconColor: Color(0xFFFF6B9D),
    cardAccent: Color(0xFFEC4899),
  ),
  _ContextMeta(
    context: AssessmentContext.leadership,
    icon: Icons.emoji_events_rounded,
    iconColor: Color(0xFFFBBF24),
    cardAccent: Color(0xFFF59E0B),
  ),
  _ContextMeta(
    context: AssessmentContext.personalDevelopment,
    icon: Icons.spa_rounded,
    iconColor: Color(0xFF34D399),
    cardAccent: Color(0xFF10B981),
  ),
];

// ─── ContextSelectionScreen ───────────────────────────────────────────────────

/// Lets the user choose a context before starting an adaptive assessment.
class ContextSelectionScreen extends StatelessWidget {
  /// The UUID of the assessment to start after context selection.
  final String testId;

  /// Human-readable name displayed in the header.
  final String testName;

  const ContextSelectionScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  void _select(BuildContext context, AssessmentContext ctx) {
    context.go(
      AppRoutes.testWithId(testId),
      extra: {'testName': testName, 'context': ctx.apiValue},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                    tooltip: 'Back to dashboard',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Context',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: -0.06, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'This shapes which questions you\'re asked and how your results are framed.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: -0.04, end: 0),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Context cards ────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: _contextMetas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final meta = _contextMetas[i];
                  return _ContextCard(
                    meta: meta,
                    index: i,
                    onTap: () => _select(context, meta.context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ContextCard ─────────────────────────────────────────────────────────────

class _ContextCard extends StatelessWidget {
  final _ContextMeta meta;
  final int index;
  final VoidCallback onTap;

  const _ContextCard({
    required this.meta,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: meta.cardAccent.withOpacity(0.12),
          highlightColor: meta.cardAccent.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: meta.cardAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(meta.icon, color: meta.iconColor, size: 26),
                ),

                const SizedBox(width: 16),

                // Label + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.context.displayLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.context.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 320.ms)
        .slideX(begin: 0.04, end: 0);
  }
}
