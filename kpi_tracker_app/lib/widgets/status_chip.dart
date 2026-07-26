import 'package:flutter/material.dart';

import '../utils/status_logic.dart';

class StatusChip extends StatelessWidget {
  final StatusLevel level;
  final String label;

  const StatusChip({super.key, required this.level, required this.label});

  Color _color(BuildContext context) {
    switch (level) {
      case StatusLevel.green:
        return Colors.green;
      case StatusLevel.yellow:
        return Colors.orange;
      case StatusLevel.red:
        return Colors.red;
      case StatusLevel.notEntered:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Free-text status pill for the weekly "missed targets" style status.
class TextStatusChip extends StatelessWidget {
  final String text;
  final bool onTrack;

  const TextStatusChip({super.key, required this.text, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    final color = onTrack ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
