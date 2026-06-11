part of 'default.dart';

class DeleteReportVariablesBuilder {
  String reportId;

  final FirebaseDataConnect _dataConnect;
  DeleteReportVariablesBuilder(this._dataConnect, {required  this.reportId,});
  Deserializer<DeleteReportData> dataDeserializer = (dynamic json)  => DeleteReportData.fromJson(jsonDecode(json));
  Serializer<DeleteReportVariables> varsSerializer = (DeleteReportVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteReportData, DeleteReportVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteReportData, DeleteReportVariables> ref() {
    DeleteReportVariables vars= DeleteReportVariables(reportId: reportId,);
    return _dataConnect.mutation("DeleteReport", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteReportData {
  final int comment_deleteMany;
  final int upvote_deleteMany;
  final int reportPhoto_deleteMany;
  final int report_deleteMany;
  DeleteReportData.fromJson(dynamic json):
  
  comment_deleteMany = nativeFromJson<int>(json['comment_deleteMany']),
  upvote_deleteMany = nativeFromJson<int>(json['upvote_deleteMany']),
  reportPhoto_deleteMany = nativeFromJson<int>(json['reportPhoto_deleteMany']),
  report_deleteMany = nativeFromJson<int>(json['report_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteReportData otherTyped = other as DeleteReportData;
    return comment_deleteMany == otherTyped.comment_deleteMany && 
    upvote_deleteMany == otherTyped.upvote_deleteMany && 
    reportPhoto_deleteMany == otherTyped.reportPhoto_deleteMany && 
    report_deleteMany == otherTyped.report_deleteMany;
    
  }
  @override
  int get hashCode => Object.hashAll([comment_deleteMany.hashCode, upvote_deleteMany.hashCode, reportPhoto_deleteMany.hashCode, report_deleteMany.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['comment_deleteMany'] = nativeToJson<int>(comment_deleteMany);
    json['upvote_deleteMany'] = nativeToJson<int>(upvote_deleteMany);
    json['reportPhoto_deleteMany'] = nativeToJson<int>(reportPhoto_deleteMany);
    json['report_deleteMany'] = nativeToJson<int>(report_deleteMany);
    return json;
  }

  DeleteReportData({
    required this.comment_deleteMany,
    required this.upvote_deleteMany,
    required this.reportPhoto_deleteMany,
    required this.report_deleteMany,
  });
}

@immutable
class DeleteReportVariables {
  final String reportId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteReportVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteReportVariables otherTyped = other as DeleteReportVariables;
    return reportId == otherTyped.reportId;
    
  }
  @override
  int get hashCode => reportId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    return json;
  }

  DeleteReportVariables({
    required this.reportId,
  });
}

