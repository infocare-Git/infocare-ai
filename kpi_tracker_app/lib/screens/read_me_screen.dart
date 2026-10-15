import 'package:flutter/material.dart';

class ReadMeScreen extends StatelessWidget {
  const ReadMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'My Week — Directors and Sales Team members log leads, meetings, demos, proposals, '
          'bookings, and follow-ups every Friday. Status is computed automatically and lists '
          'exactly which targets were missed.',
      'Pipeline — add a row per deal and update it whenever it moves stage. Weighted value '
          'and pipeline coverage vs. the remaining quarterly target are calculated automatically.',
      'Insights → Monthly KPIs — at month end, enter each KPI\'s actual; status (on track / '
          'watch / red flag) computes automatically from the built-in thresholds.',
      'Insights → Activities — update Progress % on each major activity monthly.',
      'Insights → Annual Targets — reference figures for the FY revenue mix and quarterly '
          'booking targets; adjust unit price/units and totals recalculate.',
      'More → Team Overview — compare everyone\'s cumulative totals and latest status at a glance.',
      'More → Manage Team — add, edit, or remove Directors and Sales Team members and their '
          'individually assigned weekly targets.',
      'More → Settings & Backup — this app stores data locally on your device only. Use '
          'Export/Import regularly to back up your data or move it to a new phone.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('How to use this app')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'InfoCare Weekly KPI Tracker — FY 2083/84',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Annual Sales Goal: NRs. 6,00,00,000',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('•  $s'),
            ),
          const Divider(height: 32),
          const Text(
            'Data storage',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'This is a local-only app: everything you enter stays on this device. It is not '
            'automatically shared with other phones. To share progress with your team or '
            'management, use Settings & Backup → Export and send the file, or ask them to '
            'import it.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
