import 'package:flutter/material.dart';

import 'manage_team_screen.dart';
import 'read_me_screen.dart';
import 'settings_screen.dart';
import 'team_overview_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Team Overview'),
            subtitle: const Text(
              'Compare everyone\'s latest status & cumulative totals',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TeamOverviewScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Manage Team'),
            subtitle: const Text(
              'Add, edit, or remove Directors and Sales Team members',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ManageTeamScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings & Backup'),
            subtitle: const Text(
              'Export / import your data (stored on this device only)',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How to use this app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ReadMeScreen())),
          ),
        ],
      ),
    );
  }
}
