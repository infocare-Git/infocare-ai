import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';

class TeamOverviewScreen extends StatelessWidget {
  const TeamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final members = appState.members;

    return Scaffold(
      appBar: AppBar(title: const Text('Team Overview')),
      body: members.isEmpty
          ? const Center(child: Text('No team members yet.'))
          : ListView(
              children: members.map((m) {
                final totals = appState.cumulativeTotalsFor(m.id);
                final entries = appState.entriesFor(m.id);
                final latest = entries.isEmpty ? null : entries.first;
                final status = latest == null
                    ? null
                    : appState.statusFor(latest);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (status != null)
                              TextStatusChip(
                                text: status.onTrack
                                    ? 'ON TRACK'
                                    : 'MISSED TARGETS',
                                onTrack: status.onTrack,
                              )
                            else
                              const TextStatusChip(
                                text: 'No entries',
                                onTrack: false,
                              ),
                          ],
                        ),
                        Text(
                          m.segment,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _stat('Weeks reported', '${totals.weeksReported}'),
                            _stat('Leads', '${totals.leads}'),
                            _stat('Meetings', '${totals.meetings}'),
                            _stat('Demos', '${totals.demos}'),
                            _stat('Proposals', '${totals.proposals}'),
                            _stat(
                              'Bookings won',
                              Formatters.currency(totals.bookingsWon),
                            ),
                            _stat(
                              'Avg bookings/wk',
                              Formatters.currency(totals.avgBookingsPerWeek),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
