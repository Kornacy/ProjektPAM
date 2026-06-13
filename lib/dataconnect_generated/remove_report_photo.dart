part of 'default.dart';

class RemoveReportPhotoVariablesBuilder {
  String photoId;

  final FirebaseDataConnect _dataConnect;
  RemoveReportPhotoVariablesBuilder(this._dataConnect, {required  this.photoId,});
  Deserializer<RemoveReportPhotoData> dataDeserializer = (dynamic json)  => RemoveReportPhotoData.fromJson(jsonDecode(json));
  Serializer<RemoveReportPhotoVariables> varsSerializer = (RemoveReportPhotoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<RemoveReportPhotoData, RemoveReportPhotoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RemoveReportPhotoData, RemoveReportPhotoVariables> ref() {
    RemoveReportPhotoVariables vars= RemoveReportPhotoVariables(photoId: photoId,);
    return _dataConnect.mutation("RemoveReportPhoto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RemoveReportPhotoData {
  final int reportPhoto_deleteMany;
  RemoveReportPhotoData.fromJson(dynamic json):
  
  reportPhoto_deleteMany = nativeFromJson<int>(json['reportPhoto_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RemoveReportPhotoData otherTyped = other as RemoveReportPhotoData;
    return reportPhoto_deleteMany == otherTyped.reportPhoto_deleteMany;
    
  }
  @override
  int get hashCode => reportPhoto_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportPhoto_deleteMany'] = nativeToJson<int>(reportPhoto_deleteMany);
    return json;
  }

  RemoveReportPhotoData({
    required this.reportPhoto_deleteMany,
  });
}

@immutable
class RemoveReportPhotoVariables {
  final String photoId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RemoveReportPhotoVariables.fromJson(Map<String, dynamic> json):
  
  photoId = nativeFromJson<String>(json['photoId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RemoveReportPhotoVariables otherTyped = other as RemoveReportPhotoVariables;
    return photoId == otherTyped.photoId;
    
  }
  @override
  int get hashCode => photoId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['photoId'] = nativeToJson<String>(photoId);
    return json;
  }

  RemoveReportPhotoVariables({
    required this.photoId,
  });
}

