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
import '../../../features/results/providers/results_provider.dart';
import '../../../widgets/mpi/mpi_legend_header.dart';
import 'mind_score_results_screen.dart';
import '../../../widgets/mpi/mpi_radar_chart.dart';
import '../../../widgets/mpi/mpi_dimension_row.dart';
import '../../../widgets/mpi/mpi_action_plan_card.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6B35C8);
const _kPurpleLight = Color(0xFFA67CF0);
const _kPink = Color(0xFFFF6B9D);
const _kCardBg = Color(0xFF2A1850);
const _kCardBorder = Color(0xFF3D2070);

// ─── MPI display data ─────────────────────────────────────────────────────────
class _MpiDisplayData {
  final String typeCode;
  final String typeName;
  final String emoji;
  final String tagline;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> careerPaths;
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

  factory _MpiDisplayData.fromResult(ResultModel result) {
    List<String> parseList(String key) {
      final raw = result.insights?[key];
      if (raw is List) return raw.cast<String>();
      return [];
    }

    return _MpiDisplayData(
      typeCode: result.typeCode ?? '',
      typeName: result.typeName ?? 'Your MindType Profile',
      emoji: result.emoji ?? '🧠',
      tagline: result.tagline ?? '',
      strengths: parseList('strengths'),
      growthAreas: parseList('growthAreas'),
      careerPaths: parseList('careerPaths'),
      communicationStyle:
          result.insights?['communicationStyle'] as String? ?? '',
    );
  }

  factory _MpiDisplayData.fromMpiResult(MpiResult r) {
    return _MpiDisplayData(
      typeCode: r.typeCode,
      typeName: r.typeName,
      emoji: r.emoji,
      tagline: r.tagline,
      strengths: r.strengths,
      growthAreas: r.growthAreas,
      careerPaths: r.careerPaths,
      communicationStyle: r.communicationStyle,
    );
  }
}

