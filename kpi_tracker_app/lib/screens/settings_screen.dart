import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Backup')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'All data in this app is stored only on this device (local-only mode). '
              'Use export/import below to back up or move your data to another phone.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export data'),
            subtitle: const Text(
              'Save all team members, weekly reports, pipeline, KPIs and activities to a JSON file',
            ),
            onTap: () => _exportData(context, appState),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Import data'),
            subtitle: const Text(
              'Replace all current data with a previously exported JSON file',
            ),
            onTap: () => _importData(context, appState),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.switch_account_outlined),
            title: const Text('Switch profile'),
            subtitle: const Text('Go back to profile selection'),
            onTap: () => appState.clearActiveMember(),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState) async {
    try {
      final data = appState.exportAll();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/infocare_kpi_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);
      if (!context.mounted) return;
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'InfoCare KPI Tracker backup');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importData(BuildContext context, AppState appState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Replace all data?'),
          content: const Text(
            'Importing will overwrite everything currently on this device with the contents of this backup file.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      await appState.importAll(data);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }
}
