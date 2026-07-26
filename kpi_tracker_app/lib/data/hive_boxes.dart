import 'package:hive_flutter/hive_flutter.dart';

/// Box name constants. Every box stores plain `Map<String, dynamic>`
/// values (no generated TypeAdapters) so the on-disk format stays easy
/// to inspect, export, and migrate.
class HiveBoxes {
  HiveBoxes._();

  static const String teamMembers = 'team_members';
  static const String weeklyEntries = 'weekly_entries';
  static const String pipelineDeals = 'pipeline_deals';
  static const String monthlyKpiActuals = 'monthly_kpi_actuals';
  static const String activityProgress = 'activity_progress';
  static const String revenueStreams = 'revenue_streams';
  static const String quarterTargets = 'quarter_targets';
  static const String appMeta = 'app_meta';

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox<Map>(teamMembers),
      Hive.openBox<Map>(weeklyEntries),
      Hive.openBox<Map>(pipelineDeals),
      Hive.openBox<Map>(monthlyKpiActuals),
      Hive.openBox<Map>(activityProgress),
      Hive.openBox<Map>(revenueStreams),
      Hive.openBox<Map>(quarterTargets),
      Hive.openBox(appMeta),
    ]);
  }
}
