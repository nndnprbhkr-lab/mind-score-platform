import 'package:flutter/material.dart';
import '../../core/models/mpi_models.dart';
import '../common/radar_chart.dart';

const _kAxisKeys = [
  'EnergySource',
  'PerceptionMode',
  'DecisionStyle',
  'LifeApproach',
];

const _kAxisLabels = ['Energy', 'Perception', 'Decision', 'Approach'];

const _kAxisColors = [
  Color(0xFFFF6B9D),
  Color(0xFF5DCAA5),
  Color(0xFFF5B740),
  Color(0xFF6B35C8),
];

// ── Widget — thin wrapper over generic RadarChart ──────────────────────────────

class MpiRadarChart extends StatelessWidget {
  final MpiResult result;
  final double size;

  const MpiRadarChart({super.key, required this.result, this.size = 280});

  @override
  Widget build(BuildContext context) {
    final axes = List.generate(_kAxisKeys.length, (i) {
      final key = _kAxisKeys[i];
      final dim = result.dimensions[key];
      final meta = MpiDimensionMeta.forKey(key);
      final poleWord = (meta == null || dim == null)
          ? (dim?.dominantPole ?? '')
          : (dim.dominantPole == meta.leftPole ? meta.leftWord : meta.rightWord);
      final pct = dim?.percentage ?? 50.0;
      return RadarAxis(
        name: _kAxisLabels[i],
        sublabel: '$poleWord · ${pct.round()}%',
        value: pct,
        color: _kAxisColors[i],
      );
    });
    return RadarChart(axes: axes, size: size);
  }
}
