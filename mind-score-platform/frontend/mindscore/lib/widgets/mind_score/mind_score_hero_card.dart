import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/mind_score_models.dart';

const _kDeep    = Color(0xFF150A28);
const _kBanner  = Color(0xFF1E0F3C);
const _kBorder  = Color(0xFF3d2070);
const _kLight   = Color(0xFFA67CF0);
const _kPink    = Color(0xFFFF6B9D);
const _kTeal    = Color(0xFF5DCAA5);
const _kMuted   = Color(0xFF9a85c8);

class MindScoreHeroCard extends StatelessWidget {
  final MindScoreResult result;

  const MindScoreHeroCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBanner,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Tier emoji + label
          Text(
            _tierEmoji(result.tier),
            style: const TextStyle(fontSize: 52),
          ).animate().scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 8),

          const Text(
            'MINDSCORE ASSESSMENT',
            style: TextStyle(
              fontSize: 10,
              color: _kMuted,
              letterSpacing: 1.4,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 6),

          Text(
            result.tier,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 4),

          Text(
            _tierTagline(result.tier),
            style: const TextStyle(
              fontSize: 13,
              color: _kMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Score row
          Row(
            children: [
              _ScorePill(
                value: '${result.overallScore}',
                label: 'MindScore',
                color: _kLight,
              ),
              const SizedBox(width: 10),
              _ScorePill(
                value: _topPercent(result.overallScore),
                label: 'Ranking',
                color: _kPink,
              ),
              const SizedBox(width: 10),
              _ScorePill(
                value: result.ageBandName.split(' ').first,
                label: 'Age Group',
                color: _kTeal,
              ),
            ],
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }

  String _tierEmoji(String tier) => switch (tier) {
        'Elite'      => '🧠',
        'Advanced'   => '⚡',
        'Proficient' => '🌟',
        'Developing' => '🌱',
        _            => '🔍',
      };

  String _tierTagline(String tier) => switch (tier) {
        'Elite'      => 'Exceptional cognitive and emotional mastery.',
        'Advanced'   => 'Strong mental performance across key dimensions.',
        'Proficient' => 'Solid foundations with clear areas to develop.',
        'Developing' => 'Building mental fitness — growth in progress.',
        _            => 'Early stage — every expert started here.',
      };

  String _topPercent(int score) {
    if (score >= 90) return 'Top 5%';
    if (score >= 80) return 'Top 10%';
    if (score >= 70) return 'Top 25%';
    if (score >= 60) return 'Top 50%';
    return 'Top 75%';
  }
}

class _ScorePill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ScorePill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _kDeep,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: _kMuted),
            ),
          ],
        ),
      ),
    );
  }
}
