import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/team_member.dart';
import '../state/app_state.dart';

/// Shared add/edit form for a Director or Sales Team member and their
/// weekly targets. Used from onboarding and from Manage Team.
class MemberFormSheet extends StatefulWidget {
  final TeamMember? existing;
  final bool setActiveOnCreate;

  const MemberFormSheet({
    super.key,
    this.existing,
    this.setActiveOnCreate = false,
  });

  @override
  State<MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<MemberFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _segmentCtrl;
  late final TextEditingController _leadsCtrl;
  late final TextEditingController _meetingsCtrl;
  late final TextEditingController _demosCtrl;
  late final TextEditingController _proposalsCtrl;
  late final TextEditingController _bookingsCtrl;
  late final TextEditingController _followUpsCtrl;
  late final TextEditingController _contentCtrl;
  late bool _trackContent;
  late TeamRole _role;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _segmentCtrl = TextEditingController(
      text: e?.segment ?? 'Commercial (B2B)',
    );
    _leadsCtrl = TextEditingController(text: '${e?.targets.leads ?? 4}');
    _meetingsCtrl = TextEditingController(text: '${e?.targets.meetings ?? 4}');
    _demosCtrl = TextEditingController(text: '${e?.targets.demos ?? 2}');
    _proposalsCtrl = TextEditingController(
      text: '${e?.targets.proposals ?? 1}',
    );
    _bookingsCtrl = TextEditingController(
      text: '${e?.targets.bookings ?? 100000}',
    );
    _followUpsCtrl = TextEditingController(
      text: '${((e?.targets.followUpsPct ?? 1.0) * 100).round()}',
    );
    _trackContent = e?.targets.content != null;
    _contentCtrl = TextEditingController(text: '${e?.targets.content ?? 2}');
    _role = e?.role ?? TeamRole.salesRep;
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
                widget.existing == null
                    ? 'New team member'
                    : 'Edit team member',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set their weekly targets — the app tracks them against these every week.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TeamRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                    value: TeamRole.director,
                    child: Text('Director'),
                  ),
                  DropdownMenuItem(
                    value: TeamRole.salesRep,
                    child: Text('Sales Team'),
                  ),
                  DropdownMenuItem(value: TeamRole.admin, child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? _role),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _segmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Segment / territory',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Weekly targets',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _numberField(_leadsCtrl, 'Leads')),
                  const SizedBox(width: 8),
                  Expanded(child: _numberField(_meetingsCtrl, 'Meetings')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _numberField(_demosCtrl, 'Demos')),
                  const SizedBox(width: 8),
                  Expanded(child: _numberField(_proposalsCtrl, 'Proposals')),
                ],
              ),
              const SizedBox(height: 8),
              _numberField(_bookingsCtrl, 'Bookings pace target (NRs./week)'),
              const SizedBox(height: 8),
              _numberField(_followUpsCtrl, 'Follow-ups target (%)'),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Track content published?'),
                value: _trackContent,
                onChanged: (v) => setState(() => _trackContent = v),
              ),
              if (_trackContent)
                _numberField(_contentCtrl, 'Content posts / week'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      widget.existing == null
                          ? 'Create profile'
                          : 'Save changes',
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

  Widget _numberField(TextEditingController ctrl, String label) {
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
    final targets = WeeklyTargets(
      leads: int.parse(_leadsCtrl.text),
      meetings: int.parse(_meetingsCtrl.text),
      demos: int.parse(_demosCtrl.text),
      proposals: int.parse(_proposalsCtrl.text),
      bookings: double.parse(_bookingsCtrl.text),
      followUpsPct: double.parse(_followUpsCtrl.text) / 100,
      content: _trackContent ? int.parse(_contentCtrl.text) : null,
    );

    if (widget.existing != null) {
      appState.updateTeamMember(
        widget.existing!.copyWith(
          name: _nameCtrl.text.trim(),
          role: _role,
          segment: _segmentCtrl.text.trim(),
          targets: targets,
        ),
      );
    } else {
      final id = const Uuid().v4();
      final member = TeamMember(
        id: id,
        name: _nameCtrl.text.trim(),
        role: _role,
        segment: _segmentCtrl.text.trim(),
        targets: targets,
      );
      appState.addTeamMember(member);
      if (widget.setActiveOnCreate) appState.setActiveMember(id);
    }
    Navigator.of(context).pop();
  }
}
