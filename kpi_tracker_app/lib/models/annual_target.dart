/// One product/revenue-stream row on the Annual Targets sheet.
/// Unit price and units are the yellow "assumption" cells the user may
/// adjust; revenue is always derived (unitPrice * units).
class RevenueStream {
  final String id;
  final String product;
  final double unitPrice;
  final int units;
  final String leadDirector;

  const RevenueStream({
    required this.id,
    required this.product,
    required this.unitPrice,
    required this.units,
    required this.leadDirector,
  });

  double get revenue => unitPrice * units;

  RevenueStream copyWith({double? unitPrice, int? units}) => RevenueStream(
    id: id,
    product: product,
    unitPrice: unitPrice ?? this.unitPrice,
    units: units ?? this.units,
    leadDirector: leadDirector,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'product': product,
    'unitPrice': unitPrice,
    'units': units,
    'leadDirector': leadDirector,
  };

  factory RevenueStream.fromMap(Map map) => RevenueStream(
    id: map['id'] as String,
    product: map['product'] as String,
    unitPrice: (map['unitPrice'] as num).toDouble(),
    units: (map['units'] as num).toInt(),
    leadDirector: map['leadDirector'] as String,
  );
}

/// One quarterly booking target row.
class QuarterTarget {
  final String id;
  final String quarter;
  final double bookingTarget;
  final String focus;

  const QuarterTarget({
    required this.id,
    required this.quarter,
    required this.bookingTarget,
    required this.focus,
  });

  QuarterTarget copyWith({double? bookingTarget}) => QuarterTarget(
    id: id,
    quarter: quarter,
    bookingTarget: bookingTarget ?? this.bookingTarget,
    focus: focus,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'quarter': quarter,
    'bookingTarget': bookingTarget,
    'focus': focus,
  };

  factory QuarterTarget.fromMap(Map map) => QuarterTarget(
    id: map['id'] as String,
    quarter: map['quarter'] as String,
    bookingTarget: (map['bookingTarget'] as num).toDouble(),
    focus: map['focus'] as String,
  );
}
