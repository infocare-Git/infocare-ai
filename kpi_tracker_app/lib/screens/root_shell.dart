import 'package:flutter/material.dart';

import 'activities_screen.dart';
import 'annual_targets_screen.dart';
import 'home_screen.dart';
import 'monthly_dashboard_screen.dart';
import 'more_screen.dart';
import 'pipeline_screen.dart';
import 'weekly_entry_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    WeeklyEntryScreen(),
    PipelineScreen(),
    _InsightsTabs(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'My Week',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Pipeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _InsightsTabs extends StatelessWidget {
  const _InsightsTabs();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Insights'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monthly KPIs'),
              Tab(text: 'Activities'),
              Tab(text: 'Annual Targets'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MonthlyDashboardScreen(),
            ActivitiesScreen(),
            AnnualTargetsScreen(),
          ],
        ),
      ),
    );
  }
}
