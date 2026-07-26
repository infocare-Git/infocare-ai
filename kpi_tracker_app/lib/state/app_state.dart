import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_boxes.dart';
import '../data/seed_data.dart';
import '../models/activity_item.dart';
import '../models/annual_target.dart';
import '../models/monthly_kpi.dart';
import '../models/pipeline_deal.dart';
import '../models/team_member.dart';
import '../models/weekly_entry.dart';
import '../utils/status_logic.dart';

const _uuid = Uuid();
const String _activeMemberKey = 'active_member_id';
const String _remainingQuarterlyTargetKey = 'remaining_quarterly_target';

/// Cumulative totals for one member, mirroring the "Cumulative Totals
/// (auto)" block at the bottom of each Director weekly sheet.
class CumulativeTotals {
  final int leads;
  final int meetings;
  final int demos;
  final int proposals;
  final double proposalValue;
  final double bookingsWon;
  final int? contentPublished;
  final int weeksReported;

  const CumulativeTotals({
    required this.leads,
    required this.meetings,
    required this.demos,
    required this.proposals,
    required this.proposalValue,
    required this.bookingsWon,
    required this.weeksReported,
    this.contentPublished,
  });

  double get avgBookingsPerWeek =>
      weeksReported == 0 ? 0 : bookingsWon / weeksReported;

  static const zero = CumulativeTotals(
    leads: 0,
    meetings: 0,
    demos: 0,
    proposals: 0,
    proposalValue: 0,
    bookingsWon: 0,
    weeksReported: 0,
  );
}

/// The single source of truth for the app. Wraps Hive boxes and exposes
/// computed values that mirror the source workbook's formulas.
class AppState extends ChangeNotifier {
  late Box<Map> _teamMembersBox;
  late Box<Map> _weeklyEntriesBox;
  late Box<Map> _pipelineDealsBox;
  late Box<Map> _monthlyKpiActualsBox;
  late Box<Map> _activityProgressBox;
  late Box<Map> _revenueStreamsBox;
  late Box<Map> _quarterTargetsBox;
  late Box _appMetaBox;

  bool _ready = false;
  bool get ready => _ready;

  Future<void> init() async {
    await HiveBoxes.openAll();
    _teamMembersBox = Hive.box<Map>(HiveBoxes.teamMembers);
    _weeklyEntriesBox = Hive.box<Map>(HiveBoxes.weeklyEntries);
    _pipelineDealsBox = Hive.box<Map>(HiveBoxes.pipelineDeals);
    _monthlyKpiActualsBox = Hive.box<Map>(HiveBoxes.monthlyKpiActuals);
    _activityProgressBox = Hive.box<Map>(HiveBoxes.activityProgress);
    _revenueStreamsBox = Hive.box<Map>(HiveBoxes.revenueStreams);
    _quarterTargetsBox = Hive.box<Map>(HiveBoxes.quarterTargets);
    _appMetaBox = Hive.box(HiveBoxes.appMeta);

    _seedIfEmpty();
    _ready = true;
    notifyListeners();
  }

  void _seedIfEmpty() {
    if (_teamMembersBox.isEmpty) {
      for (final m in SeedData.defaultTeamMembers()) {
        _teamMembersBox.put(m.id, m.toMap());
      }
    }
    if (_activityProgressBox.isEmpty) {
      for (final a in SeedData.defaultActivities()) {
        _activityProgressBox.put(a.id, a.toMap());
      }
    }
    if (_revenueStreamsBox.isEmpty) {
      for (final r in SeedData.defaultRevenueStreams()) {
        _revenueStreamsBox.put(r.id, r.toMap());
      }
    }
    if (_quarterTargetsBox.isEmpty) {
      for (final q in SeedData.defaultQuarterTargets()) {
        _quarterTargetsBox.put(q.id, q.toMap());
      }
    }
    if (!_appMetaBox.containsKey(_remainingQuarterlyTargetKey)) {
      _appMetaBox.put(_remainingQuarterlyTargetKey, 7000000.0);
    }
  }

  // ---------------- Team members ----------------

