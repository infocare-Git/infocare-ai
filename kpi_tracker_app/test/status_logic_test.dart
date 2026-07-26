import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_tracker/data/seed_data.dart';
import 'package:kpi_tracker/models/team_member.dart';
import 'package:kpi_tracker/models/weekly_entry.dart';
import 'package:kpi_tracker/utils/status_logic.dart';

void main() {
  group('computeWeeklyStatus', () {
    const targets = WeeklyTargets(
      leads: 4,
      meetings: 4,
      demos: 2,
      proposals: 1,
      bookings: 1030000,
      followUpsPct: 1.0,
    );

    WeeklyEntry entry({
      int leads = 4,
      int meetings = 4,
      int demos = 2,
      int proposals = 1,
      double bookings = 1030000,
      double followUps = 1.0,
    }) => WeeklyEntry(
      id: 'e1',
      memberId: 'm1',
      weekLabel: 'Shrawan W1',
      leads: leads,
      meetings: meetings,
      demos: demos,
      proposals: proposals,
      proposalValue: 0,
      bookingsWon: bookings,
      followUpsPct: followUps,
      enteredAt: DateTime(2026, 1, 1),
    );

    test(
      'matches the workbook example: Shrawan W1 for Director A misses Meetings, Demos, Bookings',
      () {
        final e = WeeklyEntry(
          id: 'e1',
          memberId: SeedData.directorAId,
          weekLabel: 'Shrawan W1',
          leads: 4,
          meetings: 3,
          demos: 1,
          proposals: 1,
          proposalValue: 1500000,
          bookingsWon: 0,
          followUpsPct: 1.0,
          enteredAt: DateTime(2026, 1, 1),
        );
        final status = computeWeeklyStatus(e, targets);
        expect(status.onTrack, isFalse);
        expect(status.missed, ['Meetings', 'Demos', 'Bookings']);
      },
    );

    test('all targets met reports ON TRACK', () {
      final status = computeWeeklyStatus(entry(), targets);
      expect(status.onTrack, isTrue);
      expect(status.label, 'ON TRACK — all targets met');
    });

    test('missing a single target names only that target', () {
      final status = computeWeeklyStatus(entry(leads: 1), targets);
      expect(status.missed, ['Leads']);
    });

    test('content target only enforced when the member tracks content', () {
      const targetsWithContent = WeeklyTargets(
        leads: 4,
        meetings: 6,
        demos: 3,
        proposals: 2,
        bookings: 130000,
        followUpsPct: 1.0,
        content: 2,
      );
      final e = WeeklyEntry(
        id: 'e2',
        memberId: SeedData.directorBId,
        weekLabel: 'Shrawan W2',
        leads: 4,
        meetings: 5,
        demos: 2,
        proposals: 2,
        proposalValue: 600000,
        bookingsWon: 0,
        followUpsPct: 1.0,
        contentPublished: 1,
        enteredAt: DateTime(2026, 1, 1),
      );
      final status = computeWeeklyStatus(e, targetsWithContent);
      expect(status.missed, ['Meetings', 'Demos', 'Bookings', 'Content']);
    });
  });

  group('computeMonthlyKpiStatus', () {
    final bookingsKpi = SeedData.monthlyKpiDefinitions().firstWhere(
      (d) => d.id == 'bookings_vs_plan',
    );
    final cycleKpi = SeedData.monthlyKpiDefinitions().firstWhere(
      (d) => d.id == 'sales_cycle_b2g',
    );

    test('not entered when actual is null', () {
      expect(
        computeMonthlyKpiStatus(bookingsKpi, null),
        StatusLevel.notEntered,
      );
    });

    test('higher-is-better: green at/above target', () {
      expect(computeMonthlyKpiStatus(bookingsKpi, 1.0), StatusLevel.green);
      expect(computeMonthlyKpiStatus(bookingsKpi, 1.2), StatusLevel.green);
    });

    test('higher-is-better: red below red flag threshold', () {
      expect(computeMonthlyKpiStatus(bookingsKpi, 0.5), StatusLevel.red);
    });

    test('higher-is-better: yellow between red flag and target', () {
      expect(computeMonthlyKpiStatus(bookingsKpi, 0.9), StatusLevel.yellow);
    });

    test('lower-is-better (sales cycle): green at/below target', () {
      expect(computeMonthlyKpiStatus(cycleKpi, 100), StatusLevel.green);
      expect(computeMonthlyKpiStatus(cycleKpi, 120), StatusLevel.green);
    });

    test('lower-is-better (sales cycle): red above red flag threshold', () {
      expect(computeMonthlyKpiStatus(cycleKpi, 200), StatusLevel.red);
    });

    test(
      'lower-is-better (sales cycle): yellow between target and red flag',
      () {
        expect(computeMonthlyKpiStatus(cycleKpi, 150), StatusLevel.yellow);
      },
    );
  });

  group('PipelineHealth', () {
    test('matches the workbook example coverage ratio', () {
      const health = PipelineHealth(
        totalOpenValue: 6300000,
        totalWeightedValue: 2660000,
        remainingQuarterlyTarget: 7000000,
      );
      expect(health.coverageRatio, closeTo(0.38, 0.01));
      expect(health.status, StatusLevel.red);
    });

    test('coverage >= 3x is green', () {
      const health = PipelineHealth(
        totalOpenValue: 10000000,
        totalWeightedValue: 21000000,
        remainingQuarterlyTarget: 7000000,
      );
      expect(health.coverageRatio, 3.0);
      expect(health.status, StatusLevel.green);
    });

    test('zero remaining target does not divide by zero', () {
      const health = PipelineHealth(
        totalOpenValue: 0,
        totalWeightedValue: 0,
        remainingQuarterlyTarget: 0,
      );
      expect(health.coverageRatio, 0);
    });
  });

  group('activityStatusLabel', () {
    test('0 is NOT STARTED, 1-99 is IN PROGRESS, 100 is COMPLETE', () {
      expect(activityStatusLabel(0), 'NOT STARTED');
      expect(activityStatusLabel(1), 'IN PROGRESS');
      expect(activityStatusLabel(99), 'IN PROGRESS');
      expect(activityStatusLabel(100), 'COMPLETE');
    });
  });
}
