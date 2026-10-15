import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_tracker/models/monthly_kpi.dart';

void main() {
  group('MonthlyKpiDefinition.thresholdLabel', () {
    test('higher-is-better percent KPI', () {
      expect(
        MonthlyKpiDefinition.thresholdLabel(
          direction: KpiDirection.higherIsBetter,
          unit: KpiUnit.percent,
          value: 1.0,
          isRedFlag: false,
        ),
        '≥ 100%',
      );
      expect(
        MonthlyKpiDefinition.thresholdLabel(
          direction: KpiDirection.higherIsBetter,
          unit: KpiUnit.percent,
          value: 0.85,
          isRedFlag: true,
        ),
        '< 85%',
      );
    });

    test('lower-is-better days KPI', () {
      expect(
        MonthlyKpiDefinition.thresholdLabel(
          direction: KpiDirection.lowerIsBetter,
          unit: KpiUnit.days,
          value: 120,
          isRedFlag: false,
        ),
        '≤ 120 days',
      );
      expect(
        MonthlyKpiDefinition.thresholdLabel(
          direction: KpiDirection.lowerIsBetter,
          unit: KpiUnit.days,
          value: 180,
          isRedFlag: true,
        ),
        '> 180 days',
      );
    });
  });

  group('MonthlyKpiDefinition toMap/fromMap', () {
    test('round-trips every field including enums', () {
      const def = MonthlyKpiDefinition(
        id: 'k1',
        name: 'Custom KPI',
        formula: 'a / b',
        targetGoalLabel: '≥ 3.0x',
        redFlagLabel: '< 2.0x',
        owner: 'Each',
        targetThreshold: 3.0,
        redThreshold: 2.0,
        direction: KpiDirection.higherIsBetter,
        unit: KpiUnit.multiplier,
      );
      final restored = MonthlyKpiDefinition.fromMap(def.toMap());
      expect(restored.id, def.id);
      expect(restored.name, def.name);
      expect(restored.direction, KpiDirection.higherIsBetter);
      expect(restored.unit, KpiUnit.multiplier);
      expect(restored.targetThreshold, 3.0);
      expect(restored.redThreshold, 2.0);
    });
  });
}
