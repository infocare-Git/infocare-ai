import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/section_header.dart';

class AnnualTargetsScreen extends StatelessWidget {
  const AnnualTargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final streams = appState.revenueStreams;
    final total = appState.totalAnnualRevenueTarget;
    final quarters = appState.quarterTargets;
    double cumulative = 0;

    return ListView(
      children: [
        const SectionHeader(
          title: 'Annual Revenue Mix — FY 2083/84',
          subtitle:
              'Reference — adjust unit price/units and totals recalculate',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product / Stream')),
                  DataColumn(label: Text('Unit Price')),
                  DataColumn(label: Text('Units')),
                  DataColumn(label: Text('Revenue')),
                  DataColumn(label: Text('Lead')),
                ],
                rows: streams
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(width: 180, child: Text(r.product)),
                          ),
                          DataCell(
                            _EditableCell(
                              value: r.unitPrice,
                              onChanged: (v) => appState.updateRevenueStream(
                                r.id,
                                unitPrice: v,
                              ),
                            ),
                          ),
                          DataCell(
                            _EditableCell(
                              value: r.units.toDouble(),
                              onChanged: (v) => appState.updateRevenueStream(
                                r.id,
                                units: v.round(),
                              ),
                            ),
                          ),
                          DataCell(Text(Formatters.currency(r.revenue))),
                          DataCell(Text(r.leadDirector)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                Formatters.currency(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Quarterly Booking Targets'),
        ...quarters.map((q) {
          cumulative += q.bookingTarget;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              child: ListTile(
                title: Text(q.quarter),
                subtitle: Text(q.focus),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(q.bookingTarget),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Cum. ${Formatters.currency(cumulative)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Annual check (must equal ${Formatters.currency(total)}): ${Formatters.currency(cumulative)} '
            '${cumulative == total ? '✓' : '⚠ mismatch'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EditableCell extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _EditableCell({required this.value, required this.onChanged});

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
        ),
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) widget.onChanged(parsed);
        },
      ),
    );
  }
}
