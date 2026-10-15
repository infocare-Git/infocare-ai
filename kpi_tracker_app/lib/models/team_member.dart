enum TeamRole { director, salesRep, admin }

TeamRole roleFromString(String value) {
  return TeamRole.values.firstWhere(
    (r) => r.name == value,
    orElse: () => TeamRole.salesRep,
  );
}

/// The weekly targets assigned to a team member, mirroring the
/// "WEEKLY TARGET →" row on each director's sheet in the source workbook.
class WeeklyTargets {
  final int leads;
  final int meetings;
  final int demos;
  final int proposals;
  final double bookings; // NRs. pace per week
  final double followUpsPct; // 0..1
  final int? content; // null when content publishing isn't tracked

  const WeeklyTargets({
    required this.leads,
    required this.meetings,
    required this.demos,
    required this.proposals,
    required this.bookings,
    required this.followUpsPct,
    this.content,
  });

  Map<String, dynamic> toMap() => {
    'leads': leads,
    'meetings': meetings,
    'demos': demos,
    'proposals': proposals,
    'bookings': bookings,
    'followUpsPct': followUpsPct,
    'content': content,
  };

  factory WeeklyTargets.fromMap(Map map) => WeeklyTargets(
    leads: (map['leads'] as num).toInt(),
    meetings: (map['meetings'] as num).toInt(),
    demos: (map['demos'] as num).toInt(),
    proposals: (map['proposals'] as num).toInt(),
    bookings: (map['bookings'] as num).toDouble(),
    followUpsPct: (map['followUpsPct'] as num).toDouble(),
    content: map['content'] == null ? null : (map['content'] as num).toInt(),
  );

  WeeklyTargets copyWith({
    int? leads,
    int? meetings,
    int? demos,
    int? proposals,
    double? bookings,
    double? followUpsPct,
    int? content,
    bool clearContent = false,
  }) {
    return WeeklyTargets(
      leads: leads ?? this.leads,
      meetings: meetings ?? this.meetings,
      demos: demos ?? this.demos,
      proposals: proposals ?? this.proposals,
      bookings: bookings ?? this.bookings,
      followUpsPct: followUpsPct ?? this.followUpsPct,
      content: clearContent ? null : (content ?? this.content),
    );
  }
}

/// A Director or Sales Team member who reports weekly activity against
/// their own assigned targets.
class TeamMember {
  final String id;
  final String name;
  final TeamRole role;
  final String segment; // e.g. "Government (B2G)", "Commercial (B2B)"
  final WeeklyTargets targets;
  final bool active;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.segment,
    required this.targets,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'role': role.name,
    'segment': segment,
    'targets': targets.toMap(),
    'active': active,
  };

  factory TeamMember.fromMap(Map map) => TeamMember(
    id: map['id'] as String,
    name: map['name'] as String,
    role: roleFromString(map['role'] as String),
    segment: map['segment'] as String,
    targets: WeeklyTargets.fromMap(
      Map<String, dynamic>.from(map['targets'] as Map),
    ),
    active: map['active'] as bool? ?? true,
  );

  TeamMember copyWith({
    String? name,
    TeamRole? role,
    String? segment,
    WeeklyTargets? targets,
    bool? active,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      segment: segment ?? this.segment,
      targets: targets ?? this.targets,
      active: active ?? this.active,
    );
  }
}
