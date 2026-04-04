import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/test/providers/test_provider.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6B35C8);
const _kPurpleLight = Color(0xFFA67CF0);
const _kPink = Color(0xFFFF6B9D);
const _kCardBg = Color(0xFF2A1850);
const _kCardBorder = Color(0xFF3D2070);
const _kTeal = Color(0xFF2E9E75);

// ─── Personality type model ───────────────────────────────────────────────────
class _PersonalityProfile {
  final String type;
  final String emoji;
  final String tagline;
  final String description;
  final Color color;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> careerPaths;
  final String communicationStyle;

  const _PersonalityProfile({
    required this.type,
    required this.emoji,
    required this.tagline,
    required this.description,
    required this.color,
    required this.strengths,
    required this.growthAreas,
    required this.careerPaths,
    required this.communicationStyle,
  });

  static _PersonalityProfile fromScore(int percent) {
    if (percent >= 80) return _analyst;
    if (percent >= 60) return _visionary;
    if (percent >= 40) return _driver;
    return _supporter;
  }

  static const _analyst = _PersonalityProfile(
    type: 'Analyst',
    emoji: '🔬',
    tagline: 'Logical · Precise · Strategic',
    description:
        'You approach problems with systematic logic and deep analytical thinking. '
        'You excel at breaking down complexity into clear, actionable insights.',
    color: _kPurple,
    strengths: [
      'Critical thinking & data analysis',
      'Strategic long-term planning',
      'Pattern recognition',
      'Objective decision making',
    ],
    growthAreas: [
      'Work-life balance',
      'Emotional expression',
      'Embracing ambiguity',
    ],
    careerPaths: [
      '📊  Data Scientist',
      '🏛️  Strategy Consultant',
      '🔍  Research Analyst',
      '🖥️  Software Architect',
    ],
    communicationStyle:
        'Direct and precise — you prefer facts over feelings and value clear, '
        'well-reasoned arguments.',
  );

  static const _visionary = _PersonalityProfile(
    type: 'Visionary',
    emoji: '✨',
    tagline: 'Creative · Inspiring · Imaginative',
    description:
        'You see possibilities others miss and inspire those around you with your '
        'big-picture thinking and infectious enthusiasm.',
    color: _kPurpleLight,
    strengths: [
      'Creative problem solving',
      'Big-picture vision',
      'Inspiring & motivating others',
      'Connecting disparate ideas',
    ],
    growthAreas: [
      'Follow-through on details',
      'Realistic planning',
      'Managing time constraints',
    ],
    careerPaths: [
      '🚀  Product Manager',
      '💡  Entrepreneur',
      '🎨  Creative Director',
      '🎯  UX Designer',
    ],
    communicationStyle:
        'Enthusiastic and imaginative — you paint vivid pictures with words and '
        'bring energy to every conversation.',
  );

  static const _driver = _PersonalityProfile(
    type: 'Driver',
    emoji: '⚡',
    tagline: 'Goal-oriented · Decisive · Results-driven',
    description:
        'You thrive under pressure and relentlessly pursue results. '
        'Your determination and focus make you a natural leader when deadlines matter.',
    color: _kPink,
    strengths: [
      'Goal achievement under pressure',
      'Fast, confident decisions',
      'Leading teams to results',
      'Cutting through obstacles',
    ],
    growthAreas: [
      'Patience with slower thinkers',
      'Active listening',
      'Collaborative approach',
    ],
    careerPaths: [
      '📋  Project Manager',
      '💼  Sales Director',
      '⚙️  Operations Lead',
      '📈  Business Developer',
    ],
    communicationStyle:
        'Results-focused and assertive — you get straight to the point and '
        'push for action over endless discussion.',
  );

  static const _supporter = _PersonalityProfile(
    type: 'Supporter',
    emoji: '🤝',
    tagline: 'Empathetic · Reliable · Harmonious',
    description:
        'You build strong relationships and create environments where everyone '
        'feels valued. Your emotional intelligence is your greatest strength.',
    color: _kTeal,
    strengths: [
      'Deep empathy & active listening',
      'Team cohesion & trust building',
      'Conflict resolution',
      'Consistent reliability',
    ],
    growthAreas: [
      'Self-advocacy',
      'Setting boundaries',
      'Pursuing career ambition',
    ],
    careerPaths: [
      '👥  HR Manager',
      '💬  Counselor / Coach',
      '⭐  Customer Success Lead',
      '🌱  Community Manager',
    ],
    communicationStyle:
        'Warm and considerate — you listen deeply before speaking and '
        'prioritise harmony in every interaction.',
  );
}

