import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kpi_tracker/screens/onboarding_screen.dart';
import 'package:kpi_tracker/screens/root_shell.dart';
import 'package:kpi_tracker/state/app_state.dart';
import 'package:provider/provider.dart';

/// Hive does real file I/O, which hangs under testWidgets' fake-async zone
/// unless it runs inside tester.runAsync. Only that real I/O goes inside
/// runAsync — pumpWidget/tap/pump stay in the normal test zone, since
/// wrapping frame-pumping itself in runAsync can deadlock.
Future<AppState> _initAppState(WidgetTester tester, Directory tempDir) async {
  final appState = AppState();
  await tester.runAsync(() async {
    Hive.init(tempDir.path);
    await appState.init();
  });
  return appState;
}

Widget _wrap(AppState appState, Widget child) {
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('onboarding lists the seeded Director A and Director B profiles', (
    tester,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('kpi_tracker_test_');
    final appState = await _initAppState(tester, tempDir);

    await tester.pumpWidget(_wrap(appState, const OnboardingScreen()));
    await tester.pump();

    expect(find.text('Director A'), findsOneWidget);
    expect(find.text('Director B'), findsOneWidget);
  });

  testWidgets('picking Director A reveals the bottom nav with My Week', (
    tester,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('kpi_tracker_test_');
    final appState = await _initAppState(tester, tempDir);
    appState.setActiveMember('director-a');

    await tester.pumpWidget(_wrap(appState, const RootShell()));
    await tester.pump();

    expect(find.text('InfoCare KPI Tracker'), findsOneWidget);
    expect(find.text('My Week'), findsOneWidget);

    await tester.tap(find.text('My Week'));
    await tester.pump();

    expect(find.text('My Week — Director A'), findsOneWidget);
  });
}
