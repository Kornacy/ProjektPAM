import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/screens/map_screen.dart';
import 'package:city_issues/features/onboarding/onboarding_screen.dart';
import 'package:city_issues/features/reports/screens/create_report_screen.dart';
import 'package:city_issues/features/reports/screens/my_reports_screen.dart';
import 'package:city_issues/features/reports/screens/report_detail_screen.dart';
import 'package:city_issues/features/settings/screens/settings_screen.dart';
import 'package:city_issues/services/app_preferences.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

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

  void openReportDetail(GetReportsReports report) {
    _shellNavigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/report-detail'),
        builder: (_) => ReportDetailScreen(
          report: report,
          onBack: () => _shellNavigatorKey.currentState?.pop(),
        ),
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

  Widget _buildMainTabs() {
    return IndexedStack(
      index: _stackIndex,
      children: [
        MapScreen(
          key: _mapKey,
          onOpenReportDetail: openReportDetail,
        ),
        MyReportsScreen(
          key: _myReportsKey,
          onOpenReportDetail: openReportDetail,
        ),
        SettingsScreen(onShowOnboarding: () => openOnboarding(replay: true)),
        CreateReportScreen(
          key: ValueKey(_createInitialLocation),
          initialLocation: _createInitialLocation,
          embedded: true,
          onClose: _closeCreateReport,
          onSubmitted: () => _closeCreateReport(submitted: true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _shellNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => _buildMainTabs(),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          if (_shellNavigatorKey.currentState?.canPop() == true) {
            _shellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          }
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
