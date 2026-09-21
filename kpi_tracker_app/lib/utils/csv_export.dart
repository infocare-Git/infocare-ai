import '../models/monthly_kpi.dart';
import '../models/team_member.dart';
import '../models/weekly_entry.dart';

/// Builds CSV strings for sharing data outside the app. Hand-rolled since
/// the escaping rules needed here are simple — no extra package required.
class CsvExport {
  CsvExport._();

  static String _cell(Object? value) {
    final s = value?.toString() ?? '';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_cell).join(',');

  static String weeklyEntries(
    List<WeeklyEntry> entries,
    List<TeamMember> members,
  ) {
    final names = {for (final m in members) m.id: m.name};
    final sorted = [...entries]
      ..sort((a, b) => a.enteredAt.compareTo(b.enteredAt));
    final buffer = StringBuffer();
    buffer.writeln(
      _row([
        'Member',
        'Week',
        'Leads',
        'Meetings',
        'Demos',
        'Proposals',
        'Proposal Value',
        'Bookings Won',
        'Follow-ups %',
        'Content Published',
        'Entered At',
      ]),
    );
    for (final e in sorted) {
      buffer.writeln(
        _row([
          names[e.memberId] ?? e.memberId,
          e.weekLabel,
          e.leads,
          e.meetings,
          e.demos,
          e.proposals,
          e.proposalValue,
          e.bookingsWon,
          (e.followUpsPct * 100).toStringAsFixed(1),
          e.contentPublished ?? '',
          e.enteredAt.toIso8601String(),
        ]),
      );
    }
    return buffer.toString();
  }

  static String monthlyKpiActuals(
    List<MonthlyKpiDefinition> defs,
    List<MonthlyKpiActual> actuals,
  ) {
    final names = {for (final d in defs) d.id: d.name};
    final sorted = [...actuals]
      ..sort((a, b) => a.enteredAt.compareTo(b.enteredAt));
    final buffer = StringBuffer();
    buffer.writeln(_row(['KPI', 'Month', 'Actual', 'Entered At']));
    for (final a in sorted) {
      buffer.writeln(
        _row([
          names[a.kpiId] ?? a.kpiId,
          a.monthLabel,
          a.actual,
          a.enteredAt.toIso8601String(),
        ]),
      );
    }
    return buffer.toString();
  }
}
