part of 'default.dart';

class AddCommentVariablesBuilder {
  String reportId;
  String content;

  final FirebaseDataConnect _dataConnect;
  AddCommentVariablesBuilder(this._dataConnect, {required  this.reportId,required  this.content,});
  Deserializer<AddCommentData> dataDeserializer = (dynamic json)  => AddCommentData.fromJson(jsonDecode(json));
  Serializer<AddCommentVariables> varsSerializer = (AddCommentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddCommentData, AddCommentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddCommentData, AddCommentVariables> ref() {
    AddCommentVariables vars= AddCommentVariables(reportId: reportId,content: content,);
    return _dataConnect.mutation("AddComment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddCommentCommentInsert {
  final String id;
  AddCommentCommentInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCommentCommentInsert otherTyped = other as AddCommentCommentInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddCommentCommentInsert({
    required this.id,
  });
}

@immutable
class AddCommentData {
  final AddCommentCommentInsert comment_insert;
  AddCommentData.fromJson(dynamic json):
  
  comment_insert = AddCommentCommentInsert.fromJson(json['comment_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCommentData otherTyped = other as AddCommentData;
    return comment_insert == otherTyped.comment_insert;
    
  }
  @override
  int get hashCode => comment_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['comment_insert'] = comment_insert.toJson();
    return json;
  }

  AddCommentData({
    required this.comment_insert,
  });
}

@immutable
class AddCommentVariables {
  final String reportId;
  final String content;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddCommentVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']),
  content = nativeFromJson<String>(json['content']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCommentVariables otherTyped = other as AddCommentVariables;
    return reportId == otherTyped.reportId && 
    content == otherTyped.content;
    
  }
  @override
  int get hashCode => Object.hashAll([reportId.hashCode, content.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    json['content'] = nativeToJson<String>(content);
    return json;
  }

  AddCommentVariables({
    required this.reportId,
    required this.content,
  });
}

