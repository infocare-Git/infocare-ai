import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_tracker/models/monthly_kpi.dart';
import 'package:kpi_tracker/models/team_member.dart';
import 'package:kpi_tracker/models/weekly_entry.dart';
import 'package:kpi_tracker/utils/csv_export.dart';
import 'package:kpi_tracker/utils/report_text.dart';
import 'package:kpi_tracker/utils/status_logic.dart';

void main() {
  const memberA = TeamMember(
    id: 'a',
    name: 'Director A',
    role: TeamRole.director,
    segment: 'Government (B2G)',
    targets: WeeklyTargets(
      leads: 4,
      meetings: 4,
      demos: 2,
      proposals: 1,
      bookings: 1030000,
      followUpsPct: 1.0,
    ),
  );

  group('ReportText.weeklyRecap', () {
    test('lists on-track and missing members correctly', () {
      final text = ReportText.weeklyRecap(
        members: const [memberA],
        latestWeekLabelByMember: const {'a': 'Shrawan W1'},
        statusByMember: const {
          'a': WeeklyStatus(['Meetings', 'Demos']),
        },
      );
      expect(text, contains('Director A (Shrawan W1)'));
      expect(text, contains('Missed: Meetings, Demos'));
    });

    test('flags members with no week logged yet', () {
      final text = ReportText.weeklyRecap(
        members: const [memberA],
        latestWeekLabelByMember: const {'a': null},
        statusByMember: const {'a': null},
      );
      expect(text, contains('Director A: no week logged yet'));
    });
  });

  group('ReportText.monthlyRecap', () {
    const def = MonthlyKpiDefinition(
      id: 'k1',
      name: 'Total bookings vs plan',
      formula: 'Cumulative signed value / cumulative target',
      targetGoalLabel: '≥ 100%',
      redFlagLabel: '< 85%',
      owner: 'Joint',
      targetThreshold: 1.0,
      redThreshold: 0.85,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    );

    test('summarizes status counts', () {
      final text = ReportText.monthlyRecap(
        defs: const [def],
        latestActualByKpi: const {'k1': 0.9},
      );
      expect(text, contains('90%'));
      expect(text, contains('watch'));
      expect(text, contains('Summary: 0 on track, 1 watch, 0 red flag, 0 not entered'));
    });
  });

  group('CsvExport', () {
    test('weeklyEntries produces a header row plus one row per entry', () {
      final entry = WeeklyEntry(
        id: 'e1',
        memberId: 'a',
        weekLabel: 'Shrawan W1',
        leads: 4,
        meetings: 4,
        demos: 2,
        proposals: 1,
        proposalValue: 500000,
        bookingsWon: 1030000,
        followUpsPct: 1.0,
        enteredAt: DateTime(2026, 1, 1),
      );
      final csv = CsvExport.weeklyEntries([entry], const [memberA]);
      final lines = csv.trim().split('\n');
      expect(lines, hasLength(2));
      expect(lines.first, startsWith('Member,Week,Leads'));
      expect(lines.last, startsWith('Director A,Shrawan W1,4,4,2,1'));
    });

    test('escapes commas in cell values', () {
      final actual = MonthlyKpiActual(
        kpiId: 'k1',
        monthLabel: 'Shrawan, 2083',
        actual: 0.9,
        enteredAt: DateTime(2026, 1, 1),
      );
      const def = MonthlyKpiDefinition(
        id: 'k1',
        name: 'Total bookings vs plan',
        formula: 'f',
        targetGoalLabel: 't',
        redFlagLabel: 'r',
        owner: 'Joint',
        targetThreshold: 1.0,
        redThreshold: 0.85,
        direction: KpiDirection.higherIsBetter,
        unit: KpiUnit.percent,
      );
      final csv = CsvExport.monthlyKpiActuals([def], [actual]);
      expect(csv, contains('"Shrawan, 2083"'));
    });
  });
}
