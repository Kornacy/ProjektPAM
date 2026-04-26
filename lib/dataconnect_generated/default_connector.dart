library default_connector;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'get_reports.dart';

part 'get_categories.dart';

part 'upsert_user.dart';

part 'create_report.dart';

part 'add_photo.dart';

part 'upvote_report.dart';







class DefaultConnectorConnector {
  
  
  GetReportsVariablesBuilder getReports () {
    return GetReportsVariablesBuilder(dataConnect, );
  }
  
  
  GetCategoriesVariablesBuilder getCategories () {
    return GetCategoriesVariablesBuilder(dataConnect, );
  }
  
  
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
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-central2',
    'default_connector',
    'projektpam',
  );

  DefaultConnectorConnector({required this.dataConnect});
  static DefaultConnectorConnector get instance {
    
    return DefaultConnectorConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
