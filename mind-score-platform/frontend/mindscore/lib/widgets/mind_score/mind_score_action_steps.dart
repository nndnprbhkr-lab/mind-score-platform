import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/mind_score_models.dart';

const _kDeep   = Color(0xFF150A28);
const _kBorder = Color(0xFF3d2070);
const _kAccent = Color(0xFF6B35C8);
const _kLight  = Color(0xFFA67CF0);
const _kPink   = Color(0xFFFF6B9D);
const _kTeal   = Color(0xFF5DCAA5);
const _kGold   = Color(0xFFF5B740);
const _kMuted  = Color(0xFF9a85c8);

class MindScoreActionSteps extends StatelessWidget {
  final MindScoreResult result;

  const MindScoreActionSteps({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(result);

    return Container(
      decoration: BoxDecoration(
        color: _kDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: _kLight, size: 16),
              SizedBox(width: 6),
              Text(
                'ACTION PLAN',
                style: TextStyle(
                  fontSize: 10,
                  color: _kLight,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return _StepRow(
              step: step,
              delay: Duration(milliseconds: 120 + i * 90),
            );
          }),
        ],
      ),
    );
  }

  List<_ActionStep> _buildSteps(MindScoreResult result) {
    // Sort modules by lowest percentile (most improvement potential)
    final sorted = [...result.modules]
      ..sort((a, b) => a.percentile.compareTo(b.percentile));

    return sorted.take(4).map((m) => _stepForModule(m)).toList();
  }

  _ActionStep _stepForModule(MindScoreModuleResult m) {
    final (icon, title, body, color) = switch (m.moduleName) {
      'Cognitive' => (
          '🧩',
          'Sharpen Cognitive Agility',
          'Practice pattern-recognition puzzles and working-memory exercises for 10 min daily.',
          _kLight,
        ),
      'Emotional' => (
          '❤️',
          'Deepen Emotional Awareness',
          'Keep a brief daily emotion journal and reflect on triggers before reacting.',
          _kPink,
        ),
      'Focus' => (
          '🎯',
          'Build Deep Focus',
          'Use Pomodoro blocks (25 min on, 5 min off) and remove notifications during work.',
          _kTeal,
        ),
      'Decision' => (
          '⚖️',
          'Strengthen Decision-Making',
          'Write out pros/cons before key choices; review past decisions weekly for patterns.',
          _kGold,
        ),
      'Resilience' => (
          '🛡️',
          'Grow Resilience',
          'Reframe setbacks as learning moments. Practice one mindfulness minute per hour.',
          const Color(0xFF7ED7F0),
        ),
      _ => (
          '📊',
          'Improve ${m.moduleName}',
          'Focus consistent daily practice on this dimension to raise your score.',
          _kAccent,
        ),
    };

    return _ActionStep(
      icon: icon,
      title: title,
      body: body,
      label: m.moduleName,
      accentColor: color,
    );
  }
}

class _ActionStep {
  final String icon;
  final String title;
  final String body;
  final String label;
  final Color accentColor;

  const _ActionStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.label,
    required this.accentColor,
  });
}

class _StepRow extends StatelessWidget {
  final _ActionStep step;
  final Duration delay;

  const _StepRow({required this.step, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 52,
            decoration: BoxDecoration(
              color: step.accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(step.icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.04, end: 0);
  }
}
