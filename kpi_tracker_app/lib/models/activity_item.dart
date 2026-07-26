/// A row on the Activities Plan sheet. The plan text is fixed; only
/// progress % is mutable month to month.
class ActivityItem {
  final String id;
  final String segment;
  final String majorActivity;
  final String keySubActivities;
  final String annualKpiTarget;
  final String responsible;
  final String approver;
  final int progressPct; // 0..100

  const ActivityItem({
    required this.id,
    required this.segment,
    required this.majorActivity,
    required this.keySubActivities,
    required this.annualKpiTarget,
    required this.responsible,
    required this.approver,
    this.progressPct = 0,
  });

  ActivityItem copyWith({int? progressPct}) => ActivityItem(
    id: id,
    segment: segment,
    majorActivity: majorActivity,
    keySubActivities: keySubActivities,
    annualKpiTarget: annualKpiTarget,
    responsible: responsible,
    approver: approver,
    progressPct: progressPct ?? this.progressPct,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'segment': segment,
    'majorActivity': majorActivity,
    'keySubActivities': keySubActivities,
    'annualKpiTarget': annualKpiTarget,
    'responsible': responsible,
    'approver': approver,
    'progressPct': progressPct,
  };

  factory ActivityItem.fromMap(Map map) => ActivityItem(
    id: map['id'] as String,
    segment: map['segment'] as String,
    majorActivity: map['majorActivity'] as String,
    keySubActivities: map['keySubActivities'] as String,
    annualKpiTarget: map['annualKpiTarget'] as String,
    responsible: map['responsible'] as String,
    approver: map['approver'] as String,
    progressPct: (map['progressPct'] as num).toInt(),
  );
}
