part of 'default_connector.dart';

class AddPhotoVariablesBuilder {
  String reportId;
  String url;

  final FirebaseDataConnect _dataConnect;
  AddPhotoVariablesBuilder(this._dataConnect, {required  this.reportId,required  this.url,});
  Deserializer<AddPhotoData> dataDeserializer = (dynamic json)  => AddPhotoData.fromJson(jsonDecode(json));
  Serializer<AddPhotoVariables> varsSerializer = (AddPhotoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddPhotoData, AddPhotoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddPhotoData, AddPhotoVariables> ref() {
    AddPhotoVariables vars= AddPhotoVariables(reportId: reportId,url: url,);
    return _dataConnect.mutation("AddPhoto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddPhotoReportPhotoInsert {
  final String id;
  AddPhotoReportPhotoInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPhotoReportPhotoInsert otherTyped = other as AddPhotoReportPhotoInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddPhotoReportPhotoInsert({
    required this.id,
  });
}

@immutable
class AddPhotoData {
  final AddPhotoReportPhotoInsert reportPhoto_insert;
  AddPhotoData.fromJson(dynamic json):
  
  reportPhoto_insert = AddPhotoReportPhotoInsert.fromJson(json['reportPhoto_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPhotoData otherTyped = other as AddPhotoData;
    return reportPhoto_insert == otherTyped.reportPhoto_insert;
    
  }
  @override
  int get hashCode => reportPhoto_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportPhoto_insert'] = reportPhoto_insert.toJson();
    return json;
  }

  AddPhotoData({
    required this.reportPhoto_insert,
  });
}

@immutable
class AddPhotoVariables {
  final String reportId;
  final String url;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddPhotoVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']),
  url = nativeFromJson<String>(json['url']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPhotoVariables otherTyped = other as AddPhotoVariables;
    return reportId == otherTyped.reportId && 
    url == otherTyped.url;
    
  }
  @override
  int get hashCode => Object.hashAll([reportId.hashCode, url.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    json['url'] = nativeToJson<String>(url);
    return json;
  }

  AddPhotoVariables({
    required this.reportId,
    required this.url,
  });
}

