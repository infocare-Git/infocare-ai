import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';
import 'switch_member_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final member = appState.activeMember;
    final totalBookings = appState.totalBookingsAllMembers;
    final annualGoal = appState.totalAnnualRevenueTarget > 0
        ? appState.totalAnnualRevenueTarget
        : SeedData.annualGoal;
    final annualProgress = (totalBookings / annualGoal).clamp(0.0, 1.0);
    final health = appState.pipelineHealth;
    final latestEntry = member == null
        ? null
        : appState.entriesFor(member.id).firstOrNull;
    final latestStatus = latestEntry == null
        ? null
        : appState.statusFor(latestEntry);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoCare KPI Tracker'),
        actions: [
          TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const SwitchMemberSheet(),
            ),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(member?.name ?? 'Select'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'FY 2083/84 — Annual Sales Goal',
            subtitle: 'Cumulative bookings across the whole team',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.currency(totalBookings),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'of ${Formatters.currency(annualGoal)} goal',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: annualProgress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.percent(annualProgress),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Live Pipeline Health'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coverage ratio',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            Formatters.multiplier(health.coverageRatio),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Weighted ${Formatters.currency(health.totalWeightedValue)} vs remaining ${Formatters.currency(health.remainingQuarterlyTarget)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      level: health.status,
                      label: health.statusLabel.split(' —').first,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (member != null) ...[
            SectionHeader(
              title: 'Your latest week — ${member.name}',
              subtitle: latestEntry?.weekLabel ?? 'No entries yet',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: latestEntry == null
                      ? const Text(
                          "You haven't logged a week yet — use the My Week tab below to log activity.",
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextStatusChip(
                              text: latestStatus!.label,
                              onTrack: latestStatus.onTrack,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                _stat(
                                  'Leads',
                                  '${latestEntry.leads}/${member.targets.leads}',
                                ),
                                _stat(
                                  'Meetings',
                                  '${latestEntry.meetings}/${member.targets.meetings}',
                                ),
                                _stat(
                                  'Demos',
                                  '${latestEntry.demos}/${member.targets.demos}',
                                ),
                                _stat(
                                  'Proposals',
                                  '${latestEntry.proposals}/${member.targets.proposals}',
                                ),
                                _stat(
                                  'Bookings',
                                  Formatters.currency(latestEntry.bookingsWon),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
