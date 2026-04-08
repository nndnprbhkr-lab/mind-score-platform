import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/results/providers/mpi_result_provider.dart';
import '../../../features/results/providers/results_provider.dart';
import '../../../widgets/mpi/mpi_result_card.dart';
import '../../dashboard/providers/tests_provider.dart';

Future<void> _handleTestStart(
  BuildContext context,
  WidgetRef ref,
  AuthState auth,
  TestModel test,
) async {
  final isMindScore = test.name.toLowerCase().contains('mindscore');
  if (isMindScore && !auth.hasDob) {
    DateTime? selectedDob;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final dobLabel = selectedDob != null
              ? '${selectedDob!.day.toString().padLeft(2, '0')}/${selectedDob!.month.toString().padLeft(2, '0')}/${selectedDob!.year}'
              : 'Select date of birth';

          Future<void> pickDob() async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: ctx,
              initialDate: selectedDob ?? DateTime(now.year - 25),
              firstDate: DateTime(now.year - 100),
              lastDate: DateTime(now.year - 5),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF6B35C8),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E0F3C),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setDialogState(() => selectedDob = picked);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1E0F3C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Date of Birth Required',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindScore uses age-specific norms to calculate your result. Please enter your date of birth to continue.',
                  style: TextStyle(color: Color(0xFF9a85c8), fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: pickDob,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1850),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedDob != null
                            ? const Color(0xFF6B35C8)
                            : const Color(0xFF3D2070),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: selectedDob != null
                              ? const Color(0xFF9a85c8)
                              : const Color(0xFF6B5A9E),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dobLabel,
                          style: TextStyle(
                            color: selectedDob != null ? Colors.white : const Color(0xFF6B5A9E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF9a85c8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B35C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: selectedDob == null ? null : () => Navigator.pop(ctx, true),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || selectedDob == null) return;

    await ref.read(authProvider.notifier).updateDob(selectedDob!);

    if (!context.mounted) return;
    final updatedAuth = ref.read(authProvider);
    if (updatedAuth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedAuth.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
  }

  if (!context.mounted) return;
  context.go(AppRoutes.testWithId(test.id), extra: test.name);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final testsState = ref.watch(testsProvider);
    final resultsState = ref.watch(resultsProvider);

    return ResponsiveWrapper(
      mobile: (ctx) => _MobileLayout(
        auth: auth,
        testsState: testsState,
        resultsState: resultsState,
        ref: ref,
      ),
      tablet: (ctx) => _TabletDesktopLayout(
        auth: auth,
        testsState: testsState,
        resultsState: resultsState,
        ref: ref,
        isDesktop: false,
      ),
      desktop: (ctx) => _TabletDesktopLayout(
        auth: auth,
        testsState: testsState,
        resultsState: resultsState,
        ref: ref,
        isDesktop: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Mobile layout
// ─────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final AuthState auth;
  final TestsState testsState;
  final ResultsState resultsState;
  final WidgetRef ref;

  const _MobileLayout({
    required this.auth,
    required this.testsState,
    required this.resultsState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _TopBarMobile(auth: auth, ref: ref),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _GreetingSection(name: auth.name),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _StatsRow(
                  resultsState: resultsState,
                  columns: 3,
                ),
              ),
            ),
            // ── MPI result card (pinned above tests) ──────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: MpiResultCardSlot(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: _SectionTitle('Featured Test'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: testsState.isLoading
                    ? _ShimmerCard(height: 180)
                    : testsState.tests.isEmpty
                        ? const _EmptyTests()
                        : _FeaturedTestCard(
                            test: testsState.tests.first,
                            onStart: () => _handleTestStart(
                              context, ref, auth, testsState.tests.first,
                            ),
                          ),
              ),
            ),
            if (testsState.tests.length > 1) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: _SectionTitle('More Tests'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                sliver: testsState.isLoading
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ShimmerCard(height: 120),
                          ),
                          childCount: 3,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final t = testsState.tests[i + 1];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RegularTestCard(
                                test: t,
                                onStart: () => _handleTestStart(
                                  context, ref, auth, t,
                                ),
                              ),
                            );
                          },
                          childCount: testsState.tests.length - 1,
                        ),
                      ),
              ),
            ] else
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Tablet / Desktop layout
// ─────────────────────────────────────────────────────
class _TabletDesktopLayout extends StatelessWidget {
  final AuthState auth;
  final TestsState testsState;
  final ResultsState resultsState;
  final WidgetRef ref;
  final bool isDesktop;

