import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/status_logic.dart';
import '../widgets/section_header.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activities = appState.activities;
    final avg = appState.averageActivityProgress;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Major Activities & Execution Plan',
          subtitle: 'Update Progress % monthly',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Average execution progress',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${avg.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...activities.map(
          (a) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.majorActivity,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text(a.segment),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.keySubActivities,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Target: ${a.annualKpiTarget}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driver: ${a.responsible} · Approver: ${a.approver}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: a.progressPct.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '${a.progressPct}%',
                            onChanged: (v) =>
                                appState.setActivityProgress(a.id, v.round()),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${a.progressPct}%',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        activityStatusLabel(a.progressPct),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: a.progressPct >= 100
                              ? Colors.green
                              : a.progressPct > 0
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
