import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/mpi_models.dart';

class MpiRadarChart extends StatefulWidget {
  final MpiResult result;
  final double size;

  const MpiRadarChart({super.key, required this.result, this.size = 280});

  @override
  State<MpiRadarChart> createState() => _MpiRadarChartState();
}

class _MpiRadarChartState extends State<MpiRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarPainter(
                  result: widget.result,
                  progress: _anim.value,
                  size: widget.size,
                ),
              ),
              ..._buildLabels(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildLabels() {
    final size = widget.size;
    final maxR = (size - 96) / 2;
    final cx = size / 2;
    final cy = size / 2;
    const labelW = 90.0;
    const totalH = 42.0;

    final axes = [
      (
        key: 'EnergySource',
        label: 'Energy',
        angle: -pi / 2,
        color: const Color(0xFFFF6B9D),
      ),
      (
        key: 'PerceptionMode',
        label: 'Perception',
        angle: 0.0,
        color: const Color(0xFF5DCAA5),
      ),
      (
        key: 'DecisionStyle',
        label: 'Decision',
        angle: pi / 2,
        color: const Color(0xFFF5B740),
      ),
      (
        key: 'LifeApproach',
        label: 'Approach',
        angle: pi,
        color: const Color(0xFF6B35C8),
      ),
    ];

    return axes.map((axis) {
      final dim = widget.result.dimensions[axis.key];
      if (dim == null) return const SizedBox.shrink();

      final anchorDist = maxR + 30;
      final ax = cx + anchorDist * cos(axis.angle);
      final ay = cy + anchorDist * sin(axis.angle);

      double left, top;
      TextAlign textAlign;
      CrossAxisAlignment crossAlign;

      const epsilon = 0.01;
      if (axis.angle.abs() < epsilon) {
        // East → left-align
        left = ax + 2;
        top = ay - totalH / 2;
        textAlign = TextAlign.left;
        crossAlign = CrossAxisAlignment.start;
      } else if ((axis.angle.abs() - pi).abs() < epsilon) {
        // West → right-align
        left = ax - labelW - 2;
        top = ay - totalH / 2;
        textAlign = TextAlign.right;
        crossAlign = CrossAxisAlignment.end;
      } else {
        // North / South → center
        left = ax - labelW / 2;
        top = ay - totalH / 2;
        textAlign = TextAlign.center;
        crossAlign = CrossAxisAlignment.center;
      }

      return Positioned(
        left: left,
        top: top,
        width: labelW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              axis.label,
              style: GoogleFonts.poppins(
                color: axis.color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: textAlign,
            ),
            Text(
              '${dim.dominantPole} · ${dim.percentage.round()}%',
              style: GoogleFonts.poppins(
                color: const Color(0xFF9A85C8),
                fontSize: 9,
              ),
              textAlign: textAlign,
            ),
            Text(
              dim.strength,
              style: GoogleFonts.poppins(
                color: const Color(0xFF5A4080),
                fontSize: 8,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _RadarPainter extends CustomPainter {
  final MpiResult result;
  final double progress;
  final double size;

  const _RadarPainter({
    required this.result,
    required this.progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final maxR = (size - 96) / 2;
    final center = Offset(size / 2, size / 2);

    // 3 concentric square-grid rings at 25%, 50%, 75%
    final gridPaint = Paint()
      ..color = const Color(0xFF3D2070).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final fraction in [0.25, 0.50, 0.75]) {
      final r = maxR * fraction;
      canvas.drawRect(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        gridPaint,
      );
    }

    // Axis lines from center to edge
    final axisPaint = Paint()
      ..color = const Color(0xFF3D2070).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const angles = [-pi / 2, 0.0, pi / 2, pi];
    for (final angle in angles) {
      canvas.drawLine(
        center,
        Offset(center.dx + maxR * cos(angle), center.dy + maxR * sin(angle)),
        axisPaint,
      );
    }

    // Build polygon vertices
    const axisKeys = [
      'EnergySource',
      'PerceptionMode',
      'DecisionStyle',
      'LifeApproach',
    ];
    final vertices = <Offset>[];
    for (var i = 0; i < axisKeys.length; i++) {
      final dim = result.dimensions[axisKeys[i]];
      final pct = dim?.percentage ?? 50.0;
      final r = (pct / 100) * maxR * progress;
      vertices.add(Offset(
        center.dx + r * cos(angles[i]),
        center.dy + r * sin(angles[i]),
      ));
    }

    final path = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (var i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color =
            const Color(0xFF6B35C8).withValues(alpha: 0.18 * progress)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6B35C8).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots at each vertex
    const axisColors = [
      Color(0xFFFF6B9D),
      Color(0xFF5DCAA5),
      Color(0xFFF5B740),
      Color(0xFF6B35C8),
    ];
    for (var i = 0; i < vertices.length; i++) {
      // Filled dot with axis colour
      canvas.drawCircle(
        vertices[i],
        5,
        Paint()
          ..color = axisColors[i]
          ..style = PaintingStyle.fill,
      );
      // White border ring
      canvas.drawCircle(
        vertices[i],
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress || old.result != result;
}
