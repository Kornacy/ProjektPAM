import 'package:flutter/material.dart';
import 'package:city_issues/features/map/screens/map_screen.dart';
import 'package:city_issues/features/reports/screens/create_report_screen.dart';
import 'package:city_issues/features/reports/screens/my_reports_screen.dart';
import 'package:city_issues/features/settings/screens/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _stackIndex = 0;
  final _mapKey = GlobalKey<MapScreenState>();
  final _myReportsKey = GlobalKey<MyReportsScreenState>();

  int get _navIndex => _stackIndex == 2 ? 3 : _stackIndex;

  Future<void> _openCreateReport() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateReportScreen()),
    );
    if (created == true) {
      _mapKey.currentState?.refreshReports();
      _myReportsKey.currentState?.refresh();
      setState(() => _stackIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          MapScreen(key: _mapKey),
          MyReportsScreen(key: _myReportsKey),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _openCreateReport();
            return;
          }
          setState(() => _stackIndex = index == 3 ? 2 : index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Moje',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Dodaj',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ustawienia',
          ),
        ],
      ),
    );
  }
}
