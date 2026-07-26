import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/monthly_kpi.dart';
import '../state/app_state.dart';
import '../utils/status_logic.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';

class MonthlyDashboardScreen extends StatelessWidget {
  const MonthlyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final defs = appState.monthlyKpiDefinitions;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Monthly KPI Dashboard',
          subtitle:
              'Enter this month\'s actual — status computes automatically',
        ),
        ...defs.map((def) => _KpiCard(def: def)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final MonthlyKpiDefinition def;
  const _KpiCard({required this.def});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actual = appState.latestActualFor(def.id);
    final status = computeMonthlyKpiStatus(def, actual?.actual);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      def.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusChip(level: status, label: _statusLabel(status)),
                ],
              ),
              const SizedBox(height: 4),
              Text(def.formula, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _meta('Target', def.targetGoalLabel),
                  _meta('Red flag', def.redFlagLabel),
                  _meta('Owner', def.owner),
                  if (actual != null)
                    _meta(
                      'Latest actual (${actual.monthLabel})',
                      def.formatValue(actual.actual),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _ActualEntryRow(def: def),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(StatusLevel s) {
    switch (s) {
      case StatusLevel.green:
        return 'ON TRACK';
      case StatusLevel.yellow:
        return 'WATCH';
      case StatusLevel.red:
        return 'RED FLAG';
      case StatusLevel.notEntered:
        return 'Not entered';
    }
  }

  Widget _meta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}

class _ActualEntryRow extends StatefulWidget {
  final MonthlyKpiDefinition def;
  const _ActualEntryRow({required this.def});

  @override
  State<_ActualEntryRow> createState() => _ActualEntryRowState();
}

class _ActualEntryRowState extends State<_ActualEntryRow> {
  late final TextEditingController _monthCtrl;
  late final TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _monthCtrl = TextEditingController();
    _valueCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final unitHint = switch (widget.def.unit) {
      KpiUnit.percent => 'e.g. 92 for 92%',
      KpiUnit.multiplier => 'e.g. 2.5 for 2.5x',
      KpiUnit.days => 'days',
      KpiUnit.count => 'count',
    };
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _monthCtrl,
            decoration: const InputDecoration(
              labelText: 'Month',
              isDense: true,
              hintText: 'e.g. Shrawan',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Actual',
              isDense: true,
              hintText: unitHint,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  void _submit() {
    final month = _monthCtrl.text.trim();
    final rawValue = double.tryParse(_valueCtrl.text);
    if (month.isEmpty || rawValue == null) return;
    final actual = widget.def.unit == KpiUnit.percent
        ? rawValue / 100
        : rawValue;
    context.read<AppState>().setMonthlyActual(
      kpiId: widget.def.id,
      monthLabel: month,
      actual: actual,
    );
    _valueCtrl.clear();
  }
}
