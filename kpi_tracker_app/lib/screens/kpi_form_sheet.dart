import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/monthly_kpi.dart';
import '../state/app_state.dart';

/// Add/edit form for a custom Monthly KPI. The "≥ 100%" / "< 85%" style
/// labels shown on the dashboard card are generated from the threshold +
/// direction here, so setting up a new KPI only needs a number and a
/// higher/lower-is-better choice — not hand-typed display text.
class KpiFormSheet extends StatefulWidget {
  final MonthlyKpiDefinition? existing;

  const KpiFormSheet({super.key, this.existing});

  @override
  State<KpiFormSheet> createState() => _KpiFormSheetState();
}

class _KpiFormSheetState extends State<KpiFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _formulaCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _redCtrl;
  late KpiUnit _unit;
  late KpiDirection _direction;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _formulaCtrl = TextEditingController(text: e?.formula ?? '');
    _ownerCtrl = TextEditingController(text: e?.owner ?? 'Each');
    _unit = e?.unit ?? KpiUnit.percent;
    _direction = e?.direction ?? KpiDirection.higherIsBetter;
    _targetCtrl = TextEditingController(
      text: e == null ? '' : _displayValue(e.unit, e.targetThreshold),
    );
    _redCtrl = TextEditingController(
      text: e == null ? '' : _displayValue(e.unit, e.redThreshold),
    );
  }

  String _displayValue(KpiUnit unit, double value) =>
      unit == KpiUnit.percent
      ? (value * 100).toStringAsFixed(0)
      : value.toString();

  @override
  Widget build(BuildContext context) {
    final unitHint = switch (_unit) {
      KpiUnit.percent => 'e.g. 90 for 90%',
      KpiUnit.multiplier => 'e.g. 3 for 3x',
      KpiUnit.days => 'e.g. 120',
      KpiUnit.count => 'e.g. 50',
    };
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'New KPI' : 'Edit KPI',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Status (on track / watch / red flag) computes '
                'automatically from the target and red-flag numbers below.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'KPI name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formulaCtrl,
                decoration: const InputDecoration(
                  labelText: 'What it measures',
                  hintText: "e.g. 'Proposals won / proposals sent'",
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerCtrl,
                decoration: const InputDecoration(labelText: 'Owner'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<KpiUnit>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: const [
                        DropdownMenuItem(
                          value: KpiUnit.percent,
                          child: Text('Percent'),
                        ),
                        DropdownMenuItem(
                          value: KpiUnit.multiplier,
                          child: Text('Multiplier (x)'),
                        ),
                        DropdownMenuItem(
                          value: KpiUnit.days,
                          child: Text('Days'),
                        ),
                        DropdownMenuItem(
                          value: KpiUnit.count,
                          child: Text('Count'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _unit = v ?? _unit),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<KpiDirection>(
                      initialValue: _direction,
                      decoration: const InputDecoration(labelText: 'Goal'),
                      items: const [
                        DropdownMenuItem(
                          value: KpiDirection.higherIsBetter,
                          child: Text('Higher is better'),
                        ),
                        DropdownMenuItem(
                          value: KpiDirection.lowerIsBetter,
                          child: Text('Lower is better'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _direction = v ?? _direction),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(_targetCtrl, 'Target', unitHint),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _numberField(_redCtrl, 'Red flag below', unitHint),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      widget.existing == null ? 'Create KPI' : 'Save changes',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController ctrl, String label, String hint) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) =>
          (v == null || double.tryParse(v) == null) ? 'Enter a number' : null,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final targetRaw = double.parse(_targetCtrl.text);
    final redRaw = double.parse(_redCtrl.text);
    final target = _unit == KpiUnit.percent ? targetRaw / 100 : targetRaw;
    final red = _unit == KpiUnit.percent ? redRaw / 100 : redRaw;

    final def = MonthlyKpiDefinition(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      formula: _formulaCtrl.text.trim(),
      targetGoalLabel: MonthlyKpiDefinition.thresholdLabel(
        direction: _direction,
        unit: _unit,
        value: target,
        isRedFlag: false,
      ),
      redFlagLabel: MonthlyKpiDefinition.thresholdLabel(
        direction: _direction,
        unit: _unit,
        value: red,
        isRedFlag: true,
      ),
      owner: _ownerCtrl.text.trim().isEmpty ? 'Each' : _ownerCtrl.text.trim(),
      targetThreshold: target,
      redThreshold: red,
      direction: _direction,
      unit: _unit,
    );

    final appState = context.read<AppState>();
    if (widget.existing != null) {
      appState.updateMonthlyKpiDefinition(def);
    } else {
      appState.addMonthlyKpiDefinition(def);
    }
    Navigator.of(context).pop();
  }
}
