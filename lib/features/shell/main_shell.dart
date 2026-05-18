import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/features/map/screens/map_screen.dart';
import 'package:city_issues/features/onboarding/onboarding_screen.dart';
import 'package:city_issues/features/reports/screens/create_report_screen.dart';
import 'package:city_issues/features/reports/screens/my_reports_screen.dart';
import 'package:city_issues/features/settings/screens/settings_screen.dart';
import 'package:city_issues/services/app_preferences.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// 0 mapa, 1 moje, 2 profil, 3 formularz (bez osobnej zakładki)
  int _stackIndex = 0;
  int _lastMainTab = 0;
  LatLng? _createInitialLocation;

  final _mapKey = GlobalKey<MapScreenState>();
  final _myReportsKey = GlobalKey<MyReportsScreenState>();

  int get _navIndex {
    if (_stackIndex == 3) return 2;
    if (_stackIndex == 2) return 3;
    return _stackIndex;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  Future<void> _maybeShowOnboarding() async {
    if (!mounted) return;
    if (!AppPreferences.instance.hasCompletedOnboarding) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  void openOnboarding({bool replay = true}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingScreen(replay: replay),
      ),
    );
  }

  void _openCreateReport({LatLng? initialLocation}) {
    if (_stackIndex != 3) _lastMainTab = _stackIndex;
    setState(() {
      _createInitialLocation = initialLocation;
      _stackIndex = 3;
    });
  }

  void _closeCreateReport({bool submitted = false}) {
    setState(() {
      _stackIndex = submitted ? 0 : _lastMainTab;
      _createInitialLocation = null;
    });
    if (submitted) {
      _mapKey.currentState?.refreshReports();
      _myReportsKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          MapScreen(
            key: _mapKey,
            onCreateReportAt: (loc) => _openCreateReport(initialLocation: loc),
          ),
          MyReportsScreen(key: _myReportsKey),
          SettingsScreen(onShowOnboarding: () => openOnboarding(replay: true)),
          CreateReportScreen(
            key: ValueKey(_createInitialLocation),
            initialLocation: _createInitialLocation,
            embedded: true,
            onClose: _closeCreateReport,
            onSubmitted: () => _closeCreateReport(submitted: true),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _openCreateReport();
            return;
          }
          setState(() {
            _stackIndex = index == 3 ? 2 : index;
            if (_stackIndex != 3) _createInitialLocation = null;
          });
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
