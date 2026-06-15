part of 'default.dart';

class DeleteAccountVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  DeleteAccountVariablesBuilder(this._dataConnect, );
  Deserializer<DeleteAccountData> dataDeserializer = (dynamic json)  => DeleteAccountData.fromJson(jsonDecode(json));
  
  Future<OperationResult<DeleteAccountData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteAccountData, void> ref() {
    
    return _dataConnect.mutation("DeleteAccount", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class DeleteAccountUserDelete {
  final String id;
  DeleteAccountUserDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteAccountUserDelete otherTyped = other as DeleteAccountUserDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteAccountUserDelete({
    required this.id,
  });
}

@immutable
class DeleteAccountData {
  final int comment_deleteMany;
  final int upvote_deleteMany;
  final int reportPhoto_deleteMany;
  final int report_deleteMany;
  final DeleteAccountUserDelete? user_delete;
  DeleteAccountData.fromJson(dynamic json):
  
  comment_deleteMany = nativeFromJson<int>(json['comment_deleteMany']),
  upvote_deleteMany = nativeFromJson<int>(json['upvote_deleteMany']),
  reportPhoto_deleteMany = nativeFromJson<int>(json['reportPhoto_deleteMany']),
  report_deleteMany = nativeFromJson<int>(json['report_deleteMany']),
  user_delete = json['user_delete'] == null ? null : DeleteAccountUserDelete.fromJson(json['user_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteAccountData otherTyped = other as DeleteAccountData;
    return comment_deleteMany == otherTyped.comment_deleteMany && 
    upvote_deleteMany == otherTyped.upvote_deleteMany && 
    reportPhoto_deleteMany == otherTyped.reportPhoto_deleteMany && 
    report_deleteMany == otherTyped.report_deleteMany && 
    user_delete == otherTyped.user_delete;
    
  }
  @override
  int get hashCode => Object.hashAll([comment_deleteMany.hashCode, upvote_deleteMany.hashCode, reportPhoto_deleteMany.hashCode, report_deleteMany.hashCode, user_delete.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['comment_deleteMany'] = nativeToJson<int>(comment_deleteMany);
    json['upvote_deleteMany'] = nativeToJson<int>(upvote_deleteMany);
    json['reportPhoto_deleteMany'] = nativeToJson<int>(reportPhoto_deleteMany);
    json['report_deleteMany'] = nativeToJson<int>(report_deleteMany);
    if (user_delete != null) {
      json['user_delete'] = user_delete!.toJson();
    }
    return json;
  }

  DeleteAccountData({
    required this.comment_deleteMany,
    required this.upvote_deleteMany,
    required this.reportPhoto_deleteMany,
    required this.report_deleteMany,
    this.user_delete,
  });
}

