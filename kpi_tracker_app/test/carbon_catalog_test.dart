import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_tracker/data/carbon_catalog.dart';
import 'package:kpi_tracker/models/carbon_entry.dart';

void main() {
  group('CarbonCatalog', () {
    test('every activity type has a unique id and a positive factor', () {
      final ids = CarbonCatalog.activityTypes.map((t) => t.id).toSet();
      expect(ids.length, CarbonCatalog.activityTypes.length);
      for (final type in CarbonCatalog.activityTypes) {
        expect(type.co2PerUnit, greaterThan(0));
      }
    });

    test('byId finds a known activity and returns null for unknown ids', () {
      expect(CarbonCatalog.byId('biked_or_walked')?.label, contains('Biked'));
      expect(CarbonCatalog.byId('not_a_real_activity'), isNull);
    });
  });

  group('CarbonActivityType.co2For', () {
    test('scales linearly with quantity', () {
      const type = CarbonActivityType(
        id: 't1',
        label: 'Test',
        icon: '🌱',
        unit: CarbonUnit.km,
        co2PerUnit: 0.19,
        sourceNote: 'test',
      );
      expect(type.co2For(1), closeTo(0.19, 1e-9));
      expect(type.co2For(10), closeTo(1.9, 1e-9));
      expect(type.co2For(0), 0);
    });
  });

  group('CarbonLogEntry', () {
    test('round-trips through toMap/fromMap', () {
      final entry = CarbonLogEntry(
        id: 'e1',
        memberId: 'm1',
        activityTypeId: 'biked_or_walked',
        quantity: 5,
        loggedAt: DateTime(2026, 10, 15, 9, 30),
      );
      final restored = CarbonLogEntry.fromMap(entry.toMap());
      expect(restored.id, entry.id);
      expect(restored.memberId, entry.memberId);
      expect(restored.activityTypeId, entry.activityTypeId);
      expect(restored.quantity, entry.quantity);
      expect(restored.loggedAt, entry.loggedAt);
    });
  });
}
