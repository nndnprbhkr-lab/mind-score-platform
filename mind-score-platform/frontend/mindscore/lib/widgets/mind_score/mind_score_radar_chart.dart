import 'package:flutter/material.dart';
import '../../core/models/mind_score_models.dart';
import '../common/radar_chart.dart';

const _kModuleColors = <String, Color>{
  'Cognitive':  Color(0xFFA67CF0),
  'Emotional':  Color(0xFFFF6B9D),
  'Focus':      Color(0xFF5DCAA5),
  'Decision':   Color(0xFFF5B740),
  'Resilience': Color(0xFF7ED7F0),
};

const _kFallbackColor = Color(0xFF6B35C8);

// ── Thin wrapper over generic RadarChart ───────────────────────────────────────

class MindScoreRadarChart extends StatelessWidget {
  final MindScoreResult result;
  final double size;

  const MindScoreRadarChart({super.key, required this.result, this.size = 300});

  @override
  Widget build(BuildContext context) {
    final axes = result.modules.map((m) {
      return RadarAxis(
        name: m.moduleName,
        sublabel: '${m.percentile.round()}%  ·  ${m.label}',
        value: m.percentile.clamp(0, 100),
        color: _kModuleColors[m.moduleName] ?? _kFallbackColor,
      );
    }).toList();

    return RadarChart(axes: axes, size: size);
  }
}
