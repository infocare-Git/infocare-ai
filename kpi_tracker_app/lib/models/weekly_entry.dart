/// One reported week of activity for a team member, mirroring a single
/// row on the "Director X - Weekly" sheets.
class WeeklyEntry {
  final String id;
  final String memberId;
  final String weekLabel; // e.g. "Shrawan W1"
  final int leads;
  final int meetings;
  final int demos;
  final int proposals;
  final double proposalValue; // NRs.
  final double bookingsWon; // NRs.
  final double followUpsPct; // 0..1
  final int? contentPublished;
  final DateTime enteredAt;

  const WeeklyEntry({
    required this.id,
    required this.memberId,
    required this.weekLabel,
    required this.leads,
    required this.meetings,
    required this.demos,
    required this.proposals,
    required this.proposalValue,
    required this.bookingsWon,
    required this.followUpsPct,
    this.contentPublished,
    required this.enteredAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'memberId': memberId,
    'weekLabel': weekLabel,
    'leads': leads,
    'meetings': meetings,
    'demos': demos,
    'proposals': proposals,
    'proposalValue': proposalValue,
    'bookingsWon': bookingsWon,
    'followUpsPct': followUpsPct,
    'contentPublished': contentPublished,
    'enteredAt': enteredAt.toIso8601String(),
  };

  factory WeeklyEntry.fromMap(Map map) => WeeklyEntry(
    id: map['id'] as String,
    memberId: map['memberId'] as String,
    weekLabel: map['weekLabel'] as String,
    leads: (map['leads'] as num).toInt(),
    meetings: (map['meetings'] as num).toInt(),
    demos: (map['demos'] as num).toInt(),
    proposals: (map['proposals'] as num).toInt(),
    proposalValue: (map['proposalValue'] as num).toDouble(),
    bookingsWon: (map['bookingsWon'] as num).toDouble(),
    followUpsPct: (map['followUpsPct'] as num).toDouble(),
    contentPublished: map['contentPublished'] == null
        ? null
        : (map['contentPublished'] as num).toInt(),
    enteredAt: DateTime.parse(map['enteredAt'] as String),
  );
}
