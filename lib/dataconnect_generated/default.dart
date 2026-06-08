library default_connector;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'upsert_user.dart';

part 'create_report.dart';

part 'add_photo.dart';

part 'upvote_report.dart';

part 'remove_upvote.dart';

part 'add_comment.dart';

part 'edit_comment.dart';

part 'delete_comment.dart';

part 'get_reports.dart';

part 'get_active_reports.dart';

part 'get_my_reports.dart';

part 'get_categories.dart';

part 'get_report_comments.dart';







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
  
  
  RemoveUpvoteVariablesBuilder removeUpvote ({required String reportId, }) {
    return RemoveUpvoteVariablesBuilder(dataConnect, reportId: reportId,);
  }
  
  
  AddCommentVariablesBuilder addComment ({required String reportId, required String content, }) {
    return AddCommentVariablesBuilder(dataConnect, reportId: reportId,content: content,);
  }
  
  
  EditCommentVariablesBuilder editComment ({required String commentId, required String content, }) {
    return EditCommentVariablesBuilder(dataConnect, commentId: commentId,content: content,);
  }
  
  
  DeleteCommentVariablesBuilder deleteComment ({required String commentId, }) {
    return DeleteCommentVariablesBuilder(dataConnect, commentId: commentId,);
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
  
  
  GetReportCommentsVariablesBuilder getReportComments ({required String reportId, }) {
    return GetReportCommentsVariablesBuilder(dataConnect, reportId: reportId,);
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
