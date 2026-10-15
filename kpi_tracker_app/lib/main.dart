import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final appState = AppState();
  await appState.init();
  runApp(KpiTrackerApp(appState: appState));
}

class KpiTrackerApp extends StatelessWidget {
  final AppState appState;

  const KpiTrackerApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0B5FFF);
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        title: 'InfoCare KPI Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.activeMember == null) {
      return const OnboardingScreen();
    }
    return const RootShell();
  }
}
