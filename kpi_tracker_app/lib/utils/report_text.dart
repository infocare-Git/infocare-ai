import '../models/monthly_kpi.dart';
import '../models/team_member.dart';
import 'status_logic.dart';

/// Plain-text recap generators for the Reports screen — the same text
/// that renders on screen is what gets shared, so there's exactly one
/// place that decides what a recap says.
class ReportText {
  ReportText._();

  static String weeklyRecap({
    required List<TeamMember> members,
    required Map<String, String?> latestWeekLabelByMember,
    required Map<String, WeeklyStatus?> statusByMember,
  }) {
    final buffer = StringBuffer('Weekly Recap\n');
    for (final m in members) {
      final weekLabel = latestWeekLabelByMember[m.id];
      final status = statusByMember[m.id];
      if (weekLabel == null || status == null) {
        buffer.writeln('- ${m.name}: no week logged yet');
        continue;
      }
      buffer.writeln('- ${m.name} ($weekLabel): ${status.label}');
    }
    return buffer.toString().trimRight();
  }

  static String monthlyRecap({
    required List<MonthlyKpiDefinition> defs,
    required Map<String, double?> latestActualByKpi,
  }) {
    final buffer = StringBuffer('Monthly KPI Recap\n');
    var green = 0, yellow = 0, red = 0, notEntered = 0;
    for (final d in defs) {
      final actual = latestActualByKpi[d.id];
      final status = computeMonthlyKpiStatus(d, actual);
      switch (status) {
        case StatusLevel.green:
          green++;
          break;
        case StatusLevel.yellow:
          yellow++;
          break;
        case StatusLevel.red:
          red++;
          break;
        case StatusLevel.notEntered:
          notEntered++;
          break;
      }
      final valueLabel = actual == null ? 'not entered' : d.formatValue(actual);
      buffer.writeln('- ${d.name}: $valueLabel (${_statusWord(status)})');
    }
    buffer.writeln(
      '\nSummary: $green on track, $yellow watch, $red red flag, '
      '$notEntered not entered',
    );
    return buffer.toString().trimRight();
  }

  static String _statusWord(StatusLevel status) {
    switch (status) {
      case StatusLevel.green:
        return 'on track';
      case StatusLevel.yellow:
        return 'watch';
      case StatusLevel.red:
        return 'red flag';
      case StatusLevel.notEntered:
        return 'not entered';
    }
  }
}
