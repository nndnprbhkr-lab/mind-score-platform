import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/models/mind_score_models.dart';
import '../../../widgets/mind_score/mind_score_hero_card.dart';
import '../../../widgets/mind_score/mind_score_module_list.dart';
import '../../../widgets/mind_score/mind_score_action_steps.dart';

const _kDeep   = Color(0xFF150A28);
const _kBorder = Color(0xFF3d2070);
const _kLight  = Color(0xFFA67CF0);
const _kMuted  = Color(0xFF9a85c8);

class MindScoreResultsScreen extends StatelessWidget {
  final ResultModel resultModel;

  const MindScoreResultsScreen({super.key, required this.resultModel});

  @override
  Widget build(BuildContext context) {
    final mindResult = MindScoreResult.fromResultModel(
      score: resultModel.score,
      dimensionScores: resultModel.dimensionScores,
      insights: resultModel.insights,
      typeName: resultModel.typeName ?? '',
    );

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
            constraints: const BoxConstraints(maxWidth: 800),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: MindScoreModuleList(result: result)),
              const SizedBox(width: 16),
              Expanded(child: MindScoreActionSteps(result: result)),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
