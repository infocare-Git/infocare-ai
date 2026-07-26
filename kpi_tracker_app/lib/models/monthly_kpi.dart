enum KpiUnit { percent, multiplier, days, count }

enum KpiDirection { higherIsBetter, lowerIsBetter }

/// Static definition of one row on the Monthly KPI Dashboard sheet.
/// These mirror the workbook's hidden columns I/J/K that drive the
/// auto Status formula.
class MonthlyKpiDefinition {
  final String id;
  final String name;
  final String formula;
  final String targetGoalLabel;
  final String redFlagLabel;
  final String owner;
  final double targetThreshold;
  final double redThreshold;
  final KpiDirection direction;
  final KpiUnit unit;

  const MonthlyKpiDefinition({
    required this.id,
    required this.name,
    required this.formula,
    required this.targetGoalLabel,
    required this.redFlagLabel,
    required this.owner,
    required this.targetThreshold,
    required this.redThreshold,
    required this.direction,
    required this.unit,
  });

  String formatValue(double value) {
    switch (unit) {
      case KpiUnit.percent:
        return '${(value * 100).toStringAsFixed(0)}%';
      case KpiUnit.multiplier:
        return '${value.toStringAsFixed(1)}x';
      case KpiUnit.days:
        return '${value.toStringAsFixed(0)} days';
      case KpiUnit.count:
        return value.toStringAsFixed(0);
    }
  }
}

/// One month's entered actual for a given KPI, mirroring the
/// "Current Actual (enter)" blue column.
class MonthlyKpiActual {
  final String kpiId;
  final String monthLabel; // e.g. "Shrawan 2083"
  final double actual;
  final DateTime enteredAt;

  const MonthlyKpiActual({
    required this.kpiId,
    required this.monthLabel,
    required this.actual,
    required this.enteredAt,
  });

  String get key => '${kpiId}__$monthLabel';

  Map<String, dynamic> toMap() => {
    'kpiId': kpiId,
    'monthLabel': monthLabel,
    'actual': actual,
    'enteredAt': enteredAt.toIso8601String(),
  };

  factory MonthlyKpiActual.fromMap(Map map) => MonthlyKpiActual(
    kpiId: map['kpiId'] as String,
    monthLabel: map['monthLabel'] as String,
    actual: (map['actual'] as num).toDouble(),
    enteredAt: DateTime.parse(map['enteredAt'] as String),
  );
}
