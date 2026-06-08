import 'package:city_issues/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/widgets/app_empty.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/core/utils/user_facing_error.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.onOpenReportDetail});

  final void Function(GetReportsReports report) onOpenReportDetail;

  @override
  MyReportsScreenState createState() => MyReportsScreenState();
}

class MyReportsScreenState extends State<MyReportsScreen> {
  List<GetReportsReports>? _reports;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reports = await ReportService.instance.getMyReports();
      if (mounted) setState(() => _reports = reports);
    } catch (e) {
      if (mounted) setState(() => _error = UserFacingError.loadMyReports(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zgłoszenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież listę',
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AppLoading(message: 'Ładowanie zgłoszeń...');
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_reports == null || _reports!.isEmpty) {
      return const AppEmpty(
        title: 'Brak zgłoszeń',
        subtitle: 'Dodaj pierwsze zgłoszenie przyciskiem „Dodaj” na pasku nawigacji.',
        icon: Icons.assignment_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: ScrollPadding.list(context, includeNavBar: true).copyWith(top: 8),
        itemCount: _reports!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final report = _reports![index];
          final photoUrl = report.reportPhotos_on_report.isNotEmpty
              ? report.reportPhotos_on_report.first.imageUrl
              : null;

          return ListTile(
            leading: photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderLeading(report),
                    ),
                  )
                : _placeholderLeading(report),
            title: Text(report.category.name),
            subtitle: Text(
              report.description ?? 'Brak opisu',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ReportUtils.statusColor(report.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ReportUtils.statusLabel(report.status),
                style: TextStyle(
                  color: ReportUtils.statusColor(report.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => widget.onOpenReportDetail(report),
          );
        },
      ),
    );
  }

  Widget _placeholderLeading(GetReportsReports report) {
    return CircleAvatar(
      backgroundColor: ReportUtils.parsePinColor(report.category.pinColor).withValues(alpha: 0.2),
      child: Icon(ReportUtils.categoryIcon(report.category.iconName)),
    );
  }
}
