import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team_member.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import 'member_form_sheet.dart';

class ManageTeamScreen extends StatelessWidget {
  const ManageTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final members = appState.members;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Team')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const MemberFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: members.isEmpty
          ? const Center(child: Text('No team members yet. Tap + to add one.'))
          : ListView(
              children: members.map((m) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                    ),
                    title: Text(m.name),
                    subtitle: Text(
                      '${m.segment}\nLeads ${m.targets.leads} · Meetings ${m.targets.meetings} · '
                      'Demos ${m.targets.demos} · Proposals ${m.targets.proposals} · '
                      'Bookings ${Formatters.currency(m.targets.bookings)}/wk',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => MemberFormSheet(existing: m),
                          );
                        } else if (v == 'delete') {
                          _confirmDelete(context, appState, m);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit targets'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Remove')),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, TeamMember m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove team member?'),
        content: Text(
          'This deletes ${m.name} and all of their weekly entries. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              appState.removeTeamMember(m.id);
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
