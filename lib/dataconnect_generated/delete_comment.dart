part of 'default.dart';

class DeleteCommentVariablesBuilder {
  String commentId;

  final FirebaseDataConnect _dataConnect;
  DeleteCommentVariablesBuilder(this._dataConnect, {required  this.commentId,});
  Deserializer<DeleteCommentData> dataDeserializer = (dynamic json)  => DeleteCommentData.fromJson(jsonDecode(json));
  Serializer<DeleteCommentVariables> varsSerializer = (DeleteCommentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteCommentData, DeleteCommentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteCommentData, DeleteCommentVariables> ref() {
    DeleteCommentVariables vars= DeleteCommentVariables(commentId: commentId,);
    return _dataConnect.mutation("DeleteComment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteCommentCommentDelete {
  final String id;
  DeleteCommentCommentDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCommentCommentDelete otherTyped = other as DeleteCommentCommentDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteCommentCommentDelete({
    required this.id,
  });
}

@immutable
class DeleteCommentData {
  final DeleteCommentCommentDelete? comment_delete;
  DeleteCommentData.fromJson(dynamic json):
  
  comment_delete = json['comment_delete'] == null ? null : DeleteCommentCommentDelete.fromJson(json['comment_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCommentData otherTyped = other as DeleteCommentData;
    return comment_delete == otherTyped.comment_delete;
    
  }
  @override
  int get hashCode => comment_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (comment_delete != null) {
      json['comment_delete'] = comment_delete!.toJson();
    }
    return json;
  }

  DeleteCommentData({
    this.comment_delete,
  });
}

@immutable
class DeleteCommentVariables {
  final String commentId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteCommentVariables.fromJson(Map<String, dynamic> json):
  
  commentId = nativeFromJson<String>(json['commentId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCommentVariables otherTyped = other as DeleteCommentVariables;
    return commentId == otherTyped.commentId;
    
  }
  @override
  int get hashCode => commentId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['commentId'] = nativeToJson<String>(commentId);
    return json;
  }

  DeleteCommentVariables({
    required this.commentId,
  });
}

