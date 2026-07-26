import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team_member.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';
import 'switch_member_sheet.dart';

class WeeklyEntryScreen extends StatelessWidget {
  const WeeklyEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final member = appState.activeMember;

    if (member == null) {
      return const Scaffold(
        body: Center(child: Text('Select a profile from Home first.')),
      );
    }

    final entries = appState.entriesFor(member.id);
    final totals = appState.cumulativeTotalsFor(member.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Week — ${member.name}'),
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
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Weekly targets',
            subtitle: 'What you\'re measured against every week',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _target('Leads', '${member.targets.leads}'),
                    _target('Meetings', '${member.targets.meetings}'),
                    _target('Demos', '${member.targets.demos}'),
                    _target('Proposals', '${member.targets.proposals}'),
                    _target(
                      'Bookings pace',
                      Formatters.currency(member.targets.bookings),
                    ),
                    _target(
                      'Follow-ups',
                      Formatters.percent(member.targets.followUpsPct),
                    ),
                    if (member.targets.content != null)
                      _target('Content', '${member.targets.content}'),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Log this week'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeeklyEntryForm(member: member),
          ),
          const SectionHeader(title: 'Cumulative totals (auto)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _target('Weeks reported', '${totals.weeksReported}'),
                    _target('Leads', '${totals.leads}'),
                    _target('Meetings', '${totals.meetings}'),
                    _target('Demos', '${totals.demos}'),
                    _target('Proposals', '${totals.proposals}'),
                    _target(
                      'Proposal value',
                      Formatters.currency(totals.proposalValue),
                    ),
                    _target(
                      'Bookings won',
                      Formatters.currency(totals.bookingsWon),
                    ),
                    _target(
                      'Avg bookings/week',
                      Formatters.currency(totals.avgBookingsPerWeek),
                    ),
                    if (totals.contentPublished != null)
                      _target(
                        'Content published',
                        '${totals.contentPublished}',
                      ),
                  ],
                ),
              ),
            ),
          ),
          SectionHeader(
            title: 'History',
            subtitle: '${entries.length} week(s) reported',
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No weeks logged yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...entries.map((e) {
            final status = appState.statusFor(e);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                child: ListTile(
                  title: Text(e.weekLabel),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text('Leads ${e.leads}'),
                        Text('Meetings ${e.meetings}'),
                        Text('Demos ${e.demos}'),
                        Text('Proposals ${e.proposals}'),
                        Text('Bookings ${Formatters.currency(e.bookingsWon)}'),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                  leading: TextStatusChip(
                    text: status.onTrack ? 'ON TRACK' : 'MISSED',
                    onTrack: status.onTrack,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => appState.deleteWeeklyEntry(e.id),
                  ),
                  subtitleTextStyle: const TextStyle(fontSize: 12),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _target(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WeeklyEntryForm extends StatefulWidget {
  final TeamMember member;
  const _WeeklyEntryForm({required this.member});

  @override
  State<_WeeklyEntryForm> createState() => _WeeklyEntryFormState();
}

class _WeeklyEntryFormState extends State<_WeeklyEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weekCtrl;
  final _leadsCtrl = TextEditingController(text: '0');
  final _meetingsCtrl = TextEditingController(text: '0');
  final _demosCtrl = TextEditingController(text: '0');
  final _proposalsCtrl = TextEditingController(text: '0');
  final _proposalValueCtrl = TextEditingController(text: '0');
  final _bookingsCtrl = TextEditingController(text: '0');
  final _followUpsCtrl = TextEditingController(text: '100');
  final _contentCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _weekCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final tracksContent = widget.member.targets.content != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _weekCtrl,
                decoration: const InputDecoration(
                  labelText: 'Week label',
                  hintText: 'e.g. Shrawan W1',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _num(_leadsCtrl, 'Leads Added')),
                  const SizedBox(width: 8),
                  Expanded(child: _num(_meetingsCtrl, 'Meetings Held')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _num(_demosCtrl, 'Demos Delivered')),
                  const SizedBox(width: 8),
                  Expanded(child: _num(_proposalsCtrl, 'Proposals Submitted')),
                ],
              ),
              const SizedBox(height: 8),
              _num(_proposalValueCtrl, 'Proposal Value (NRs.)'),
              const SizedBox(height: 8),
              _num(_bookingsCtrl, 'Bookings Won (NRs.)'),
              const SizedBox(height: 8),
              _num(_followUpsCtrl, 'Follow-ups Done (%)'),
              if (tracksContent) ...[
                const SizedBox(height: 8),
                _num(_contentCtrl, 'Content Published'),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit weekly report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _num(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          (v == null || double.tryParse(v) == null) ? 'Enter a number' : null,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    appState.addWeeklyEntry(
      memberId: widget.member.id,
      weekLabel: _weekCtrl.text.trim(),
      leads: int.parse(_leadsCtrl.text),
      meetings: int.parse(_meetingsCtrl.text),
      demos: int.parse(_demosCtrl.text),
      proposals: int.parse(_proposalsCtrl.text),
      proposalValue: double.parse(_proposalValueCtrl.text),
      bookingsWon: double.parse(_bookingsCtrl.text),
      followUpsPct: double.parse(_followUpsCtrl.text) / 100,
      contentPublished: widget.member.targets.content != null
          ? int.parse(_contentCtrl.text)
          : null,
    );
    _weekCtrl.clear();
    for (final c in [
      _leadsCtrl,
      _meetingsCtrl,
      _demosCtrl,
      _proposalsCtrl,
      _proposalValueCtrl,
      _bookingsCtrl,
      _contentCtrl,
    ]) {
      c.text = '0';
    }
    _followUpsCtrl.text = '100';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Weekly report submitted.')));
  }
}
