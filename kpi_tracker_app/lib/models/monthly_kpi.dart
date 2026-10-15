enum KpiUnit { percent, multiplier, days, count }

enum KpiDirection { higherIsBetter, lowerIsBetter }

KpiUnit _unitFromString(String value) =>
    KpiUnit.values.firstWhere((u) => u.name == value, orElse: () => KpiUnit.count);

KpiDirection _directionFromString(String value) => KpiDirection.values.firstWhere(
  (d) => d.name == value,
  orElse: () => KpiDirection.higherIsBetter,
);

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'formula': formula,
    'targetGoalLabel': targetGoalLabel,
    'redFlagLabel': redFlagLabel,
    'owner': owner,
    'targetThreshold': targetThreshold,
    'redThreshold': redThreshold,
    'direction': direction.name,
    'unit': unit.name,
  };

  factory MonthlyKpiDefinition.fromMap(Map map) => MonthlyKpiDefinition(
    id: map['id'] as String,
    name: map['name'] as String,
    formula: map['formula'] as String,
    targetGoalLabel: map['targetGoalLabel'] as String,
    redFlagLabel: map['redFlagLabel'] as String,
    owner: map['owner'] as String,
    targetThreshold: (map['targetThreshold'] as num).toDouble(),
    redThreshold: (map['redThreshold'] as num).toDouble(),
    direction: _directionFromString(map['direction'] as String),
    unit: _unitFromString(map['unit'] as String),
  );

  MonthlyKpiDefinition copyWith({
    String? name,
    String? formula,
    String? targetGoalLabel,
    String? redFlagLabel,
    String? owner,
    double? targetThreshold,
    double? redThreshold,
    KpiDirection? direction,
    KpiUnit? unit,
  }) => MonthlyKpiDefinition(
    id: id,
    name: name ?? this.name,
    formula: formula ?? this.formula,
    targetGoalLabel: targetGoalLabel ?? this.targetGoalLabel,
    redFlagLabel: redFlagLabel ?? this.redFlagLabel,
    owner: owner ?? this.owner,
    targetThreshold: targetThreshold ?? this.targetThreshold,
    redThreshold: redThreshold ?? this.redThreshold,
    direction: direction ?? this.direction,
    unit: unit ?? this.unit,
  );

  String formatValue(double value) => formatForUnit(unit, value);

  /// Auto-generates the "≥ 100%" / "< 85%" style display label for a
  /// threshold, so a new KPI's labels don't have to be typed by hand —
  /// just the number and whether higher or lower is better.
  static String thresholdLabel({
    required KpiDirection direction,
    required KpiUnit unit,
    required double value,
    required bool isRedFlag,
  }) {
    final comparator = isRedFlag
        ? (direction == KpiDirection.higherIsBetter ? '<' : '>')
        : (direction == KpiDirection.higherIsBetter ? '≥' : '≤');
    return '$comparator ${formatForUnit(unit, value)}';
  }

  static String formatForUnit(KpiUnit unit, double value) {
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
