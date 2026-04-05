import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/mpi_models.dart';

// ── Axis config ────────────────────────────────────────────────────────────────

const _kAxisKeys = [
  'EnergySource',
  'PerceptionMode',
  'DecisionStyle',
  'LifeApproach',
];

const _kAxisLabels = ['Energy', 'Perception', 'Decision', 'Approach'];

const _kAxisAngles = [-pi / 2, 0.0, pi / 2, pi];

const _kAxisColors = [
  Color(0xFFFF6B9D),
  Color(0xFF5DCAA5),
  Color(0xFFF5B740),
  Color(0xFF6B35C8),
];

// ── Widget ─────────────────────────────────────────────────────────────────────

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
  int _hoveredAxis = -1;

  double get _maxR => (widget.size - 96) / 2;
  Offset get _center => Offset(widget.size / 2, widget.size / 2);

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

  List<Offset> _computeVertices() {
    return List.generate(_kAxisKeys.length, (i) {
      final dim = widget.result.dimensions[_kAxisKeys[i]];
      final pct = dim?.percentage ?? 50.0;
      final r = (pct / 100) * _maxR * _anim.value;
      return Offset(
        _center.dx + r * cos(_kAxisAngles[i]),
        _center.dy + r * sin(_kAxisAngles[i]),
      );
    });
  }

  void _onHover(Offset localPos) {
    if (_anim.value < 0.5) return;
    final vertices = _computeVertices();
    const hitRadius = 18.0;
    int found = -1;
    for (var i = 0; i < vertices.length; i++) {
      if ((localPos - vertices[i]).distance <= hitRadius) {
        found = i;
        break;
      }
    }
    if (found != _hoveredAxis) setState(() => _hoveredAxis = found);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _onHover(e.localPosition),
      onExit: (_) => setState(() => _hoveredAxis = -1),
      cursor: _hoveredAxis >= 0
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final vertices = _computeVertices();
            return Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RadarPainter(
                    result: widget.result,
                    progress: _anim.value,
                    size: widget.size,
                    hoveredAxis: _hoveredAxis,
                    vertices: vertices,
                  ),
                ),
                ..._buildLabels(),
                if (_hoveredAxis >= 0 && _anim.value > 0.5)
                  _buildTooltip(_hoveredAxis, vertices[_hoveredAxis]),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildLabels() {
    const labelW = 90.0;
    const totalH = 42.0;

    return List.generate(_kAxisKeys.length, (i) {
      final dim = widget.result.dimensions[_kAxisKeys[i]];
      if (dim == null) return const SizedBox.shrink();

      final anchorDist = _maxR + 30;
      final ax = _center.dx + anchorDist * cos(_kAxisAngles[i]);
      final ay = _center.dy + anchorDist * sin(_kAxisAngles[i]);

      double left, top;
      TextAlign textAlign;
      CrossAxisAlignment crossAlign;

      const epsilon = 0.01;
      final angle = _kAxisAngles[i];
      if (angle.abs() < epsilon) {
        left = ax + 2;
        top = ay - totalH / 2;
        textAlign = TextAlign.left;
        crossAlign = CrossAxisAlignment.start;
      } else if ((angle.abs() - pi).abs() < epsilon) {
        left = ax - labelW - 2;
        top = ay - totalH / 2;
        textAlign = TextAlign.right;
        crossAlign = CrossAxisAlignment.end;
      } else {
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
              _kAxisLabels[i],
              style: GoogleFonts.poppins(
                color: _kAxisColors[i],
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
    });
  }

  Widget _buildTooltip(int axisIndex, Offset vertex) {
    final key = _kAxisKeys[axisIndex];
    final dim = widget.result.dimensions[key];
    final meta = MpiDimensionMeta.forKey(key);
    if (dim == null || meta == null) return const SizedBox.shrink();

    final poleDesc = kPoleDescriptions[dim.dominantPole] ?? '';
    final poleWord = dim.dominantPole == meta.leftPole
        ? meta.leftWord
        : meta.rightWord;
    final color = _kAxisColors[axisIndex];

    const tooltipW = 180.0;
    const padding = 12.0;

    double left = vertex.dx + padding;
    double top = vertex.dy - padding - 90;
    if (left + tooltipW > widget.size) left = vertex.dx - tooltipW - padding;
    if (top < 0) top = vertex.dy + padding;
    if (left < 0) left = 0;

    return Positioned(
      left: left,
      top: top,
      width: tooltipW,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF150A28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(meta.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    meta.name,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$poleWord — ${dim.percentage.round()}%',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dim.strength,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9A85C8),
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (poleDesc.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  poleDesc,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A5090),
                    fontSize: 8.5,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final MpiResult result;
  final double progress;
  final double size;
  final int hoveredAxis;
  final List<Offset> vertices;

  const _RadarPainter({
    required this.result,
    required this.progress,
    required this.size,
    required this.hoveredAxis,
    required this.vertices,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final maxR = (size - 96) / 2;
    final center = Offset(size / 2, size / 2);

    // ── Grid rings at 25 / 50 / 75 % ─────────────────────────────────────────
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
      // Scale label to the right of the ring's top edge
      _paintScaleLabel(
        canvas,
        '${(fraction * 100).round()}%',
        Offset(center.dx + r + 3, center.dy - r - 1),
      );
    }

    // ── Axis lines ────────────────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF3D2070).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final angle in _kAxisAngles) {
      canvas.drawLine(
        center,
        Offset(center.dx + maxR * cos(angle), center.dy + maxR * sin(angle)),
        axisPaint,
      );
    }

    // ── Data polygon ──────────────────────────────────────────────────────────
    final path = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (var i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6B35C8).withValues(alpha: 0.18 * progress)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6B35C8).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Vertex dots ───────────────────────────────────────────────────────────
    for (var i = 0; i < vertices.length; i++) {
      final v = vertices[i];
      final color = _kAxisColors[i];
      final isHovered = i == hoveredAxis;

      if (isHovered) {
        // Glow ring
        canvas.drawCircle(
          v,
          13,
          Paint()
            ..color = color.withValues(alpha: 0.18)
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          v,
          9,
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      canvas.drawCircle(v, isHovered ? 6.5 : 5,
          Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(
          v,
          isHovered ? 6.5 : 5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  void _paintScaleLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF5A4080),
          fontSize: 7.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress ||
      old.result != result ||
      old.hoveredAxis != hoveredAxis;
}
