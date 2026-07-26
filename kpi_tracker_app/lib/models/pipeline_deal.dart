const List<String> pipelineStages = [
  'Lead',
  'Meeting Scheduled',
  'Demo / Trial Running',
  'Proposal Sent',
  'Pilot Discussion',
  'Negotiation',
  'Won',
  'Lost',
];

/// One deal row on the Live Pipeline sheet.
class PipelineDeal {
  final String id;
  final String clientName;
  final String product;
  final double dealValue; // NRs.
  final String stage;
  final double winProbabilityPct; // 0..1
  final String expectedClose; // free text, e.g. "Mangsir W3"
  final String dealOwner;

  const PipelineDeal({
    required this.id,
    required this.clientName,
    required this.product,
    required this.dealValue,
    required this.stage,
    required this.winProbabilityPct,
    required this.expectedClose,
    required this.dealOwner,
  });

  double get weightedValue => dealValue * winProbabilityPct;

  bool get isOpen => stage != 'Won' && stage != 'Lost';

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientName': clientName,
    'product': product,
    'dealValue': dealValue,
    'stage': stage,
    'winProbabilityPct': winProbabilityPct,
    'expectedClose': expectedClose,
    'dealOwner': dealOwner,
  };

  factory PipelineDeal.fromMap(Map map) => PipelineDeal(
    id: map['id'] as String,
    clientName: map['clientName'] as String,
    product: map['product'] as String,
    dealValue: (map['dealValue'] as num).toDouble(),
    stage: map['stage'] as String,
    winProbabilityPct: (map['winProbabilityPct'] as num).toDouble(),
    expectedClose: map['expectedClose'] as String,
    dealOwner: map['dealOwner'] as String,
  );
}
