part of 'default.dart';

class RemoveUpvoteVariablesBuilder {
  String reportId;

  final FirebaseDataConnect _dataConnect;
  RemoveUpvoteVariablesBuilder(this._dataConnect, {required  this.reportId,});
  Deserializer<RemoveUpvoteData> dataDeserializer = (dynamic json)  => RemoveUpvoteData.fromJson(jsonDecode(json));
  Serializer<RemoveUpvoteVariables> varsSerializer = (RemoveUpvoteVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<RemoveUpvoteData, RemoveUpvoteVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RemoveUpvoteData, RemoveUpvoteVariables> ref() {
    RemoveUpvoteVariables vars= RemoveUpvoteVariables(reportId: reportId,);
    return _dataConnect.mutation("RemoveUpvote", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RemoveUpvoteData {
  final int upvote_deleteMany;
  RemoveUpvoteData.fromJson(dynamic json):
  
  upvote_deleteMany = nativeFromJson<int>(json['upvote_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RemoveUpvoteData otherTyped = other as RemoveUpvoteData;
    return upvote_deleteMany == otherTyped.upvote_deleteMany;
    
  }
  @override
  int get hashCode => upvote_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['upvote_deleteMany'] = nativeToJson<int>(upvote_deleteMany);
    return json;
  }

  RemoveUpvoteData({
    required this.upvote_deleteMany,
  });
}

@immutable
class RemoveUpvoteVariables {
  final String reportId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RemoveUpvoteVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RemoveUpvoteVariables otherTyped = other as RemoveUpvoteVariables;
    return reportId == otherTyped.reportId;
    
  }
  @override
  int get hashCode => reportId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    return json;
  }

  RemoveUpvoteVariables({
    required this.reportId,
  });
}

