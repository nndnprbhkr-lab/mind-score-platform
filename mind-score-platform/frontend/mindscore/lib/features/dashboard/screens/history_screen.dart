import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/results/providers/results_provider.dart';
import '../../../features/results/screens/mind_score_results_screen.dart';
import '../../../features/results/screens/career_fit_results_screen.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6B35C8);
const _kPurpleLight = Color(0xFFA67CF0);
const _kPink = Color(0xFFFF6B9D);
const _kCardBg = Color(0xFF2A1850);
const _kCardBorder = Color(0xFF3D2070);
const _kTeal = Color(0xFF2E9E75);

// ─── Personality helpers ──────────────────────────────────────────────────────
class _Type {
  final String name;
  final String emoji;
  final Color color;
  const _Type(this.name, this.emoji, this.color);
}

_Type _typeFor(int percent) {
  if (percent >= 80) return const _Type('Analyst', '🔬', _kPurple);
  if (percent >= 60) return const _Type('Visionary', '✨', _kPurpleLight);
  if (percent >= 40) return const _Type('Driver', '⚡', _kPink);
  return const _Type('Supporter', '🤝', _kTeal);
}

int _toPercent(double score) =>
    (((score - 1) / 4) * 100).round().clamp(0, 100);

int _displayScore(ResultModel r) =>
    r.typeCode == 'MIND_SCORE' ? r.score.round() : _toPercent(r.score);

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

// ─── Filter enum ──────────────────────────────────────────────────────────────
enum _Filter { all, highScore, lowScore, recent }

extension _FilterLabel on _Filter {
  String get label => switch (this) {
        _Filter.all => 'All',
        _Filter.highScore => 'Highest Score',
        _Filter.lowScore => 'Lowest Score',
        _Filter.recent => 'Recent',
      };
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Filter _filter = _Filter.all;

  List<ResultModel> _sorted(List<ResultModel> raw) {
    final list = List<ResultModel>.from(raw);
    switch (_filter) {
      case _Filter.highScore:
        list.sort((a, b) => _displayScore(b) - _displayScore(a));
      case _Filter.lowScore:
        list.sort((a, b) => _displayScore(a) - _displayScore(b));
      case _Filter.all:
      case _Filter.recent:
        list.sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resultsProvider);
    final sorted = _sorted(state.results);

    return ResponsiveWrapper(
      mobile: (_) => _MobileLayout(
        state: state,
        sorted: sorted,
        ref: ref,
      ),
      desktop: (_) => _WideLayout(
        state: state,
        sorted: sorted,
        filter: _filter,
        onFilterChanged: (f) => setState(() => _filter = f),
        ref: ref,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile layout
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final ResultsState state;
  final List<ResultModel> sorted;
  final WidgetRef ref;

  const _MobileLayout({
    required this.state,
    required this.sorted,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.isLoading
                        ? 'Loading…'
                        : '${sorted.length} completed assessment${sorted.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0),
            ),

            const SizedBox(height: 16),

            // ── Body ───────────────────────────────────────────────────────
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) return _LoadingList();
    if (state.error != null) return _ErrorState(message: state.error!, ref: ref);
    if (sorted.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      color: _kPurple,
      onRefresh: () => ref.read(resultsProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: sorted.length,
        itemBuilder: (ctx, i) {
          final r = sorted[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MobileCard(
              result: r,
              onTap: () => _showDetail(ctx, r),
            )
                .animate(delay: (i * 40).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.03, end: 0),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, ResultModel r) {
    if (r.typeCode == 'MIND_SCORE') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MindScoreResultsScreen(resultModel: r),
      ));
      return;
    }
    if (r.testName == 'Career Fit Assessment') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CareerFitResultsScreen(resultModel: r),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultDetailSheet(result: r),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet / Desktop layout
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final ResultsState state;
  final List<ResultModel> sorted;
  final _Filter filter;
  final ValueChanged<_Filter> onFilterChanged;
  final WidgetRef ref;

  const _WideLayout({
    required this.state,
    required this.sorted,
    required this.filter,
    required this.onFilterChanged,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment History',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isLoading
                            ? 'Loading…'
                            : '${sorted.length} completed assessment${sorted.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter dropdown
                  _FilterDropdown(
                    value: filter,
                    onChanged: onFilterChanged,
                  ),
                ],
              ).animate().fadeIn(duration: 350.ms),
            ),

            const SizedBox(height: 20),

            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) return _LoadingGrid();
    if (state.error != null) return _ErrorState(message: state.error!, ref: ref);
    if (sorted.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      color: _kPurple,
      onRefresh: () => ref.read(resultsProvider.notifier).load(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemCount: sorted.length,
        itemBuilder: (ctx, i) {
          final r = sorted[i];
          return _WideCard(
            result: r,
            onTap: () => _showDetail(ctx, r),
          )
              .animate(delay: (i * 40).ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, end: 0);
        },
      ),
    );
  }

  void _showDetail(BuildContext context, ResultModel r) {
    if (r.typeCode == 'MIND_SCORE') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MindScoreResultsScreen(resultModel: r),
      ));
      return;
    }
    if (r.testName == 'Career Fit Assessment') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CareerFitResultsScreen(resultModel: r),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultDetailSheet(result: r),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile card
