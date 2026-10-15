import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/pipeline_deal.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';

class PipelineScreen extends StatelessWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final deals = appState.pipelineDeals;
    final health = appState.pipelineHealth;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Pipeline')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDealForm(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Pipeline Health Check',
            subtitle:
                'Weighted pipeline must stay ≥ 3× the remaining quarterly target',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(
                      'Total open pipeline',
                      Formatters.currency(health.totalOpenValue),
                    ),
                    _row(
                      'Total weighted pipeline',
                      Formatters.currency(health.totalWeightedValue),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining quarterly target'),
                        SizedBox(
                          width: 140,
                          child: _EditableAmount(
                            value: health.remainingQuarterlyTarget,
                            onChanged: (v) =>
                                appState.setRemainingQuarterlyTarget(v),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Coverage ratio',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          Formatters.multiplier(health.coverageRatio),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StatusChip(level: health.status, label: health.statusLabel),
                  ],
                ),
              ),
            ),
          ),
          SectionHeader(
            title: 'Deals',
            subtitle: '${deals.length} in pipeline',
          ),
          if (deals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No deals yet. Tap + to add one.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...deals.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                child: ListTile(
                  onTap: () => _showDealForm(context, existing: d),
                  title: Text(d.clientName),
                  subtitle: Text(
                    '${d.product} · ${d.stage} · ${Formatters.percent(d.winProbabilityPct)} win prob.\n'
                    'Value ${Formatters.currency(d.dealValue)} · Weighted ${Formatters.currency(d.weightedValue)}\n'
                    'Owner: ${d.dealOwner} · Close: ${d.expectedClose}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => appState.deleteDeal(d.id),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showDealForm(BuildContext context, {PipelineDeal? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DealForm(existing: existing),
    );
  }
}

class _EditableAmount extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _EditableAmount({required this.value, required this.onChanged});

  @override
  State<_EditableAmount> createState() => _EditableAmountState();
}

class _EditableAmountState extends State<_EditableAmount> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(isDense: true, prefixText: 'NRs. '),
      onSubmitted: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) widget.onChanged(parsed);
      },
      onEditingComplete: () {
        final parsed = double.tryParse(_ctrl.text);
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}

class _DealForm extends StatefulWidget {
  final PipelineDeal? existing;
  const _DealForm({this.existing});

  @override
  State<_DealForm> createState() => _DealFormState();
}

class _DealFormState extends State<_DealForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientCtrl;
  late final TextEditingController _productCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _probabilityCtrl;
  late final TextEditingController _closeCtrl;
  late final TextEditingController _ownerCtrl;
  late String _stage;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _clientCtrl = TextEditingController(text: e?.clientName ?? '');
    _productCtrl = TextEditingController(text: e?.product ?? '');
    _valueCtrl = TextEditingController(
      text: (e?.dealValue ?? 0).toStringAsFixed(0),
    );
    _probabilityCtrl = TextEditingController(
      text: ((e?.winProbabilityPct ?? 0.5) * 100).toStringAsFixed(0),
    );
    _closeCtrl = TextEditingController(text: e?.expectedClose ?? '');
    _ownerCtrl = TextEditingController(text: e?.dealOwner ?? '');
    _stage = e?.stage ?? pipelineStages.first;
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'New deal' : 'Edit deal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientCtrl,
                decoration: const InputDecoration(labelText: 'Client Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productCtrl,
                decoration: const InputDecoration(labelText: 'Product'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Deal Value (NRs.)',
                ),
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'Enter a number'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _stage,
                decoration: const InputDecoration(labelText: 'Current Stage'),
                items: pipelineStages
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _stage = v ?? _stage),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _probabilityCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Win Probability (%)',
                ),
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'Enter a number'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _closeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Expected Close',
                  hintText: 'e.g. Mangsir W3',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerCtrl,
                decoration: const InputDecoration(labelText: 'Deal Owner'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save deal'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final deal = PipelineDeal(
      id: widget.existing?.id ?? const Uuid().v4(),
      clientName: _clientCtrl.text.trim(),
      product: _productCtrl.text.trim(),
      dealValue: double.parse(_valueCtrl.text),
      stage: _stage,
      winProbabilityPct: double.parse(_probabilityCtrl.text) / 100,
      expectedClose: _closeCtrl.text.trim(),
      dealOwner: _ownerCtrl.text.trim(),
    );
    appState.upsertDeal(deal);
    Navigator.of(context).pop();
  }
}
