import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/app_state.dart';
import '../utils/csv_export.dart';
import '../utils/report_text.dart';
import '../widgets/section_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final members = appState.members;
    final defs = appState.monthlyKpiDefinitions;

    final latestEntryByMember = {
      for (final m in members)
        m.id: appState.entriesFor(m.id).isEmpty
            ? null
            : appState.entriesFor(m.id).first,
    };
    final latestWeekLabelByMember = {
      for (final m in members) m.id: latestEntryByMember[m.id]?.weekLabel,
    };
    final statusByMember = {
      for (final m in members)
        m.id: latestEntryByMember[m.id] == null
            ? null
            : appState.statusFor(latestEntryByMember[m.id]!),
    };
    final latestActualByKpi = {
      for (final d in defs) d.id: appState.latestActualFor(d.id)?.actual,
    };

    final weeklyRecap = ReportText.weeklyRecap(
      members: members,
      latestWeekLabelByMember: latestWeekLabelByMember,
      statusByMember: statusByMember,
    );
    final monthlyRecap = ReportText.monthlyRecap(
      defs: defs,
      latestActualByKpi: latestActualByKpi,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Weekly Recap',
            subtitle: "Every member's latest logged week, at a glance",
          ),
          _RecapCard(
            text: weeklyRecap,
            onShare: () => _shareText(context, 'Weekly recap', weeklyRecap),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _shareCsv(
                context,
                'weekly_entries',
                CsvExport.weeklyEntries(appState.weeklyEntries, members),
              ),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Export weekly entries (CSV)'),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Monthly KPI Recap',
            subtitle: 'Latest actual and status for every KPI',
          ),
          _RecapCard(
            text: monthlyRecap,
            onShare: () =>
                _shareText(context, 'Monthly KPI recap', monthlyRecap),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _shareCsv(
                context,
                'monthly_kpi_actuals',
                CsvExport.monthlyKpiActuals(
                  defs,
                  defs
                      .expand((d) => appState.actualsHistoryFor(d.id))
                      .toList(),
                ),
              ),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Export monthly KPI actuals (CSV)'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _shareText(
    BuildContext context,
    String subject,
    String text,
  ) async {
    await Share.share(text, subject: subject);
  }

  Future<void> _shareCsv(
    BuildContext context,
    String baseName,
    String csv,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);
      if (!context.mounted) return;
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'InfoCare KPI Tracker export');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

class _RecapCard extends StatelessWidget {
  final String text;
  final VoidCallback onShare;

  const _RecapCard({required this.text, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                text,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
