// MPI (MindType Profile Inventory) results screen.
//
// Displays the user's four-letter type code, a radar chart of dimension
// percentages, strengths/growth/career insight cards, an action plan, and
// buttons to download the PDF report or copy a share text.
//
// Data source: [testProvider] (just-submitted result) or [mpiResultProvider]
// (most recent MPI result loaded from history), with a fallback empty state.
//
// The layout is responsive via [ResponsiveWrapper]:
//   - Mobile:  single scrollable ListView.
//   - Desktop: two-column Row (main content left, sidebar right).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/test/providers/test_provider.dart';
import '../../../core/models/mpi_models.dart';
import '../../../features/results/providers/mpi_result_provider.dart';
import '../../../widgets/mpi/mpi_legend_header.dart';
import '../../../widgets/mpi/mpi_radar_chart.dart';
import '../../../widgets/mpi/mpi_dimension_row.dart';
import '../../../widgets/mpi/mpi_action_plan_card.dart';

// ─── _MpiDisplayData ─────────────────────────────────────────────────────────

/// A view-model that flattens the various MPI result sources into a single
/// shape consumed by the layout widgets.
///
/// Both [ResultModel] (from [testProvider]) and [MpiResult] (from
/// [mpiResultProvider]) carry the same logical data but in different
/// structures.  This adapter class normalises them so the layout widgets
/// don't need to know the source.
class _MpiDisplayData {
  /// Four-letter type code (e.g. `EOLS`).
  final String typeCode;

  /// Human-readable personality type name (e.g. "The Strategist").
  final String typeName;

  /// Emoji associated with the personality type.
  final String emoji;

  /// Motivational tagline for the personality type.
  final String tagline;

  /// Key strengths for this type.
  final List<String> strengths;

  /// Recommended growth areas.
  final List<String> growthAreas;

  /// Career paths suited to this personality type.
  final List<String> careerPaths;

  /// Description of how this type typically communicates.
  final String communicationStyle;

  const _MpiDisplayData({
    required this.typeCode,
    required this.typeName,
    required this.emoji,
    required this.tagline,
    required this.strengths,
    required this.growthAreas,
    required this.careerPaths,
    required this.communicationStyle,
  });

  /// Constructs from a [ResultModel] (just-submitted, still in [testProvider]).
  ///
  /// Parses list fields from the raw [ResultModel.insights] JSON map.
  factory _MpiDisplayData.fromResult(ResultModel result) {
    List<String> parseList(String key) {
      final raw = result.insights?[key];
      if (raw is List) return raw.cast<String>();
      return [];
    }

    return _MpiDisplayData(
      typeCode:          result.typeCode ?? '',
      typeName:          result.typeName ?? 'Your MindType Profile',
      emoji:             result.emoji ?? '🧠',
      tagline:           result.tagline ?? '',
      strengths:         parseList('strengths'),
      growthAreas:       parseList('growthAreas'),
      careerPaths:       parseList('careerPaths'),
      communicationStyle:
          result.insights?['communicationStyle'] as String? ?? '',
    );
  }

  /// Constructs from a fully-typed [MpiResult] (loaded from [mpiResultProvider]).
  factory _MpiDisplayData.fromMpiResult(MpiResult r) {
    return _MpiDisplayData(
      typeCode:          r.typeCode,
      typeName:          r.typeName,
      emoji:             r.emoji,
      tagline:           r.tagline,
      strengths:         r.strengths,
      growthAreas:       r.growthAreas,
      careerPaths:       r.careerPaths,
      communicationStyle: r.communicationStyle,
    );
  }
}

// ─── ResultsScreen ───────────────────────────────────────────────────────────

