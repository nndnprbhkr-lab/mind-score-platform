import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/models/mind_score_models.dart';
import '../../../features/test/providers/test_provider.dart';
import '../../../features/results/providers/results_provider.dart';
import '../../../widgets/mind_score/mind_score_hero_card.dart';
import '../../../widgets/mind_score/mind_score_module_list.dart';
import '../../../widgets/mind_score/mind_score_action_steps.dart';
import '../../../widgets/mind_score/mind_score_radar_chart.dart';

const _kDeep   = Color(0xFF150A28);
const _kBorder = Color(0xFF3d2070);
const _kLight  = Color(0xFFA67CF0);
const _kMuted  = Color(0xFF9a85c8);

class MindScoreResultsScreen extends ConsumerWidget {
  final ResultModel? resultModel;

  const MindScoreResultsScreen({super.key, this.resultModel});

  MindScoreResult? _resolve(WidgetRef ref) {
    ResultModel? model = resultModel;
    if (model == null) {
      final testResult = ref.watch(testProvider).result;
      if (testResult?.typeCode == 'MIND_SCORE') model = testResult;
    }
    if (model == null) {
      model = ref
          .watch(resultsProvider)
          .results
          .where((r) => r.typeCode == 'MIND_SCORE')
          .firstOrNull;
    }
    if (model == null) return null;
    return MindScoreResult.fromResultModel(
      score: model.score,
      dimensionScores:
          model.dimensionScores is List ? model.dimensionScores as List<dynamic> : null,
      insights: model.insights,
      typeName: model.typeName ?? '',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mindResult = _resolve(ref);

    if (mindResult == null) {
      return Scaffold(
        backgroundColor: _kDeep,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_outlined, size: 56, color: _kMuted),
              const SizedBox(height: 16),
              const Text(
                'No MindScore result found.',
                style: TextStyle(color: _kMuted, fontSize: 15),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                style: FilledButton.styleFrom(backgroundColor: _kLight),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      backgroundColor: _kDeep,
      appBar: AppBar(
        backgroundColor: _kDeep,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kLight, size: 18),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: const Text(
          'Your MindScore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: _kBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 32 : 16,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: isWide
                ? _WideLayout(result: mindResult)
                : _NarrowLayout(result: mindResult),
          ),
        ),
      ),
    );
  }
}

// ─── Narrow (mobile) ─────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final MindScoreResult result;

  const _NarrowLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MindScoreHeroCard(result: result),
        const SizedBox(height: 20),
        Center(
          child: MindScoreRadarChart(result: result, size: 300)
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
        ),
        const SizedBox(height: 20),
        MindScoreModuleList(result: result),
        const SizedBox(height: 16),
        MindScoreActionSteps(result: result),
        const SizedBox(height: 16),
        _RetakeButton(),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Wide (desktop) ──────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final MindScoreResult result;

  const _WideLayout({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MindScoreHeroCard(result: result),
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: radar chart + action steps
              Expanded(
                child: Column(
                  children: [
                    MindScoreRadarChart(result: result, size: 320)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 16),
                    MindScoreActionSteps(result: result),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right column: module breakdown
              Expanded(
                child: MindScoreModuleList(result: result),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _RetakeButton(),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Footer button ────────────────────────────────────────────────────────────

class _RetakeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => context.go(AppRoutes.dashboard),
        icon: const Icon(Icons.home_outlined, size: 16, color: _kMuted),
        label: const Text(
          'Back to Dashboard',
          style: TextStyle(color: _kMuted, fontSize: 13),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _kBorder),
          ),
        ),
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}
