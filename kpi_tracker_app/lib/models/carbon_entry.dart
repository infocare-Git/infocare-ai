/// The unit a carbon-saving activity is logged in.
enum CarbonUnit { km, meal, item, kgWaste, load, hour }

String carbonUnitLabel(CarbonUnit unit) {
  switch (unit) {
    case CarbonUnit.km:
      return 'km';
    case CarbonUnit.meal:
      return 'meal(s)';
    case CarbonUnit.item:
      return 'item(s)';
    case CarbonUnit.kgWaste:
      return 'kg';
    case CarbonUnit.load:
      return 'load(s)';
    case CarbonUnit.hour:
      return 'hour(s)';
  }
}

/// A catalog entry describing one everyday action and how much CO2e it
/// saves per unit logged. Factors are general averages (see
/// `lib/data/carbon_catalog.dart` for sources) — a quick, honest estimate,
/// not a precise personal carbon audit.
class CarbonActivityType {
  final String id;
  final String label;
  final String icon; // emoji, so no image asset is needed
  final CarbonUnit unit;
  final double co2PerUnit; // kg CO2e saved per 1 unit
  final String sourceNote;

  const CarbonActivityType({
    required this.id,
    required this.label,
    required this.icon,
    required this.unit,
    required this.co2PerUnit,
    required this.sourceNote,
  });

  double co2For(double quantity) => co2PerUnit * quantity;
}

/// One logged instance of a carbon-saving activity.
class CarbonLogEntry {
  final String id;
  final String memberId;
  final String activityTypeId;
  final double quantity;
  final DateTime loggedAt;

  const CarbonLogEntry({
    required this.id,
    required this.memberId,
    required this.activityTypeId,
    required this.quantity,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'memberId': memberId,
    'activityTypeId': activityTypeId,
    'quantity': quantity,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory CarbonLogEntry.fromMap(Map map) => CarbonLogEntry(
    id: map['id'] as String,
    memberId: map['memberId'] as String,
    activityTypeId: map['activityTypeId'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    loggedAt: DateTime.parse(map['loggedAt'] as String),
  );
}
