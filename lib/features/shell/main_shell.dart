import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/screens/map_screen.dart';
import 'package:city_issues/features/onboarding/app_tour.dart';
import 'package:city_issues/features/reports/screens/edit_report_screen.dart';
import 'package:city_issues/features/reports/screens/create_report_screen.dart';
import 'package:city_issues/features/reports/screens/my_reports_screen.dart';
import 'package:city_issues/features/reports/screens/report_detail_screen.dart';
import 'package:city_issues/features/settings/screens/settings_screen.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/report_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  final _navBarKey = GlobalKey();
  final _mapFiltersKey = GlobalKey();
  final _mapFabKey = GlobalKey();
  final _settingsHelpKey = GlobalKey();
  final _settingsScrollController = ScrollController();

  int _stackIndex = 0;
  int _lastMainTab = 0;
  int _createReportSession = 0;
  LatLng? _createInitialLocation;

  final _mapKey = GlobalKey<MapScreenState>();
  final _myReportsKey = GlobalKey<MyReportsScreenState>();

  bool _tourVisible = false;
  bool _tourReplay = false;
  int _tourStep = 0;
  late final List<AppTourStep> _tourSteps = AppTourSteps.build(
    mapFiltersKey: _mapFiltersKey,
    mapFabKey: _mapFabKey,
    settingsHelpKey: _settingsHelpKey,
  );

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

  @override
  void dispose() {
    _settingsScrollController.dispose();
    super.dispose();
  }

  Future<void> _maybeShowOnboarding() async {
    if (!mounted) return;
    if (!AppPreferences.instance.hasCompletedOnboarding) {
      _startTour();
    }
  }

  void openOnboarding({bool replay = true}) {
    _startTour(replay: replay);
  }

  void _startTour({bool replay = false}) {
    setState(() {
      _tourVisible = true;
      _tourReplay = replay;
      _tourStep = 0;
      _stackIndex = 0;
      _createInitialLocation = null;
    });
    _applyTourStep(0);
  }

  Future<void> _applyTourStep(int step) async {
    final target = _tourSteps[step];
    setState(() {
      _tourStep = step;
      _stackIndex = target.stackIndex;
      if (_stackIndex != 3) _createInitialLocation = null;
    });

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (target.targetKey == _settingsHelpKey) {
      final helpContext = _settingsHelpKey.currentContext;
      if (helpContext != null && helpContext.mounted) {
        await Scrollable.ensureVisible(
          helpContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: 0.3,
        );
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _nextTourStep() async {
    if (_tourStep >= _tourSteps.length - 1) {
      await _finishTour();
      return;
    }
    await _applyTourStep(_tourStep + 1);
  }

  Future<void> _finishTour() async {
    if (!_tourReplay) {
      await AppPreferences.instance.setOnboardingCompleted();
    }
    if (mounted) {
      setState(() => _tourVisible = false);
    }
  }

  void _refreshReportData() {
    _mapKey.currentState?.refreshReports(forceRefresh: true);
    _myReportsKey.currentState?.refresh();
  }

  Future<bool> _resolveCanManage(String reportId, {bool? canManage}) async {
    if (canManage != null) return canManage;
    if (!AuthService.instance.isSignedIn) return false;
    return ReportService.instance.isOwnReport(reportId);
  }

  Future<void> openReportDetail(
    GetReportsReports report, {
    bool? canManage,
  }) async {
    final manage = await _resolveCanManage(report.id, canManage: canManage);
    if (!mounted) return;

    _shellNavigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/report-detail'),
        builder: (_) => ReportDetailScreen(
          report: report,
          canManage: manage,
          onBack: () => _shellNavigatorKey.currentState?.pop(),
          onEdit: manage ? () => _openEditReport(report) : null,
          onDeleted: manage
              ? () {
                  _shellNavigatorKey.currentState?.pop(true);
                  _refreshReportData();
                }
              : null,
        ),
      ),
    ).then((deleted) {
      if (deleted == true && manage) {
        _refreshReportData();
      }
    });
  }

  void _openEditReport(GetReportsReports report) {
    _shellNavigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/report-edit'),
        builder: (_) => EditReportScreen(report: report),
      ),
    ).then((saved) {
      if (saved == true) {
        _refreshReportData();
        _shellNavigatorKey.currentState?.popUntil(
          (route) => route.settings.name != '/report-detail',
        );
      }
    });
  }

  void openReportDetailFromMyReports(GetReportsReports report) {
    openReportDetail(report, canManage: true);
  }

  void _openCreateReport({LatLng? initialLocation}) {
    if (_stackIndex != 3) _lastMainTab = _stackIndex;
    setState(() {
      _createInitialLocation = initialLocation;
      _createReportSession++;
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

  void _handleSystemBack() {
    if (_tourVisible) {
      _finishTour();
      return;
    }

    if (_mapKey.currentState?.closeReportSheetIfOpen() ?? false) {
      return;
    }

    final shell = _shellNavigatorKey.currentState;
    if (shell != null && shell.canPop()) {
      shell.pop();
      return;
    }

    final rootNav = Navigator.of(context, rootNavigator: true);
    if (rootNav.canPop()) {
      rootNav.pop();
      return;
    }

    if (_stackIndex == 3) {
      _closeCreateReport();
      return;
    }

    if (_stackIndex != 0) {
      setState(() {
        _stackIndex = 0;
        _createInitialLocation = null;
      });
      return;
    }

    SystemNavigator.pop();
  }

  Widget _buildMainTabs() {
    return IndexedStack(
      index: _stackIndex,
      children: [
        MapScreen(
          key: _mapKey,
          onOpenReportDetail: openReportDetail,
          filtersKey: _mapFiltersKey,
          locationFabKey: _mapFabKey,
        ),
        MyReportsScreen(
          key: _myReportsKey,
          onOpenReportDetail: openReportDetailFromMyReports,
          onEditReport: _openEditReport,
          onReportDeleted: _refreshReportData,
        ),
        SettingsScreen(
          onShowOnboarding: () => openOnboarding(replay: true),
          onboardingHelpKey: _settingsHelpKey,
          scrollController: _settingsScrollController,
        ),
        CreateReportScreen(
          key: ValueKey(_createReportSession),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Stack(
        children: [
          Scaffold(
          body: Navigator(
            key: _shellNavigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => _buildMainTabs(),
              );
            },
          ),
          bottomNavigationBar: NavigationBar(
            key: _navBarKey,
            selectedIndex: _navIndex,
            onDestinationSelected: (index) {
              if (_tourVisible) return;
              if (_shellNavigatorKey.currentState?.canPop() == true) {
                _shellNavigatorKey.currentState
                    ?.popUntil((route) => route.isFirst);
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
        ),
        if (_tourVisible)
          Positioned.fill(
            child: AppTourOverlay(
              step: _tourSteps[_tourStep],
              stepIndex: _tourStep,
              stepCount: _tourSteps.length,
              navBarKey: _navBarKey,
              isLast: _tourStep == _tourSteps.length - 1,
              isReplay: _tourReplay,
              onNext: _nextTourStep,
              onSkip: _finishTour,
            ),
          ),
      ],
    ),
    );
  }
}