/// The root widget for the MPI results screen.
///
/// Orchestrates data resolution:
///   1. Checks [testProvider] for a just-submitted result (excluding
///      `MIND_SCORE` which has its own screen).
///   2. Falls back to [mpiResultProvider] for the most recent server-side
///      MPI result.
///   3. Shows a loading spinner while [mpiResultProvider] is reloading.
///   4. Shows an empty-state view if no MPI result is available at all.
///
/// Once data is resolved, delegates layout to [_MobileLayout] or [_WideLayout]
/// via [ResponsiveWrapper].
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  /// Formats the elapsed test duration for display.
  ///
  /// Returns `—` if no duration was recorded.  Omits the seconds component
  /// when the duration is a whole number of minutes.
  String get _duration {
    final secs = ref.read(testProvider).durationSeconds;
    if (secs == null || secs <= 0) return '—';
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m == 0) return '${s}s';
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  /// Resolves the result ID to use for PDF report requests.
  ///
  /// Prefers the just-submitted result from [testProvider]; falls back to
  /// the most recent MPI result from [mpiResultProvider].
  String? get _resultId {
    final testResultId = ref.read(testProvider).result?.id;
    if (testResultId != null) return testResultId;
    return ref.read(mpiResultProvider).valueOrNull?.id;
  }

  /// Requests the signed report URL from the backend and attempts to open it.
  ///
  /// If the URL cannot be launched (e.g. no browser on desktop), falls back
  /// to copying it to the clipboard.  Shows a snackbar for all outcomes.
  Future<void> _downloadReport() async {
    final resultId = _resultId;
    if (resultId == null) return;

    setState(() => _isDownloading = true);
    try {
      final data = await ApiClient.get(
        '${ApiConstants.reports}/$resultId',
        auth: true,
      );
      final url = data['url'] as String? ?? data['reportUrl'] as String?;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await Clipboard.setData(ClipboardData(text: url));
          _showSnack('Report URL copied to clipboard');
        }
      } else {
        _showSnack('Report not available yet. Try again shortly.');
      }
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('Failed to fetch report. Please try again.');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Composes a shareable text summary and copies it to the clipboard.
  Future<void> _shareResults() async {
    final result = ref.read(testProvider).result;
    final mpi    = ref.read(mpiResultProvider).valueOrNull;
    final emoji    = result?.emoji    ?? mpi?.emoji    ?? '🧠';
    final typeName = result?.typeName ?? mpi?.typeName ?? '';
    final typeCode = result?.typeCode ?? mpi?.typeCode ?? '';
    final tagline  = result?.tagline  ?? mpi?.tagline  ?? '';
    final text = 'I just discovered my personality type on MindScore!\n'
        '$emoji $typeName ($typeCode)\n'
        '"$tagline"\n'
        'Powered by MindScore — mind-score.com';
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('Results copied to clipboard — paste to share!');
  }

  /// Displays a floating snackbar with [msg].
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(testProvider);
    // Filter out MIND_SCORE results — they belong to a separate screen.
    final result = test.result?.typeCode == 'MIND_SCORE' ? null : test.result;

    if (result == null && !test.isLoading) {
      final mpiAsync = ref.watch(mpiResultProvider);

      // Keep the screen stable while the provider is reloading.
      if (mpiAsync.isLoading) {
        return const Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }

      final mpiResult = mpiAsync.valueOrNull;

      if (mpiResult == null) {
        // No MPI result available at all — show empty state.
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment_outlined,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No results to display.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    ref.read(testProvider.notifier).reset();
                    context.go(AppRoutes.dashboard);
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        );
      }

      // Have an MPI result from history — build display data and show layout.
      final mpiData = _MpiDisplayData.fromMpiResult(mpiResult);
      return ResponsiveWrapper(
        mobile: (ctx) => _MobileLayout(
          mpiData:       mpiData,
          duration:      '',
          testName:      mpiResult.testName,
          isDownloading: _isDownloading,
          onDownload:    _downloadReport,
          onShare:       _shareResults,
          onBack:        () => context.go(AppRoutes.dashboard),
          ref:           ref,
        ),
        desktop: (ctx) => _WideLayout(
          mpiData:       mpiData,
          duration:      '',
          testName:      mpiResult.testName,
          isDownloading: _isDownloading,
          onDownload:    _downloadReport,
          onShare:       _shareResults,
          onBack:        () => context.go(AppRoutes.dashboard),
          ref:           ref,
        ),
      );
    }

    // Have a just-submitted result from testProvider.
    final mpiData = result != null
        ? _MpiDisplayData.fromResult(result)
        : const _MpiDisplayData(
            typeCode:          '',
            typeName:          'Your Profile',
            emoji:             '🧠',
            tagline:           '',
            strengths:         [],
            growthAreas:       [],
            careerPaths:       [],
            communicationStyle: '',
          );
    final duration = _duration;
    final testName = result?.testName ?? '';

    return ResponsiveWrapper(
      mobile: (ctx) => _MobileLayout(
        mpiData:       mpiData,
        duration:      duration,
        testName:      testName,
        isDownloading: _isDownloading,
        onDownload:    _downloadReport,
        onShare:       _shareResults,
        onBack: () {
          ref.read(testProvider.notifier).reset();
          context.go(AppRoutes.dashboard);
        },
        ref: ref,
      ),
      desktop: (ctx) => _WideLayout(
        mpiData:       mpiData,
        duration:      duration,
        testName:      testName,
        isDownloading: _isDownloading,
        onDownload:    _downloadReport,
        onShare:       _shareResults,
        onBack: () {
          ref.read(testProvider.notifier).reset();
          context.go(AppRoutes.dashboard);
        },
        ref: ref,
      ),
    );
  }
}