  List<TeamMember> get members =>
      _teamMembersBox.values.map((m) => TeamMember.fromMap(m)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  String? get activeMemberId => _appMetaBox.get(_activeMemberKey) as String?;

  TeamMember? get activeMember {
    final id = activeMemberId;
    if (id == null) return null;
    final raw = _teamMembersBox.get(id);
    return raw == null ? null : TeamMember.fromMap(raw);
  }

  void setActiveMember(String id) {
    _appMetaBox.put(_activeMemberKey, id);
    notifyListeners();
  }

  Future<void> clearActiveMember() async {
    await _appMetaBox.delete(_activeMemberKey);
    notifyListeners();
  }

  TeamMember? memberById(String id) {
    final raw = _teamMembersBox.get(id);
    return raw == null ? null : TeamMember.fromMap(raw);
  }

  Future<void> addTeamMember(TeamMember member) async {
    await _teamMembersBox.put(member.id, member.toMap());
    notifyListeners();
  }

  Future<void> updateTeamMember(TeamMember member) async {
    await _teamMembersBox.put(member.id, member.toMap());
    notifyListeners();
  }

  Future<void> removeTeamMember(String id) async {
    await _teamMembersBox.delete(id);
    for (final e in weeklyEntries.where((e) => e.memberId == id).toList()) {
      await _weeklyEntriesBox.delete(e.id);
    }
    if (activeMemberId == id) {
      await _appMetaBox.delete(_activeMemberKey);
    }
    notifyListeners();
  }

  // ---------------- Weekly entries ----------------

  List<WeeklyEntry> get weeklyEntries =>
      _weeklyEntriesBox.values.map((m) => WeeklyEntry.fromMap(m)).toList()
        ..sort((a, b) => b.enteredAt.compareTo(a.enteredAt));

  List<WeeklyEntry> entriesFor(String memberId) =>
      weeklyEntries.where((e) => e.memberId == memberId).toList();

  Future<WeeklyEntry> addWeeklyEntry({
    required String memberId,
    required String weekLabel,
    required int leads,
    required int meetings,
    required int demos,
    required int proposals,
    required double proposalValue,
    required double bookingsWon,
    required double followUpsPct,
    int? contentPublished,
  }) async {
    final entry = WeeklyEntry(
      id: _uuid.v4(),
      memberId: memberId,
      weekLabel: weekLabel,
      leads: leads,
      meetings: meetings,
      demos: demos,
      proposals: proposals,
      proposalValue: proposalValue,
      bookingsWon: bookingsWon,
      followUpsPct: followUpsPct,
      contentPublished: contentPublished,
      enteredAt: DateTime.now(),
    );
    await _weeklyEntriesBox.put(entry.id, entry.toMap());
    notifyListeners();
    return entry;
  }

  Future<void> deleteWeeklyEntry(String id) async {
    await _weeklyEntriesBox.delete(id);
    notifyListeners();
  }

  WeeklyStatus statusFor(WeeklyEntry entry) {
    final member = memberById(entry.memberId);
    if (member == null) return const WeeklyStatus([]);
    return computeWeeklyStatus(entry, member.targets);
  }

  CumulativeTotals cumulativeTotalsFor(String memberId) {
    final entries = entriesFor(memberId);
    if (entries.isEmpty) return CumulativeTotals.zero;
    final member = memberById(memberId);
    final tracksContent = member?.targets.content != null;
    return CumulativeTotals(
      leads: entries.fold(0, (s, e) => s + e.leads),
      meetings: entries.fold(0, (s, e) => s + e.meetings),
      demos: entries.fold(0, (s, e) => s + e.demos),
      proposals: entries.fold(0, (s, e) => s + e.proposals),
      proposalValue: entries.fold(0.0, (s, e) => s + e.proposalValue),
      bookingsWon: entries.fold(0.0, (s, e) => s + e.bookingsWon),
      contentPublished: tracksContent
          ? entries.fold<int>(0, (s, e) => s + (e.contentPublished ?? 0))
          : null,
      weeksReported: entries.length,
    );
  }

  double get totalBookingsAllMembers =>
      members.fold(0.0, (s, m) => s + cumulativeTotalsFor(m.id).bookingsWon);

  // ---------------- Live Pipeline ----------------

  List<PipelineDeal> get pipelineDeals =>
      _pipelineDealsBox.values.map((m) => PipelineDeal.fromMap(m)).toList();

  Future<void> upsertDeal(PipelineDeal deal) async {
    await _pipelineDealsBox.put(deal.id, deal.toMap());
    notifyListeners();
  }

  Future<void> deleteDeal(String id) async {
    await _pipelineDealsBox.delete(id);
    notifyListeners();
  }

  double get remainingQuarterlyTarget =>
      (_appMetaBox.get(_remainingQuarterlyTargetKey) as num?)?.toDouble() ??
      7000000.0;

  Future<void> setRemainingQuarterlyTarget(double value) async {
    await _appMetaBox.put(_remainingQuarterlyTargetKey, value);
    notifyListeners();
  }

  PipelineHealth get pipelineHealth {
    final open = pipelineDeals.where((d) => d.isOpen);
    return PipelineHealth(
      totalOpenValue: open.fold(0.0, (s, d) => s + d.dealValue),
      totalWeightedValue: open.fold(0.0, (s, d) => s + d.weightedValue),
      remainingQuarterlyTarget: remainingQuarterlyTarget,
    );
  }

  // ---------------- Monthly KPI Dashboard ----------------

  List<MonthlyKpiDefinition> get monthlyKpiDefinitions =>
      SeedData.monthlyKpiDefinitions();

  List<MonthlyKpiActual> _actualsFor(String kpiId) =>
      _monthlyKpiActualsBox.values
          .map((m) => MonthlyKpiActual.fromMap(m))
          .where((a) => a.kpiId == kpiId)
          .toList()
        ..sort((a, b) => b.enteredAt.compareTo(a.enteredAt));

  MonthlyKpiActual? latestActualFor(String kpiId) {
    final list = _actualsFor(kpiId);
    return list.isEmpty ? null : list.first;
  }

  Future<void> setMonthlyActual({
    required String kpiId,
    required String monthLabel,
    required double actual,
  }) async {
    final entry = MonthlyKpiActual(
      kpiId: kpiId,
      monthLabel: monthLabel,
      actual: actual,
      enteredAt: DateTime.now(),
    );
    await _monthlyKpiActualsBox.put(entry.key, entry.toMap());
    notifyListeners();
  }

  // ---------------- Activities Plan ----------------

  List<ActivityItem> get activities =>
      _activityProgressBox.values.map((m) => ActivityItem.fromMap(m)).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  Future<void> setActivityProgress(String id, int progressPct) async {
    final raw = _activityProgressBox.get(id);
    if (raw == null) return;
    final updated = ActivityItem.fromMap(
      raw,
    ).copyWith(progressPct: progressPct);
    await _activityProgressBox.put(id, updated.toMap());
    notifyListeners();
  }

  double get averageActivityProgress {
    final list = activities;
    if (list.isEmpty) return 0;
    return list.fold(0, (s, a) => s + a.progressPct) / list.length;
  }

  // ---------------- Annual Targets ----------------

  List<RevenueStream> get revenueStreams =>
      _revenueStreamsBox.values.map((m) => RevenueStream.fromMap(m)).toList();

  double get totalAnnualRevenueTarget =>
      revenueStreams.fold(0.0, (s, r) => s + r.revenue);

  Future<void> updateRevenueStream(
    String id, {
    double? unitPrice,
    int? units,
  }) async {
    final raw = _revenueStreamsBox.get(id);
    if (raw == null) return;
    final updated = RevenueStream.fromMap(
      raw,
    ).copyWith(unitPrice: unitPrice, units: units);
    await _revenueStreamsBox.put(id, updated.toMap());
    notifyListeners();
  }

  List<QuarterTarget> get quarterTargets =>
      _quarterTargetsBox.values.map((m) => QuarterTarget.fromMap(m)).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  Future<void> updateQuarterTarget(String id, double bookingTarget) async {
    final raw = _quarterTargetsBox.get(id);
    if (raw == null) return;
    final updated = QuarterTarget.fromMap(
      raw,
    ).copyWith(bookingTarget: bookingTarget);
    await _quarterTargetsBox.put(id, updated.toMap());
    notifyListeners();
  }

  // ---------------- Backup / restore ----------------

  Map<String, dynamic> exportAll() => {
    'exportedAt': DateTime.now().toIso8601String(),
    'teamMembers': _teamMembersBox.values.toList(),
    'weeklyEntries': _weeklyEntriesBox.values.toList(),
    'pipelineDeals': _pipelineDealsBox.values.toList(),
    'monthlyKpiActuals': _monthlyKpiActualsBox.values.toList(),
    'activityProgress': _activityProgressBox.values.toList(),
    'revenueStreams': _revenueStreamsBox.values.toList(),
    'quarterTargets': _quarterTargetsBox.values.toList(),
    'remainingQuarterlyTarget': remainingQuarterlyTarget,
  };

  Future<void> importAll(Map<String, dynamic> data) async {
    Future<void> replace(Box<Map> box, String key, String idField) async {
      await box.clear();
      final list = (data[key] as List?) ?? [];
      for (final raw in list) {
        final map = Map<String, dynamic>.from(raw as Map);
        await box.put(map[idField] ?? _uuid.v4(), map);
      }
    }

    await replace(_teamMembersBox, 'teamMembers', 'id');
    await replace(_weeklyEntriesBox, 'weeklyEntries', 'id');
    await replace(_pipelineDealsBox, 'pipelineDeals', 'id');
    await replace(_activityProgressBox, 'activityProgress', 'id');
    await replace(_revenueStreamsBox, 'revenueStreams', 'id');
    await replace(_quarterTargetsBox, 'quarterTargets', 'id');

    await _monthlyKpiActualsBox.clear();
    final actuals = (data['monthlyKpiActuals'] as List?) ?? [];
    for (final raw in actuals) {
      final map = Map<String, dynamic>.from(raw as Map);
      final actual = MonthlyKpiActual.fromMap(map);
      await _monthlyKpiActualsBox.put(actual.key, map);
    }

    if (data['remainingQuarterlyTarget'] != null) {
      await _appMetaBox.put(
        _remainingQuarterlyTargetKey,
        (data['remainingQuarterlyTarget'] as num).toDouble(),
      );
    }
    await _appMetaBox.delete(_activeMemberKey);
    notifyListeners();
  }
}
