import '../models/activity_item.dart';
import '../models/annual_target.dart';
import '../models/monthly_kpi.dart';
import '../models/team_member.dart';

/// Default data seeded on first launch, taken directly from the
/// InfoCare Weekly KPI Tracker FY 2083/84 workbook (Read Me + Annual
/// Targets + Activities Plan + Monthly KPI Dashboard sheets).
class SeedData {
  SeedData._();

  static const String directorAId = 'director-a';
  static const String directorBId = 'director-b';

  static List<TeamMember> defaultTeamMembers() => [
    const TeamMember(
      id: directorAId,
      name: 'Director A',
      role: TeamRole.director,
      segment: 'Government (B2G)',
      targets: WeeklyTargets(
        leads: 4,
        meetings: 4,
        demos: 2,
        proposals: 1,
        bookings: 1030000,
        followUpsPct: 1.0,
      ),
    ),
    const TeamMember(
      id: directorBId,
      name: 'Director B',
      role: TeamRole.director,
      segment: 'Commercial (B2B) + Marketing',
      targets: WeeklyTargets(
        leads: 4,
        meetings: 6,
        demos: 3,
        proposals: 2,
        bookings: 130000,
        followUpsPct: 1.0,
        content: 2,
      ),
    ),
  ];

  static const double annualGoal = 60000000;

  static List<MonthlyKpiDefinition> monthlyKpiDefinitions() => const [
    MonthlyKpiDefinition(
      id: 'bookings_vs_plan',
      name: 'Total bookings vs plan',
      formula: 'Cumulative signed value / cumulative target',
      targetGoalLabel: '≥ 100%',
      redFlagLabel: '< 85%',
      owner: 'Joint',
      targetThreshold: 1.0,
      redThreshold: 0.85,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    ),
    MonthlyKpiDefinition(
      id: 'pipeline_coverage',
      name: 'Weighted pipeline coverage',
      formula: 'Σ(value × probability) / remaining target',
      targetGoalLabel: '≥ 3×',
      redFlagLabel: '< 2×',
      owner: 'Each',
      targetThreshold: 3.0,
      redThreshold: 2.0,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.multiplier,
    ),
    MonthlyKpiDefinition(
      id: 'demo_to_proposal',
      name: 'Demo-to-proposal rate',
      formula: 'Proposals / demos',
      targetGoalLabel: '≥ 60%',
      redFlagLabel: '< 40%',
      owner: 'Each',
      targetThreshold: 0.6,
      redThreshold: 0.4,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    ),
    MonthlyKpiDefinition(
      id: 'proposal_win_rate',
      name: 'Proposal win rate',
      formula: 'Won / proposals decided',
      targetGoalLabel: '≥ 40%',
      redFlagLabel: '< 25%',
      owner: 'Each',
      targetThreshold: 0.4,
      redThreshold: 0.25,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    ),
    MonthlyKpiDefinition(
      id: 'sales_cycle_b2g',
      name: 'Avg sales cycle (B2G)',
      formula: 'Lead date → contract date',
      targetGoalLabel: '≤ 120 days',
      redFlagLabel: '> 180 days',
      owner: 'Director A',
      targetThreshold: 120,
      redThreshold: 180,
      direction: KpiDirection.lowerIsBetter,
      unit: KpiUnit.days,
    ),
    MonthlyKpiDefinition(
      id: 'sales_cycle_b2b',
      name: 'Avg sales cycle (B2B)',
      formula: 'Lead date → contract date',
      targetGoalLabel: '≤ 30 days',
      redFlagLabel: '> 60 days',
      owner: 'Director B',
      targetThreshold: 30,
      redThreshold: 60,
      direction: KpiDirection.lowerIsBetter,
      unit: KpiUnit.days,
    ),
    MonthlyKpiDefinition(
      id: 'cross_sell_attach',
      name: 'Cross-sell attach rate',
      formula: 'Cross-sells / eligible clients',
      targetGoalLabel: '≥ 50%',
      redFlagLabel: '< 30%',
      owner: 'Director A',
      targetThreshold: 0.5,
      redThreshold: 0.3,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    ),
    MonthlyKpiDefinition(
      id: 'inbound_inquiries',
      name: 'Inbound inquiries/month',
      formula: 'Website + social forms',
      targetGoalLabel: '50',
      redFlagLabel: '< 20',
      owner: 'Director B',
      targetThreshold: 50,
      redThreshold: 20,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.count,
    ),
    MonthlyKpiDefinition(
      id: 'collections_vs_bookings',
      name: 'Collections vs bookings',
      formula: 'Cash received / invoiced',
      targetGoalLabel: '≥ 80%',
      redFlagLabel: '< 60%',
      owner: 'Director B',
      targetThreshold: 0.8,
      redThreshold: 0.6,
      direction: KpiDirection.higherIsBetter,
      unit: KpiUnit.percent,
    ),
  ];