// ─── Mobile layout ────────────────────────────────────────────────────────────

/// Single-column scrollable layout for narrow (mobile) viewports.
///
/// Renders: legend header → hero card → radar chart → dimension row →
/// strengths → growth areas → action plan → career paths → download → share.
class _MobileLayout extends StatelessWidget {
  final _MpiDisplayData mpiData;
  final String duration;
  final String testName;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onBack;
  final WidgetRef ref;

  const _MobileLayout({
    required this.mpiData,
    required this.duration,
    required this.testName,
    required this.isDownloading,
    required this.onDownload,
    required this.onShare,
    required this.onBack,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final mpiResult = ref.watch(mpiResultProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: onBack,
        ),
        title: const Text('Your Results'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Dimension legend strip at the top
          Consumer(builder: (context, ref, _) {
            final mpi = ref.watch(mpiResultProvider);
            return mpi.maybeWhen(
              data: (r) => r != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MpiLegendHeader(result: r)
                          .animate()
                          .fadeIn(duration: 350.ms),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            );
          }),

          _HeroCard(mpiData: mpiData)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 16),

          if (mpiResult != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryMid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: MpiRadarChart(result: mpiResult, size: 260),
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          if (mpiResult != null)
            MpiDimensionRow(result: mpiResult)
                .animate(delay: 80.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 16),

          _InsightCard(
            title:    'Your Strengths',
            dotColor: AppColors.accent,
            items:    mpiData.strengths,
          )
              .animate(delay: 140.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 12),

          _InsightCard(
            title:    'Growth Areas',
            dotColor: AppColors.accentLight,
            items:    mpiData.growthAreas,
          )
              .animate(delay: 180.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 12),

          if (mpiResult != null)
            MpiActionPlanCard(result: mpiResult)
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms),

          const SizedBox(height: 12),

          _InsightCard(
            title:    'Career Paths',
            dotColor: AppColors.highlight,
            items:    mpiData.careerPaths,
          )
              .animate(delay: 220.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 24),

          _DownloadButton(isLoading: isDownloading, onTap: onDownload)
              .animate(delay: 280.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          _ShareButton(onTap: onShare)
              .animate(delay: 320.ms)
              .fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

// ─── Wide (desktop) layout ────────────────────────────────────────────────────

/// Two-column layout for tablet / desktop viewports.
///
/// Left column (scrollable): hero card → info cards row → radar chart +
/// dimension row (side by side) → action plan → strengths/growth areas.
/// Right column (300 px sidebar): career paths → communication style →
/// download button → share button.
class _WideLayout extends StatelessWidget {
  final _MpiDisplayData mpiData;
  final String duration;
  final String testName;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onBack;
  final WidgetRef ref;

  const _WideLayout({
    required this.mpiData,
    required this.duration,
    required this.testName,
    required this.isDownloading,
    required this.onDownload,
    required this.onShare,
    required this.onBack,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final mpiResult = ref.watch(mpiResultProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: onBack,
        ),
        title: const Text('Your Results'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main content (left) ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(mpiData: mpiData)
                      .animate()
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  _InfoCardsRow(mpiData: mpiData, duration: duration)
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 350.ms),

                  if (mpiResult != null) ...[
                    const SizedBox(height: 20),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMid,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.cardBorder),
                              ),
                              child: Center(
                                child: MpiRadarChart(
                                    result: mpiResult, size: 240),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MpiDimensionRow(result: mpiResult),
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 350.ms),

                    const SizedBox(height: 24),

                    MpiActionPlanCard(result: mpiResult)
                        .animate(delay: 120.ms)
                        .fadeIn(duration: 350.ms),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InsightCard(
                          title:    'Your Strengths',
                          dotColor: AppColors.accent,
                          items:    mpiData.strengths,
                        )
                            .animate(delay: 140.ms)
                            .fadeIn(duration: 350.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InsightCard(
                          title:    'Growth Areas',
                          dotColor: AppColors.accentLight,
                          items:    mpiData.growthAreas,
                        )
                            .animate(delay: 180.ms)
                            .fadeIn(duration: 350.ms),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Sidebar (right, 300 px) ──────────────────────────────────────
          Container(
            width: 300,
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InsightCard(
                    title:    'Career Paths',
                    dotColor: AppColors.highlight,
                    items:    mpiData.careerPaths,
                  ).animate(delay: 200.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 16),

                  if (mpiData.communicationStyle.isNotEmpty)
                    _CommunicationCard(
                      communicationStyle: mpiData.communicationStyle,
                    ).animate(delay: 240.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 24),

                  _DownloadButton(isLoading: isDownloading, onTap: onDownload)
                      .animate(delay: 280.ms)
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 12),

                  _ShareButton(onTap: onShare)
                      .animate(delay: 310.ms)
                      .fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _HeroCard ────────────────────────────────────────────────────────────────

/// Displays the personality emoji, type name with gradient, type code badge,
/// and tagline.
class _HeroCard extends StatelessWidget {
  final _MpiDisplayData mpiData;

  const _HeroCard({required this.mpiData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(mpiData.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accent, AppColors.highlight],
                      ).createShader(bounds),
                      child: Text(
                        mpiData.typeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (mpiData.typeCode.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          mpiData.typeCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accentLight,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (mpiData.tagline.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              mpiData.tagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── _InfoCardsRow ────────────────────────────────────────────────────────────

/// A row of three compact metric cards: type code, assessment name, duration.
class _InfoCardsRow extends StatelessWidget {
  final _MpiDisplayData mpiData;
  final String duration;

  const _InfoCardsRow({required this.mpiData, required this.duration});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniInfoCard(
        label: 'Type Code',
        value: mpiData.typeCode.isNotEmpty ? mpiData.typeCode : '—',
        color: AppColors.accentLight,
      ),
      const _MiniInfoCard(
        label: 'Assessment',
        value: 'MindType',
        color: AppColors.highlight,
      ),
      _MiniInfoCard(
        label: 'Duration',
        value: duration,
        color: AppColors.accent,
      ),
    ];

    return Row(
      children: cards
          .asMap()
          .entries
          .expand((e) => [
                Expanded(child: e.value),
                if (e.key < cards.length - 1) const SizedBox(width: 10),
              ])
          .toList(),
    );
  }
}

/// A compact single-metric card used in the info cards row.
class _MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniInfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── _InsightCard ─────────────────────────────────────────────────────────────

/// A bulleted list card used for strengths, growth areas, and career paths.
///
/// Each bullet is a coloured dot ([dotColor]) followed by the item text.
class _InsightCard extends StatelessWidget {
  final String title;

  /// Colour of the bullet dot — differentiates card types visually.
  final Color dotColor;
  final List<String> items;

  const _InsightCard({
    required this.title,
    required this.dotColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'No data available.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── _CommunicationCard ───────────────────────────────────────────────────────

/// Displays the communication-style description in the desktop sidebar.
class _CommunicationCard extends StatelessWidget {
  final String communicationStyle;

  const _CommunicationCard({required this.communicationStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppColors.accentLight),
              const SizedBox(width: 8),
              Text(
                'Communication Style',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            communicationStyle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

/// Full-width button to request and open the PDF report.
///
/// Shows a progress indicator while [isLoading] is `true` (the signed URL
/// is being fetched from the server).
class _DownloadButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _DownloadButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.highlight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.cardBorder,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.download_rounded, size: 18),
        label: Text(
          isLoading ? 'Preparing PDF…' : 'Download PDF Report',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}

/// Full-width outlined button to copy a share text to the clipboard.
class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text(
          'Share Results',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}
