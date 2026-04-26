part of 'default_connector.dart';

class UpvoteReportVariablesBuilder {
  String reportId;

  final FirebaseDataConnect _dataConnect;
  UpvoteReportVariablesBuilder(this._dataConnect, {required  this.reportId,});
  Deserializer<UpvoteReportData> dataDeserializer = (dynamic json)  => UpvoteReportData.fromJson(jsonDecode(json));
  Serializer<UpvoteReportVariables> varsSerializer = (UpvoteReportVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpvoteReportData, UpvoteReportVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpvoteReportData, UpvoteReportVariables> ref() {
    UpvoteReportVariables vars= UpvoteReportVariables(reportId: reportId,);
    return _dataConnect.mutation("UpvoteReport", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpvoteReportUpvoteInsert {
  final String id;
  UpvoteReportUpvoteInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpvoteReportUpvoteInsert otherTyped = other as UpvoteReportUpvoteInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpvoteReportUpvoteInsert({
    required this.id,
  });
}

@immutable
class UpvoteReportData {
  final UpvoteReportUpvoteInsert upvote_insert;
  UpvoteReportData.fromJson(dynamic json):
  
  upvote_insert = UpvoteReportUpvoteInsert.fromJson(json['upvote_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpvoteReportData otherTyped = other as UpvoteReportData;
    return upvote_insert == otherTyped.upvote_insert;
    
  }
  @override
  int get hashCode => upvote_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['upvote_insert'] = upvote_insert.toJson();
    return json;
  }

  UpvoteReportData({
    required this.upvote_insert,
  });
}

@immutable
class UpvoteReportVariables {
  final String reportId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpvoteReportVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpvoteReportVariables otherTyped = other as UpvoteReportVariables;
    return reportId == otherTyped.reportId;
    
  }
  @override
  int get hashCode => reportId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    return json;
  }

  UpvoteReportVariables({
    required this.reportId,
  });
}

