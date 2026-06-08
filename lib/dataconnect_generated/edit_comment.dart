part of 'default.dart';

class EditCommentVariablesBuilder {
  String commentId;
  String content;

  final FirebaseDataConnect _dataConnect;
  EditCommentVariablesBuilder(this._dataConnect, {required  this.commentId,required  this.content,});
  Deserializer<EditCommentData> dataDeserializer = (dynamic json)  => EditCommentData.fromJson(jsonDecode(json));
  Serializer<EditCommentVariables> varsSerializer = (EditCommentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditCommentData, EditCommentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditCommentData, EditCommentVariables> ref() {
    EditCommentVariables vars= EditCommentVariables(commentId: commentId,content: content,);
    return _dataConnect.mutation("EditComment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditCommentCommentUpdate {
  final String id;
  EditCommentCommentUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditCommentCommentUpdate otherTyped = other as EditCommentCommentUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditCommentCommentUpdate({
    required this.id,
  });
}

@immutable
class EditCommentData {
  final EditCommentCommentUpdate? comment_update;
  EditCommentData.fromJson(dynamic json):
  
  comment_update = json['comment_update'] == null ? null : EditCommentCommentUpdate.fromJson(json['comment_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditCommentData otherTyped = other as EditCommentData;
    return comment_update == otherTyped.comment_update;
    
  }
  @override
  int get hashCode => comment_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (comment_update != null) {
      json['comment_update'] = comment_update!.toJson();
    }
    return json;
  }

  EditCommentData({
    this.comment_update,
  });
}

@immutable
class EditCommentVariables {
  final String commentId;
  final String content;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditCommentVariables.fromJson(Map<String, dynamic> json):
  
  commentId = nativeFromJson<String>(json['commentId']),
  content = nativeFromJson<String>(json['content']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditCommentVariables otherTyped = other as EditCommentVariables;
    return commentId == otherTyped.commentId && 
    content == otherTyped.content;
    
  }
  @override
  int get hashCode => Object.hashAll([commentId.hashCode, content.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['commentId'] = nativeToJson<String>(commentId);
    json['content'] = nativeToJson<String>(content);
    return json;
  }

  EditCommentVariables({
    required this.commentId,
    required this.content,
  });
}

