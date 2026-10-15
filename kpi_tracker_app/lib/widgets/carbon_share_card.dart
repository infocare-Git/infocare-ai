import 'package:flutter/material.dart';

import '../data/carbon_catalog.dart';
import '../utils/formatters.dart';

/// A story-ratio (9:16) card summarizing one day's carbon savings, built
/// to be captured as a PNG and shared — the on-screen size doesn't
/// matter, [RenderRepaintBoundary.toImage] captures it at a higher
/// pixel ratio regardless (see `lib/utils/share_image.dart`).
class CarbonShareCard extends StatelessWidget {
  final String memberName;
  final double totalKg;
  final Map<String, double> breakdown;
  final DateTime date;

  const CarbonShareCard({
    super.key,
    required this.memberName,
    required this.totalKg,
    required this.breakdown,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final topActivities = breakdown.entries.take(3);
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F5132), Color(0xFF14532D), Color(0xFF052E16)],
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'My carbon savings today',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.date(date),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const Spacer(),
            Text(
              totalKg.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const Text(
              'kg CO2e saved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (topActivities.isNotEmpty) ...[
              const Text(
                'Top actions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...topActivities.map((entry) {
                final type = CarbonCatalog.byId(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text(
                        type?.icon ?? '🌱',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type?.label ?? entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            Text(
              '$memberName · InfoCare KPI Tracker',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