  static List<ActivityItem> defaultActivities() => const [
    ActivityItem(
      id: 'act-1',
      segment: 'Govt. Sales',
      majorActivity: 'Palika pipeline building',
      keySubActivities:
          'Build list of 60 Palikas; collect CAO/Mayor contacts via NARMIN & MuAN',
      annualKpiTarget:
          '60 Palikas listed (Shrawan); 40 first meetings (Kartik)',
      responsible: 'Director A',
      approver: 'Director A',
    ),
    ActivityItem(
      id: 'act-2',
      segment: 'Govt. Sales',
      majorActivity: 'Demo & proposal engine',
      keySubActivities: 'Standardize scripts; 48-hour proposal turnaround rule',
      annualKpiTarget: '36 demos; 24 proposals; win rate ≥ 40%',
      responsible: 'Director A',
      approver: 'Director A',
    ),
    ActivityItem(
      id: 'act-3',
      segment: 'Govt. Sales',
      majorActivity: 'Tender participation (e-GP)',
      keySubActivities: 'Daily PPMO monitoring; bid/no-bid checklist',
      annualKpiTarget: 'Bid on 12 tenders; win 4',
      responsible: 'Director A',
      approver: 'Director A',
    ),
    ActivityItem(
      id: 'act-4',
      segment: 'Govt. Sales',
      majorActivity: 'Federal & provincial outreach',
      keySubActivities:
          'Map 10 target ministries; pilot proposal for 1 free 60-day pilot',
      annualKpiTarget:
          '2 paid contracts (80 Lakh); Q2 gate decision documented',
      responsible: 'Director A',
      approver: 'Joint',
    ),
    ActivityItem(
      id: 'act-5',
      segment: 'Govt. Sales',
      majorActivity: 'Cross-sell to existing Palikas',
      keySubActivities: "Offer Mayor's Dashboard within 60 days of go-live",
      annualKpiTarget: '10 cross-sell closes; attach rate ≥ 50%',
      responsible: 'Director A',
      approver: 'Director A',
    ),
    ActivityItem(
      id: 'act-6',
      segment: 'Commercial Sales',
      majorActivity: 'Restaurant pipeline',
      keySubActivities:
          'List 150 chain/franchise restaurants (KTM/Pokhara); walk-in outreach',
      annualKpiTarget: '150 listed; 90 contacted; 50 demos',
      responsible: 'Director B',
      approver: 'Director B',
    ),
    ActivityItem(
      id: 'act-7',
      segment: 'Commercial Sales',
      majorActivity: 'Demo-to-close system',
      keySubActivities: '15-min live demo; 14-day free trial; 7-day onboarding',
      annualKpiTarget: '33 paying outlets; trial-to-paid conversion ≥ 50%',
      responsible: 'Director B',
      approver: 'Director B',
    ),
    ActivityItem(
      id: 'act-8',
      segment: 'Marketing Engine',
      majorActivity: 'Content & product videos',
      keySubActivities: 'Product demo video per product; monthly case studies',
      annualKpiTarget: '7 product videos live by Ashwin; 24 case studies',
      responsible: 'Director B',
      approver: 'Director B',
    ),
    ActivityItem(
      id: 'act-9',
      segment: 'Marketing Engine',
      majorActivity: 'Digital presence',
      keySubActivities: 'Website refresh; LinkedIn/FB cadence; Google profile',
      annualKpiTarget: '2 posts/week; 600 inbound inquiries/year',
      responsible: 'Director B',
      approver: 'Director B',
    ),
    ActivityItem(
      id: 'act-10',
      segment: 'Marketing Engine',
      majorActivity: 'Sales collateral',
      keySubActivities: 'One-page Nepali brochures; testimonial bank',
      annualKpiTarget: 'All 7 brochures ready by end of Bhadra',
      responsible: 'Director B',
      approver: 'Director B',
    ),
  ];

  static List<RevenueStream> defaultRevenueStreams() => const [
    RevenueStream(
      id: 'rev-1',
      product: 'Citizen Service Delivery Platform',
      unitPrice: 1500000,
      units: 16,
      leadDirector: 'Director A (Gov)',
    ),
    RevenueStream(
      id: 'rev-2',
      product: "Mayor's Dashboard (Gov. Intelligence) — cross-sell",
      unitPrice: 600000,
      units: 12,
      leadDirector: 'Director A (Gov)',
    ),
    RevenueStream(
      id: 'rev-3',
      product: 'Agriculture MIS + eCommerce',
      unitPrice: 1200000,
      units: 6,
      leadDirector: 'Director A (Gov)',
    ),
    RevenueStream(
      id: 'rev-4',
      product: 'Data Portal (Gov + NGO SaaS)',
      unitPrice: 1000000,
      units: 7,
      leadDirector: 'Director A (Gov)',
    ),
    RevenueStream(
      id: 'rev-5',
      product: 'Gov. Knowledge Layer (Federal/Provincial)',
      unitPrice: 4000000,
      units: 2,
      leadDirector: 'Director A (Gov)',
    ),
    RevenueStream(
      id: 'rev-6',
      product: 'RestroAxis (setup + annual subscription)',
      unitPrice: 200000,
      units: 33,
      leadDirector: 'Director B (Comm.)',
    ),
  ];

  static List<QuarterTarget> defaultQuarterTargets() => const [
    QuarterTarget(
      id: 'q1',
      quarter: 'Q1 (Shrawan–Ashwin)',
      bookingTarget: 7000000,
      focus: 'Pipeline build, collateral, first RestroAxis closes',
    ),
    QuarterTarget(
      id: 'q2',
      quarter: 'Q2 (Kartik–Poush)',
      bookingTarget: 14000000,
      focus:
          'First Palika closes, Gov. Knowledge Layer gate decision, tender wins',
    ),
    QuarterTarget(
      id: 'q3',
      quarter: 'Q3 (Magh–Chaitra)',
      bookingTarget: 18500000,
      focus: 'Peak Palika closing (budget planning season), cross-sells',
    ),
    QuarterTarget(
      id: 'q4',
      quarter: 'Q4 (Baishakh–Ashadh)',
      bookingTarget: 20500000,
      focus: 'Ashadh-end government spending push; federal contracts',
    ),
  ];
}
