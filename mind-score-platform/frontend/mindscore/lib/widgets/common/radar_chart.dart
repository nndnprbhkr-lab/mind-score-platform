import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Data model ─────────────────────────────────────────────────────────────────

class RadarAxis {
  final String name;
  final String sublabel;
  final double value;
  final Color color;

  const RadarAxis({
    required this.name,
    required this.sublabel,
    required this.value,
    required this.color,
  });
}

// ── Widget ─────────────────────────────────────────────────────────────────────

class RadarChart extends StatefulWidget {
  final List<RadarAxis> axes;
  final double size;

  const RadarChart({super.key, required this.axes, this.size = 280});

  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hoveredAxis = -1;

  int get _n => widget.axes.length;
  double get _maxR => (widget.size - 96) / 2;
  Offset get _center => Offset(widget.size / 2, widget.size / 2);

  double _angle(int i) => -pi / 2 + (2 * pi * i / _n);

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
    return List.generate(_n, (i) {
      final pct = widget.axes[i].value.clamp(0, 100) / 100;
      final r = pct * _maxR * _anim.value;
      return Offset(
        _center.dx + r * cos(_angle(i)),
        _center.dy + r * sin(_angle(i)),
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
      cursor: _hoveredAxis >= 0 ? SystemMouseCursors.click : MouseCursor.defer,
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
                    axes: widget.axes,
                    progress: _anim.value,
                    size: widget.size,
                    hoveredAxis: _hoveredAxis,
                    vertices: vertices,
                    angleOf: _angle,
                  ),
                ),
                ..._buildLabels(vertices),
                if (_hoveredAxis >= 0 && _anim.value > 0.5)
                  _buildTooltip(_hoveredAxis, vertices[_hoveredAxis]),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildLabels(List<Offset> vertices) {
    const labelW = 100.0;
    const totalH = 36.0;

    return List.generate(_n, (i) {
      final axis = widget.axes[i];
      final anchorDist = _maxR + 32;
      final angle = _angle(i);
      final ax = _center.dx + anchorDist * cos(angle);
      final ay = _center.dy + anchorDist * sin(angle);

      double left, top;
      TextAlign textAlign;
      CrossAxisAlignment crossAlign;

      const epsilon = 0.15;
      final cosA = cos(angle);
      if (cosA > epsilon) {
        left = ax + 4;
        top = ay - totalH / 2;
        textAlign = TextAlign.left;
        crossAlign = CrossAxisAlignment.start;
      } else if (cosA < -epsilon) {
        left = ax - labelW - 4;
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
              axis.name,
              style: GoogleFonts.poppins(
                color: axis.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 1),
            Text(
              axis.sublabel,
              style: GoogleFonts.poppins(
                color: const Color(0xFFBBAADF),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTooltip(int axisIndex, Offset vertex) {
    final axis = widget.axes[axisIndex];
    const tooltipW = 160.0;
    const padding = 12.0;

    double left = vertex.dx + padding;
    double top = vertex.dy - padding - 60;
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
            border: Border.all(
                color: axis.color.withValues(alpha: 0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: axis.color.withValues(alpha: 0.22),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                axis.name,
                style: GoogleFonts.poppins(
                  color: axis.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                axis.sublabel,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final List<RadarAxis> axes;
  final double progress;
  final double size;
  final int hoveredAxis;
  final List<Offset> vertices;
  final double Function(int) angleOf;

  const _RadarPainter({
    required this.axes,
    required this.progress,
    required this.size,
    required this.hoveredAxis,
    required this.vertices,
    required this.angleOf,
  });

  int get _n => axes.length;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final maxR = (size - 96) / 2;
    final center = Offset(size / 2, size / 2);

    // ── Grid rings at 25 / 50 / 75 % ─────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF5A3890).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final fraction in [0.25, 0.50, 0.75]) {
      final r = maxR * fraction;
      final ringPath = Path();
      for (var i = 0; i < _n; i++) {
        final pt = Offset(
          center.dx + r * cos(angleOf(i)),
          center.dy + r * sin(angleOf(i)),
        );
        if (i == 0) {
          ringPath.moveTo(pt.dx, pt.dy);
        } else {
          ringPath.lineTo(pt.dx, pt.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);

      // Scale label near top-right vertex
      final labelPt = Offset(
        center.dx + r * cos(angleOf(0)) + 4,
        center.dy + r * sin(angleOf(0)) - 12,
      );
      _paintScaleLabel(canvas, '${(fraction * 100).round()}%', labelPt);
    }

    // ── Axis lines ────────────────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = const Color(0xFF5A3890).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < _n; i++) {
      canvas.drawLine(
        center,
        Offset(
          center.dx + maxR * cos(angleOf(i)),
          center.dy + maxR * sin(angleOf(i)),
        ),
        axisPaint,
      );
    }

    // ── Data polygon ──────────────────────────────────────────────────────────
    if (vertices.isEmpty) return;
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
      final color = axes[i].color;
      final isHovered = i == hoveredAxis;

      if (isHovered) {
        canvas.drawCircle(
          v,
          13,
          Paint()
            ..color = color.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
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
          ..strokeWidth = 1.5,
      );
    }
  }

  void _paintScaleLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF9A80C8),
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress ||
      old.axes != axes ||
      old.hoveredAxis != hoveredAxis;
}