// ─── Results screen ───────────────────────────────────────────────────────────
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _isDownloading = false;

  int get _percent {
    final score = ref.read(testProvider).result?.score;
    if (score == null) return 0;
    return (((score - 1) / 4) * 100).round().clamp(0, 100);
  }

  String get _topPercent {
    final p = _percent;
    if (p >= 90) return 'Top 5%';
    if (p >= 80) return 'Top 10%';
    if (p >= 70) return 'Top 25%';
    if (p >= 60) return 'Top 50%';
    return 'Top 75%';
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

  Future<void> _downloadReport() async {
    final resultId = ref.read(testProvider).result?.id;
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
    final test = ref.read(testProvider);
    final percent = _percent;
    final profile = _PersonalityProfile.fromScore(percent);
    final text =
        'I scored $percent% on the ${test.result?.testName ?? "MindScore"} test!\n'
        'My personality type: ${profile.type} (${profile.tagline})\n'
        'Powered by MindScore — mind-score.app';
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

    // No result yet — shouldn't normally happen but guard anyway
    if (test.result == null && !test.isLoading) {
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
                style:
                    FilledButton.styleFrom(backgroundColor: _kPurple),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final percent = _percent;
    final profile = _PersonalityProfile.fromScore(percent);
    final topPct = _topPercent;
    final duration = _duration;
    final testName = test.result?.testName ?? '';

    return ResponsiveWrapper(
      mobile: (ctx) => _MobileLayout(
        percent: percent,
        topPercent: topPct,
        duration: duration,
        testName: testName,
        profile: profile,
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
        percent: percent,
        topPercent: topPct,
        duration: duration,
        testName: testName,
        profile: profile,
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
  final int percent;
  final String topPercent;
  final String duration;
  final String testName;
  final _PersonalityProfile profile;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onBack;
  final WidgetRef ref;

  const _MobileLayout({
    required this.percent,
    required this.topPercent,
    required this.duration,
    required this.testName,
    required this.profile,
    required this.isDownloading,
    required this.onDownload,
    required this.onShare,
    required this.onBack,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
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
          _HeroCard(
            profile: profile,
            percent: percent,
            topPercent: topPercent,
            compact: false,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),

          const SizedBox(height: 16),

          _ScoreCardsRow(
            percent: percent,
            topPercent: topPercent,
            duration: duration,
            profile: profile,
          )
              .animate(delay: 80.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 16),

          _InsightCard(
            title: 'Your Strengths',
            dotColor: _kPurple,
            items: profile.strengths,
          )
              .animate(delay: 140.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 12),

          _InsightCard(
            title: 'Growth Areas',
            dotColor: _kPurpleLight,
            items: profile.growthAreas,
          )
              .animate(delay: 180.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 12),

          _InsightCard(
            title: 'Career Paths',
            dotColor: _kPink,
            items: profile.careerPaths,
          )
              .animate(delay: 220.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 24),

          _DownloadButton(
            isLoading: isDownloading,
            onTap: onDownload,
          )
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

// ─────────────────────────────────────────────────────────────────────────────
// Tablet / Desktop (wide) layout
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final int percent;
  final String topPercent;
  final String duration;
  final String testName;
  final _PersonalityProfile profile;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onBack;
  final WidgetRef ref;

  const _WideLayout({
    required this.percent,
    required this.topPercent,
    required this.duration,
    required this.testName,
    required this.profile,
    required this.isDownloading,
    required this.onDownload,
    required this.onShare,
    required this.onBack,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
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
                  _HeroCard(
                    profile: profile,
                    percent: percent,
                    topPercent: topPercent,
                    compact: true,
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  _ScoreCardsRow(
                    percent: percent,
                    topPercent: topPercent,
                    duration: duration,
                    profile: profile,
                  ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InsightCard(
                          title: 'Your Strengths',
                          dotColor: _kPurple,
                          items: profile.strengths,
                        ).animate(delay: 140.ms).fadeIn(duration: 350.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InsightCard(
                          title: 'Growth Areas',
                          dotColor: _kPurpleLight,
                          items: profile.growthAreas,
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
                    items: profile.careerPaths,
                  ).animate(delay: 200.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 16),

                  _CommunicationCard(profile: profile)
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 350.ms),

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
  final _PersonalityProfile profile;
  final int percent;
  final String topPercent;
  final bool compact;

  const _HeroCard({
    required this.profile,
    required this.percent,
    required this.topPercent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final emojiAndType = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(profile.emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Top X% badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _kPink.withValues(alpha: 0.4)),
                ),
                child: Text(
                  topPercent,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _kPink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

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
          emojiAndType,
          const SizedBox(height: 20),

          // Type badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: profile.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: profile.color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  profile.type,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: profile.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  profile.tagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            profile.description,
            style: theme.textTheme.bodyMedium?.copyWith(
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
// Score cards row (3 mini cards)
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreCardsRow extends StatelessWidget {
  final int percent;
  final String topPercent;
  final String duration;
  final _PersonalityProfile profile;

  const _ScoreCardsRow({
    required this.percent,
    required this.topPercent,
    required this.duration,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniScoreCard(
        label: 'Score',
        value: '$percent%',
        color: _kPurple,
      ),
      _MiniScoreCard(
        label: 'Ranking',
        value: topPercent,
        color: _kPink,
      ),
      _MiniScoreCard(
        label: 'Duration',
        value: duration,
        color: profile.color,
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

class _MiniScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniScoreCard({
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
  final _PersonalityProfile profile;

  const _CommunicationCard({required this.profile});

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
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: profile.color),
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
            profile.communicationStyle,
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