// ─── Results screen ───────────────────────────────────────────────────────────
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
    // Refresh results list so Reports tab is up-to-date immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resultsProvider.notifier).load();
    });
  }

  String get _duration {
    final test = ref.read(testProvider);
    final total = test.questions.length * 60;
    final taken = total - test.remainingSeconds;
    final m = taken ~/ 60;
    final s = taken % 60;
    if (m == 0) return '${s}s';
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  String? get _resultId {
    final testResultId = ref.read(testProvider).result?.id;
    if (testResultId != null) return testResultId;
    return ref.read(mpiResultProvider).valueOrNull?.id;
  }

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

  Future<void> _shareResults() async {
    final result = ref.read(testProvider).result;
    final mpi = ref.read(mpiResultProvider).valueOrNull;
    final emoji = result?.emoji ?? mpi?.emoji ?? '🧠';
    final typeName = result?.typeName ?? mpi?.typeName ?? '';
    final typeCode = result?.typeCode ?? mpi?.typeCode ?? '';
    final tagline = result?.tagline ?? mpi?.tagline ?? '';
    final text = 'I just discovered my personality type on MindScore!\n'
        '$emoji $typeName ($typeCode)\n'
        '"$tagline"\n'
        'Powered by MindScore — mind-score.com';
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('Results copied to clipboard — paste to share!');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(testProvider);

    // Route MindScore results to the dedicated screen
    if (test.result?.typeCode == 'MIND_SCORE') {
      return MindScoreResultsScreen(resultModel: test.result!);
    }

    if (test.result == null && !test.isLoading) {
      final mpiResult = ref.watch(mpiResultProvider).valueOrNull;
      if (mpiResult == null) {
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
                  style: FilledButton.styleFrom(backgroundColor: _kPurple),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        );
      }

      final mpiData = _MpiDisplayData.fromMpiResult(mpiResult);
      return ResponsiveWrapper(
        mobile: (ctx) => _MobileLayout(
          mpiData: mpiData,
          duration: '',
          testName: mpiResult.testName,
          isDownloading: _isDownloading,
          onDownload: _downloadReport,
          onShare: _shareResults,
          onBack: () => context.go(AppRoutes.dashboard),
          ref: ref,
        ),
        desktop: (ctx) => _WideLayout(
          mpiData: mpiData,
          duration: '',
          testName: mpiResult.testName,
          isDownloading: _isDownloading,
          onDownload: _downloadReport,
          onShare: _shareResults,
          onBack: () => context.go(AppRoutes.dashboard),
          ref: ref,
        ),
      );
    }

    final result = test.result;
    final mpiData = result != null
        ? _MpiDisplayData.fromResult(result)
        : const _MpiDisplayData(
            typeCode: '',
            typeName: 'Your Profile',
            emoji: '🧠',
            tagline: '',
            strengths: [],
            growthAreas: [],
            careerPaths: [],
            communicationStyle: '',
          );
    final duration = _duration;
    final testName = result?.testName ?? '';

    return ResponsiveWrapper(
      mobile: (ctx) => _MobileLayout(
        mpiData: mpiData,
        duration: duration,
        testName: testName,
        isDownloading: _isDownloading,
        onDownload: _downloadReport,
        onShare: _shareResults,
        onBack: () {
          ref.read(testProvider.notifier).reset();
          context.go(AppRoutes.dashboard);
        },
        ref: ref,
      ),
      desktop: (ctx) => _WideLayout(
        mpiData: mpiData,
        duration: duration,
        testName: testName,
        isDownloading: _isDownloading,
        onDownload: _downloadReport,
        onShare: _shareResults,
        onBack: () {
          ref.read(testProvider.notifier).reset();
          context.go(AppRoutes.dashboard);
        },
        ref: ref,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile layout
// ─────────────────────────────────────────────────────────────────────────────
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
          // 1. MpiLegendHeader
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

          // 2. _HeroCard
          _HeroCard(mpiData: mpiData)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, end: 0),

          // 3. SizedBox(16)
          const SizedBox(height: 16),

          // 4. Radar chart container
          if (mpiResult != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _kCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kCardBorder),
              ),
              child: Center(
                child: MpiRadarChart(result: mpiResult, size: 260),
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 400.ms),

          // 5. SizedBox(16)
          const SizedBox(height: 16),

          // 6. MpiDimensionRow
          if (mpiResult != null)
            MpiDimensionRow(result: mpiResult)
                .animate(delay: 80.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.06, end: 0),

          // 7. SizedBox(16)
          const SizedBox(height: 16),

          // 8. Strengths
          _InsightCard(
            title: 'Your Strengths',
            dotColor: _kPurple,
            items: mpiData.strengths,
          )
              .animate(delay: 140.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          // 9. SizedBox(12)
          const SizedBox(height: 12),

          // 10. Growth Areas
          _InsightCard(
            title: 'Growth Areas',
            dotColor: _kPurpleLight,
            items: mpiData.growthAreas,
          )
              .animate(delay: 180.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          // 11. SizedBox(12)
          const SizedBox(height: 12),

          // 12. MpiActionPlanCard
          if (mpiResult != null)
            MpiActionPlanCard(result: mpiResult)
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms),

          // 13. SizedBox(12)
          const SizedBox(height: 12),

          // 14. Career Paths
          _InsightCard(
            title: 'Career Paths',
            dotColor: _kPink,
            items: mpiData.careerPaths,
          )
              .animate(delay: 220.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          // 15. SizedBox(24)
          const SizedBox(height: 24),

          // 16. Download button
          _DownloadButton(
            isLoading: isDownloading,
            onTap: onDownload,
          ).animate(delay: 280.ms).fadeIn(duration: 300.ms),

          // 17. SizedBox(12)
          const SizedBox(height: 12),

          // 18. Share button
          _ShareButton(onTap: onShare)
              .animate(delay: 320.ms)
              .fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet / Desktop (wide) layout
// ─────────────────────────────────────────────────────────────────────────────
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
          // ── Left panel ──────────────────────────────────────────────────────
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
                                color: _kCardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _kCardBorder),
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
                          title: 'Your Strengths',
                          dotColor: _kPurple,
                          items: mpiData.strengths,
                        ).animate(delay: 140.ms).fadeIn(duration: 350.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InsightCard(
                          title: 'Growth Areas',
                          dotColor: _kPurpleLight,
                          items: mpiData.growthAreas,
                        ).animate(delay: 180.ms).fadeIn(duration: 350.ms),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Right panel (300px) ─────────────────────────────────────────────
          Container(
            width: 300,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: _kCardBorder)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InsightCard(
                    title: 'Career Paths',
                    dotColor: _kPink,
                    items: mpiData.careerPaths,
                  ).animate(delay: 200.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 16),

                  if (mpiData.communicationStyle.isNotEmpty)
                    _CommunicationCard(
                      communicationStyle: mpiData.communicationStyle,
                    ).animate(delay: 240.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 24),

                  _DownloadButton(
                    isLoading: isDownloading,
                    onTap: onDownload,
                  ).animate(delay: 280.ms).fadeIn(duration: 300.ms),

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

// ─────────────────────────────────────────────────────────────────────────────
// Hero card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final _MpiDisplayData mpiData;

  const _HeroCard({required this.mpiData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
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
                        colors: [_kPurple, _kPink],
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
                          color: _kPurple.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _kPurple.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          mpiData.typeCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _kPurpleLight,
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

// ─────────────────────────────────────────────────────────────────────────────
// Info cards row (3 mini cards)
// ─────────────────────────────────────────────────────────────────────────────
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
        color: _kPurpleLight,
      ),
      const _MiniInfoCard(
        label: 'Assessment',
        value: 'MindType',
        color: _kPink,
      ),
      _MiniInfoCard(
        label: 'Duration',
        value: duration,
        color: _kPurple,
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
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kCardBorder),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight card (strengths / growth / career)
// ─────────────────────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String title;
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
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kCardBorder),
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

// ─────────────────────────────────────────────────────────────────────────────
// Communication style card (desktop right panel)
// ─────────────────────────────────────────────────────────────────────────────
class _CommunicationCard extends StatelessWidget {
  final String communicationStyle;

  const _CommunicationCard({required this.communicationStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: _kPurpleLight),
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

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────
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
          backgroundColor: _kPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kCardBorder,
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
