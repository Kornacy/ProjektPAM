library default_connector;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'upsert_user.dart';

part 'create_report.dart';

part 'add_photo.dart';

part 'upvote_report.dart';

part 'get_reports.dart';

part 'get_active_reports.dart';

part 'get_my_reports.dart';

part 'get_categories.dart';







class DefaultConnector {
  
  
  UpsertUserVariablesBuilder upsertUser ({required String email, }) {
    return UpsertUserVariablesBuilder(dataConnect, email: email,);
  }
  
  
  CreateReportVariablesBuilder createReport ({required String category, required double lat, required double lng, }) {
    return CreateReportVariablesBuilder(dataConnect, category: category,lat: lat,lng: lng,);
  }
  
  
  AddPhotoVariablesBuilder addPhoto ({required String reportId, required String url, }) {
    return AddPhotoVariablesBuilder(dataConnect, reportId: reportId,url: url,);
  }
  
  
  UpvoteReportVariablesBuilder upvoteReport ({required String reportId, }) {
    return UpvoteReportVariablesBuilder(dataConnect, reportId: reportId,);
  }
  
  
  GetReportsVariablesBuilder getReports () {
    return GetReportsVariablesBuilder(dataConnect, );
  }
  
  
  GetActiveReportsVariablesBuilder getActiveReports () {
    return GetActiveReportsVariablesBuilder(dataConnect, );
  }
  
  
  GetMyReportsVariablesBuilder getMyReports () {
    return GetMyReportsVariablesBuilder(dataConnect, );
  }
  
  
  GetCategoriesVariablesBuilder getCategories () {
    return GetCategoriesVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-central2',
    'default',
    'projektpam',
  );

  DefaultConnector({required this.dataConnect});
  static DefaultConnector get instance {
    
    return DefaultConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