  const _TabletDesktopLayout({
    required this.auth,
    required this.testsState,
    required this.resultsState,
    required this.ref,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = isDesktop ? 40.0 : 24.0;
    final statsColumns = isDesktop ? 4 : 2;
    final testColumns = isDesktop ? 3 : 2;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with optional search
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
              child: _TopBarDesktop(
                auth: auth,
                ref: ref,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GreetingSection(name: auth.name),
                      const SizedBox(height: 28),
                      _StatsRow(
                          resultsState: resultsState,
                          columns: statsColumns),
                      const SizedBox(height: 24),
                      const MpiResultCardSlot(),
                      const SizedBox(height: 36),
                      _SectionTitle('Available Tests'),
                      const SizedBox(height: 16),
                      testsState.isLoading
                          ? _shimmerGrid(testColumns)
                          : testsState.error != null
                              ? _ErrorWidget(message: testsState.error!)
                              : testsState.tests.isEmpty
                                  ? const _EmptyTests()
                                  : _TestsGrid(
                                      tests: testsState.tests,
                                      columns: testColumns,
                                      onStart: (t) => _handleTestStart(
                                        context, ref, auth, t,
                                      ),
                                    ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerGrid(int columns) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        columns * 2,
        (_) => FractionallySizedBox(
          widthFactor: 1 / columns,
          child: _ShimmerCard(height: 160),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Top bars
// ─────────────────────────────────────────────────────
class _TopBarMobile extends StatelessWidget {
  final AuthState auth;
  final WidgetRef ref;

  const _TopBarMobile({required this.auth, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.psychology_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'MindScore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const Spacer(),
        _AvatarMenu(auth: auth, ref: ref),
      ],
    );
  }
}

class _TopBarDesktop extends StatelessWidget {
  final AuthState auth;
  final WidgetRef ref;

  const _TopBarDesktop({
    required this.auth,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 16),
        _AvatarMenu(auth: auth, ref: ref),
      ],
    );
  }
}


class _AvatarMenu extends StatelessWidget {
  final AuthState auth;
  final WidgetRef ref;

  const _AvatarMenu({required this.auth, required this.ref});

  @override
  Widget build(BuildContext context) {
    final _nameStr = auth.name?.trim();
    final _emailStr = auth.email?.trim();
    final initial = (_nameStr != null && _nameStr.isNotEmpty)
        ? _nameStr[0].toUpperCase()
        : (_emailStr != null && _emailStr.isNotEmpty)
            ? _emailStr[0].toUpperCase()
            : 'U';
    return PopupMenuButton<String>(
      tooltip: '',
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.accent.withValues(alpha: 0.18),
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      itemBuilder: (_) => [
        if (auth.isAdmin)
          const PopupMenuItem(
            value: 'admin',
            child: Row(children: [
              Icon(Icons.admin_panel_settings_outlined, size: 18),
              SizedBox(width: 8),
              Text('Admin Panel'),
            ]),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18),
            SizedBox(width: 8),
            Text('Sign Out'),
          ]),
        ),
      ],
      onSelected: (v) {
        if (v == 'logout') ref.read(authProvider.notifier).logout();
        if (v == 'admin') context.go(AppRoutes.adminPanel);
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String? name;

  const _GreetingSection({required this.name});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _displayName {
    if (name == null || name!.trim().isEmpty) return 'there';
    return name!.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting, $_displayName 👋',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ready to discover your mind today?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────
// Stats
// ─────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  final ResultsState resultsState;
  final int columns;

  const _StatsRow({required this.resultsState, required this.columns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = resultsState.results;
    final mpiAsync = ref.watch(mpiResultProvider);
    final mpi = mpiAsync.valueOrNull;

    final personalityValue = mpi != null && mpi.typeCode.isNotEmpty
        ? '${mpi.emoji} ${mpi.typeCode}'
        : '—';

    final stats = [
      _StatData(
        emoji: '🧪',
        value: '${results.length}',
        label: 'Tests Taken',
      ),
      _StatData(
        emoji: '🧠',
        value: personalityValue,
        label: 'Personality',
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final cols = columns.clamp(1, stats.length);
      const spacing = 12.0;
      final itemWidth =
          (constraints.maxWidth - spacing * (cols - 1)) / cols;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: stats.asMap().entries.map((e) {
          return SizedBox(
            width: itemWidth,
            child: _StatCard(data: e.value)
                .animate(delay: (e.key * 60).ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0),
          );
        }).toList(),
      );
    });
  }
}

class _StatData {
  final String emoji;
  final String value;
  final String label;
  const _StatData(
      {required this.emoji, required this.value, required this.label});
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text(
            data.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Featured test card
// ─────────────────────────────────────────────────────
class _FeaturedTestCard extends StatelessWidget {
  final TestModel test;
  final VoidCallback onStart;

  const _FeaturedTestCard({required this.test, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1D80), Color(0xFF6B35C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'FEATURED',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            test.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${test.questionCount} questions · 3–5 min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.highlight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'Start Now',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────
// Regular test card
// ─────────────────────────────────────────────────────
class _RegularTestCard extends StatelessWidget {
  final TestModel test;
  final VoidCallback onStart;

  const _RegularTestCard({required this.test, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1D80), Color(0xFF6B35C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Psychology',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  test.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${test.questionCount} questions · 3–5 min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              textStyle: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Tests grid (tablet / desktop)
// ─────────────────────────────────────────────────────
class _TestsGrid extends StatelessWidget {
  final List<TestModel> tests;
  final int columns;
  final void Function(TestModel) onStart;

  const _TestsGrid({
    required this.tests,
    required this.columns,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 14.0;
      final itemW =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: tests.asMap().entries.map((e) {
          final t = e.value;
          return SizedBox(
            width: itemW,
            child: _GridTestCard(
              test: t,
              isFeatured: e.key == 0,
              onStart: () => onStart(t),
            )
                .animate(delay: (e.key * 50).ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.06, end: 0),
          );
        }).toList(),
      );
    });
  }
}

class _GridTestCard extends StatelessWidget {
  final TestModel test;
  final bool isFeatured;
  final VoidCallback onStart;

  const _GridTestCard({
    required this.test,
    required this.isFeatured,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1D80), Color(0xFF6B35C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFeatured ? 'FEATURED' : 'Psychology',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: isFeatured ? 0.8 : 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            test.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${test.questionCount} questions · 3–5 min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.highlight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'Start Now',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Shimmer loading card
// ─────────────────────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  final double height;
  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppColors.cardBorder.withValues(alpha: 0.6),
        );
  }
}

// ─────────────────────────────────────────────────────
// Empty / error states
// ─────────────────────────────────────────────────────
class _EmptyTests extends StatelessWidget {
  const _EmptyTests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.quiz_outlined,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No tests available yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.error),
      ),
    );
  }
}
