import 'package:flutter/material.dart';

/// A minimal inline trend line — deliberately hand-rolled with
/// [CustomPainter] instead of a charting package, so KPI/report screens
/// stay dependency-free and the on-disk data model stays the source of
/// truth for what's plotted.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const Sparkline({
    super.key,
    required this.values,
    this.color = Colors.blue,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            values.isEmpty
                ? 'No history yet'
                : 'Log one more entry to see a trend',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparklinePainter(values: values, color: color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : maxV - minV;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    Offset pointAt(int i) {
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * size.height);
      return Offset(dx * i, y.clamp(0, size.height));
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(pointAt(values.length - 1).dx, size.height)
      ..lineTo(pointAt(0).dx, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    canvas.drawCircle(pointAt(values.length - 1), 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
