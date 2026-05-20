import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';

class ReportsRepository {
  ReportsRepository._();
  static final ReportsRepository instance = ReportsRepository._();

  Future<List<GetReportsReports>> fetchAllReports() async {
    final result = await DefaultConnector.instance.getReports().execute();
    return result.data.reports;
  }

  // Future<List<GetReportsReports>> fetchMyReports() async {
  //   final uid = AuthService.instance.currentUser?.uid;
  //   if (uid == null) return [];
  //   final all = await fetchAllReports();
  //   return all.where((r) => r.user.id == uid).toList()
  //     ..sort((a, b) => b.id.compareTo(a.id));
  // }

  Future<List<GetCategoriesCategories>> fetchCategories() async {
    final result = await DefaultConnector.instance.getCategories().execute();
    return result.data.categories;
  }

  Future<void> upvoteReport(String reportId) async {
    await DefaultConnector.instance.upvoteReport(reportId: reportId).execute();
  }
}
