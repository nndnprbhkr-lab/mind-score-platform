import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/mind_score_models.dart';

const _kDeep   = Color(0xFF150A28);
const _kInner  = Color(0xFF1E0F3C);
const _kBorder = Color(0xFF3d2070);
const _kAccent = Color(0xFF6B35C8);
const _kLight  = Color(0xFFA67CF0);
const _kPink   = Color(0xFFFF6B9D);
const _kTeal   = Color(0xFF5DCAA5);
const _kGold   = Color(0xFFF5B740);

class MindScoreModuleList extends StatelessWidget {
  final MindScoreResult result;

  const MindScoreModuleList({super.key, required this.result});

  static const _moduleColors = <String, Color>{
    'Cognitive':  _kLight,
    'Emotional':  _kPink,
    'Focus':      _kTeal,
    'Decision':   _kGold,
    'Resilience': Color(0xFF7ED7F0),
  };

  static const _moduleIcons = <String, String>{
    'Cognitive':  '🧩',
    'Emotional':  '❤️',
    'Focus':      '🎯',
    'Decision':   '⚖️',
    'Resilience': '🛡️',
  };

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'MODULE BREAKDOWN',
            style: TextStyle(
              fontSize: 10,
              color: _kLight,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...result.modules.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return _ModuleRow(
              module: m,
              color: _moduleColors[m.moduleName] ?? _kAccent,
              emoji: _moduleIcons[m.moduleName] ?? '📊',
              delay: Duration(milliseconds: 100 + i * 80),
            );
          }),
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  final MindScoreModuleResult module;
  final Color color;
  final String emoji;
  final Duration delay;

  const _ModuleRow({
    required this.module,
    required this.color,
    required this.emoji,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (module.percentile / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.moduleName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kInner,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kBorder, width: 0.5),
                ),
                child: Text(
                  module.label,
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${module.percentile.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 5,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    height: 5,
                    width: constraints.maxWidth * pct,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.04, end: 0);
  }
}