// ─────────────────────────────────────────────────────────────────────────────
class _MobileCard extends StatelessWidget {
  final ResultModel result;
  final VoidCallback onTap;

  const _MobileCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = _displayScore(result);
    final type = _typeFor(percent);

    return Material(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _kPurple.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Emoji in rounded square
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: type.color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(type.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),

              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(result.createdAtUtc),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: _kPurpleLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide (grid) card
// ─────────────────────────────────────────────────────────────────────────────
class _WideCard extends StatefulWidget {
  final ResultModel result;
  final VoidCallback onTap;

  const _WideCard({required this.result, required this.onTap});

  @override
  State<_WideCard> createState() => _WideCardState();
}

class _WideCardState extends State<_WideCard> {
  bool _reportLoading = false;

  Future<void> _viewReport() async {
    setState(() => _reportLoading = true);
    try {
      final data = await ApiClient.get(
        '${ApiConstants.reports}/${widget.result.id}',
        auth: true,
      );
      final url = data['url'] as String? ?? data['reportUrl'] as String?;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await Clipboard.setData(ClipboardData(text: url));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report URL copied to clipboard'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report not available yet'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch report'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reportLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = _displayScore(widget.result);
    final type = _typeFor(percent);

    return Material(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _kPurple.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCardBorder),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: type.color.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(type.emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.result.testName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Date + personality badge
              Row(
                children: [
                  Text(
                    _formatDate(widget.result.createdAtUtc),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.name,
                      style: TextStyle(
                        color: type.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Score + button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_kPurple, _kPink],
                    ).createShader(bounds),
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),

                  // View Report button
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _reportLoading ? null : _viewReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _kPurple.withOpacity(0.18),
                        foregroundColor: _kPurpleLight,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _reportLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                  color: _kPurpleLight, strokeWidth: 2),
                            )
                          : const Text('View Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ResultDetailSheet extends StatelessWidget {
  final ResultModel result;

  const _ResultDetailSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = _displayScore(result);
    final type = _typeFor(percent);

    final topPct = switch (percent) {
      >= 90 => 'Top 5%',
      >= 80 => 'Top 10%',
      >= 70 => 'Top 25%',
      >= 60 => 'Top 50%',
      _ => 'Top 75%',
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: _kCardBorder)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kCardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    // Score + type header
                    Row(
                      children: [
                        Text(type.emoji,
                            style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (b) =>
                                    const LinearGradient(
                                  colors: [_kPurple, _kPink],
                                ).createShader(b),
                                child: Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: type.color
                                          .withOpacity(0.18),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      type.name,
                                      style: TextStyle(
                                        color: type.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _kPink.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      topPct,
                                      style: const TextStyle(
                                        color: _kPink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: _kCardBorder),
                    const SizedBox(height: 16),

                    // Test info
                    _SheetRow(
                      icon: Icons.assignment_outlined,
                      label: 'Assessment',
                      value: result.testName,
                    ),
                    _SheetRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Completed',
                      value: _formatDate(result.createdAtUtc),
                    ),
                    _SheetRow(
                      icon: Icons.bar_chart_rounded,
                      label: 'Score',
                      value: '$percent / 100',
                      valueColor: _kPurpleLight,
                    ),
                    _SheetRow(
                      icon: Icons.emoji_events_outlined,
                      label: 'Ranking',
                      value: topPct,
                      valueColor: _kPink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final _Filter value;
  final ValueChanged<_Filter> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kCardBorder),
      ),
      child: DropdownButton<_Filter>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: _kCardBg,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary, size: 20),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: _Filter.values
            .map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f.label),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading states
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCardBorder),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1200.ms,
              color: _kCardBorder.withOpacity(0.6),
            ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kCardBorder),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1200.ms,
            color: _kCardBorder.withOpacity(0.6),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / error states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No assessments yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete a test to see your history here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final WidgetRef ref;

  const _ErrorState({required this.message, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => ref.read(resultsProvider.notifier).load(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
