import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team_member.dart';
import '../state/app_state.dart';
import 'member_form_sheet.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final members = appState.members;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'InfoCare KPI Tracker',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'FY 2083/84 — Annual Sales Goal NRs. 6,00,00,000',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            const Text(
              'Who are you?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pick your profile to see your weekly targets, or add yourself as a new Sales Team member.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...members.map(
              (m) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                  ),
                  title: Text(m.name),
                  subtitle: Text('${_roleLabel(m.role)} · ${m.segment}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.setActiveMember(m.id),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const MemberFormSheet(setActiveOnCreate: true),
              ),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Add myself as a new Sales Team member'),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(TeamRole role) {
    switch (role) {
      case TeamRole.director:
        return 'Director';
      case TeamRole.salesRep:
        return 'Sales Team';
      case TeamRole.admin:
        return 'Admin';
    }
  }
}
