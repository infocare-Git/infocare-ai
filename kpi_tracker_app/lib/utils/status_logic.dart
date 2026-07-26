import '../models/monthly_kpi.dart';
import '../models/team_member.dart';
import '../models/weekly_entry.dart';

enum StatusLevel { green, yellow, red, notEntered }

/// Mirrors the "Status (auto — lists missed targets)" column on the
/// Director weekly sheets: lists every target the entry missed, or
/// "ON TRACK — all targets met" when none were missed.
class WeeklyStatus {
  final List<String> missed;
  const WeeklyStatus(this.missed);

  bool get onTrack => missed.isEmpty;

  String get label =>
      onTrack ? 'ON TRACK — all targets met' : 'Missed: ${missed.join(', ')}';
}

WeeklyStatus computeWeeklyStatus(WeeklyEntry entry, WeeklyTargets targets) {
  final missed = <String>[];
  if (entry.leads < targets.leads) missed.add('Leads');
  if (entry.meetings < targets.meetings) missed.add('Meetings');
  if (entry.demos < targets.demos) missed.add('Demos');
  if (entry.proposals < targets.proposals) missed.add('Proposals');
  if (entry.bookingsWon < targets.bookings) missed.add('Bookings');
  if (entry.followUpsPct < targets.followUpsPct) missed.add('Follow-ups');
  if (targets.content != null &&
      (entry.contentPublished ?? 0) < targets.content!) {
    missed.add('Content');
  }
  return WeeklyStatus(missed);
}

/// Mirrors the Monthly KPI Dashboard's auto Status column, driven by the
/// hidden target/red-flag threshold columns and a +1/-1 direction flag.
StatusLevel computeMonthlyKpiStatus(MonthlyKpiDefinition def, double? actual) {
  if (actual == null) return StatusLevel.notEntered;
  final higherIsBetter = def.direction == KpiDirection.higherIsBetter;
  if (higherIsBetter) {
    if (actual >= def.targetThreshold) return StatusLevel.green;
    if (actual < def.redThreshold) return StatusLevel.red;
    return StatusLevel.yellow;
  } else {
    if (actual <= def.targetThreshold) return StatusLevel.green;
    if (actual > def.redThreshold) return StatusLevel.red;
    return StatusLevel.yellow;
  }
}

/// Mirrors the Live Pipeline "Coverage ratio (must be ≥ 3×)" health check.
class PipelineHealth {
  final double totalOpenValue;
  final double totalWeightedValue;
  final double remainingQuarterlyTarget;

  const PipelineHealth({
    required this.totalOpenValue,
    required this.totalWeightedValue,
    required this.remainingQuarterlyTarget,
  });

  double get coverageRatio => remainingQuarterlyTarget <= 0
      ? 0
      : totalWeightedValue / remainingQuarterlyTarget;

  StatusLevel get status {
    if (coverageRatio >= 3) return StatusLevel.green;
    if (coverageRatio < 2) return StatusLevel.red;
    return StatusLevel.yellow;
  }

  String get statusLabel {
    switch (status) {
      case StatusLevel.green:
        return 'HEALTHY — coverage on track';
      case StatusLevel.yellow:
        return 'WATCH — coverage below 3× target';
      case StatusLevel.red:
        return 'RED FLAG — shift next week to lead generation';
      case StatusLevel.notEntered:
        return 'Not entered';
    }
  }
}

/// Mirrors the Activities Plan auto Status column.
String activityStatusLabel(int progressPct) {
  if (progressPct <= 0) return 'NOT STARTED';
  if (progressPct >= 100) return 'COMPLETE';
  return 'IN PROGRESS';
}
