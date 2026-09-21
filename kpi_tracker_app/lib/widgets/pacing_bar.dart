import 'package:flutter/material.dart';

/// A compact horizontal bar showing an actual value against its target,
/// with a tick mark at the target threshold — a faster read than the raw
/// numbers alone when scanning many KPIs at once.
class PacingBar extends StatelessWidget {
  final double actual;
  final double target;
  final double redThreshold;
  final Color color;

  const PacingBar({
    super.key,
    required this.actual,
    required this.target,
    required this.redThreshold,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scaleMax =
        [actual, target, redThreshold].reduce((a, b) => a > b ? a : b) * 1.15;
    final fraction = scaleMax <= 0 ? 0.0 : (actual / scaleMax).clamp(0.0, 1.0);
    final targetFraction = scaleMax <= 0
        ? 0.0
        : (target / scaleMax).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 10,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Positioned(
                left: (constraints.maxWidth * targetFraction - 1).clamp(
                  0,
                  constraints.maxWidth - 2,
                ),
                child: Container(
                  width: 2,
                  height: 10,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
