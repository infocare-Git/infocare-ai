import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SwitchMemberSheet extends StatelessWidget {
  const SwitchMemberSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeId = appState.activeMemberId;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: activeId,
              onChanged: (id) {
                if (id == null) return;
                appState.setActiveMember(id);
                Navigator.of(context).pop();
              },
              child: Column(
                children: appState.members
                    .map(
                      (m) => RadioListTile<String>(
                        value: m.id,
                        title: Text(m.name),
                        subtitle: Text(m.segment),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
