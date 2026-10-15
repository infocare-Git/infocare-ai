import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/carbon_catalog.dart';
import '../models/carbon_entry.dart';
import '../state/app_state.dart';
import '../widgets/section_header.dart';
import '../widgets/sparkline.dart';
import 'carbon_share_sheet.dart';
import 'switch_member_sheet.dart';

class CarbonScreen extends StatelessWidget {
  const CarbonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final member = appState.activeMember;

    if (member == null) {
      return const Scaffold(
        body: Center(child: Text('Select a profile from Home first.')),
      );
    }

    final totalToday = appState.carbonSavedToday(member.id);
    final breakdownToday = appState.carbonBreakdownToday(member.id);
    final history = appState.carbonDailyHistory(member.id, days: 14);
    final thisWeek = history.skip(history.length - 7).fold(0.0, (s, v) => s + v);
    final allTime = appState.carbonSavedAllTime(member.id);
    final logs = appState.carbonLogsFor(member.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const SwitchMemberSheet(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityPicker(context, member.id),
        icon: const Icon(Icons.add),
        label: const Text('Log activity'),
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Today',
            subtitle: 'How much CO2e you saved today, and by what',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totalToday.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 6, bottom: 6),
                          child: Text(
                            'kg CO2e saved today',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 20,
                      runSpacing: 4,
                      children: [
                        _stat('This week', '${thisWeek.toStringAsFixed(1)} kg'),
                        _stat('All time', '${allTime.toStringAsFixed(1)} kg'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: totalToday <= 0
                            ? null
                            : () => _showShareSheet(
                                context,
                                member.name,
                                totalToday,
                                breakdownToday,
                              ),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share today\'s impact'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(
            title: '14-day trend',
            subtitle: 'Daily CO2e saved, oldest → newest',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Sparkline(values: history, color: Colors.green, height: 48),
              ),
            ),
          ),
          SectionHeader(
            title: "Today's breakdown",
            subtitle: breakdownToday.isEmpty
                ? 'Log an activity below to see it here'
                : 'Which activities saved the most today',
          ),
          if (breakdownToday.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: breakdownToday.entries
                        .map((e) => _BreakdownRow(
                              activityTypeId: e.key,
                              kg: e.value,
                              maxKg: breakdownToday.values.first,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          const SectionHeader(
            title: 'Log an activity',
            subtitle: 'Tap one to add it',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CarbonCatalog.activityTypes
                  .map(
                    (type) => ActionChip(
                      avatar: Text(type.icon, style: const TextStyle(fontSize: 16)),
                      label: Text(type.label),
                      onPressed: () =>
                          _showQuantitySheet(context, member.id, type),
                    ),
                  )
                  .toList(),
            ),
          ),
          SectionHeader(
            title: 'Recent activity',
            subtitle: '${logs.length} logged in total',
          ),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Nothing logged yet — tap "Log activity" to start.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...logs.take(20).map((e) => _LogTile(entry: e)),
          const SizedBox(height: 80),
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

  void _showActivityPicker(BuildContext context, String memberId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: CarbonCatalog.activityTypes
              .map(
                (type) => ListTile(
                  leading: Text(type.icon, style: const TextStyle(fontSize: 22)),
                  title: Text(type.label),
                  subtitle: Text(
                    '${type.co2PerUnit} kg CO2e per ${carbonUnitLabel(type.unit)} · '
                    '${type.sourceNote}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showQuantitySheet(context, memberId, type);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showQuantitySheet(
    BuildContext context,
    String memberId,
    CarbonActivityType type,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LogQuantitySheet(memberId: memberId, type: type),
    );
  }

  void _showShareSheet(
    BuildContext context,
    String memberName,
    double totalKg,
    Map<String, double> breakdown,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CarbonShareSheet(
        memberName: memberName,
        totalKg: totalKg,
        breakdown: breakdown,
        date: DateTime.now(),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String activityTypeId;
  final double kg;
  final double maxKg;

  const _BreakdownRow({
    required this.activityTypeId,
    required this.kg,
    required this.maxKg,
  });

  @override
  Widget build(BuildContext context) {
    final type = CarbonCatalog.byId(activityTypeId);
    final fraction = maxKg <= 0 ? 0.0 : (kg / maxKg).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type?.icon ?? '🌱', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type?.label ?? activityTypeId,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${kg.toStringAsFixed(2)} kg',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              color: Colors.green,
              backgroundColor: Colors.green.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final CarbonLogEntry entry;
  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final type = CarbonCatalog.byId(entry.activityTypeId);
    final kg = type?.co2For(entry.quantity) ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Text(type?.icon ?? '🌱', style: const TextStyle(fontSize: 22)),
          title: Text(type?.label ?? entry.activityTypeId),
          subtitle: Text(
            '${entry.quantity.toStringAsFixed(entry.quantity % 1 == 0 ? 0 : 1)} '
            '${type != null ? carbonUnitLabel(type.unit) : ""} · '
            '${entry.loggedAt.hour.toString().padLeft(2, '0')}:'
            '${entry.loggedAt.minute.toString().padLeft(2, '0')}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${kg.toStringAsFixed(2)} kg',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    context.read<AppState>().deleteCarbonLog(entry.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogQuantitySheet extends StatefulWidget {
  final String memberId;
  final CarbonActivityType type;

  const _LogQuantitySheet({required this.memberId, required this.type});

  @override
  State<_LogQuantitySheet> createState() => _LogQuantitySheetState();
}

class _LogQuantitySheetState extends State<_LogQuantitySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '1');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.type.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.type.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.type.co2PerUnit} kg CO2e per ${carbonUnitLabel(widget.type.unit)} '
              '(${widget.type.sourceNote})',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qtyCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'How many ${carbonUnitLabel(widget.type.unit)}?',
              ),
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Add to today'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().addCarbonLog(
      memberId: widget.memberId,
      activityTypeId: widget.type.id,
      quantity: double.parse(_qtyCtrl.text),
    );
    Navigator.of(context).pop();
  }
}
