part of 'default.dart';

class GetReportCommentsVariablesBuilder {
  String reportId;

  final FirebaseDataConnect _dataConnect;
  GetReportCommentsVariablesBuilder(this._dataConnect, {required  this.reportId,});
  Deserializer<GetReportCommentsData> dataDeserializer = (dynamic json)  => GetReportCommentsData.fromJson(jsonDecode(json));
  Serializer<GetReportCommentsVariables> varsSerializer = (GetReportCommentsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetReportCommentsData, GetReportCommentsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetReportCommentsData, GetReportCommentsVariables> ref() {
    GetReportCommentsVariables vars= GetReportCommentsVariables(reportId: reportId,);
    return _dataConnect.query("GetReportComments", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetReportCommentsComments {
  final String id;
  final String content;
  final Timestamp createdAt;
  final GetReportCommentsCommentsUser user;
  GetReportCommentsComments.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  content = nativeFromJson<String>(json['content']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  user = GetReportCommentsCommentsUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportCommentsComments otherTyped = other as GetReportCommentsComments;
    return id == otherTyped.id && 
    content == otherTyped.content && 
    createdAt == otherTyped.createdAt && 
    user == otherTyped.user;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, content.hashCode, createdAt.hashCode, user.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['content'] = nativeToJson<String>(content);
    json['createdAt'] = createdAt.toJson();
    json['user'] = user.toJson();
    return json;
  }

  GetReportCommentsComments({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });
}

@immutable
class GetReportCommentsCommentsUser {
  final String id;
  final String username;
  final String photoUrl;
  GetReportCommentsCommentsUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  username = nativeFromJson<String>(json['username']),
  photoUrl = nativeFromJson<String>(json['photoUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportCommentsCommentsUser otherTyped = other as GetReportCommentsCommentsUser;
    return id == otherTyped.id && 
    username == otherTyped.username && 
    photoUrl == otherTyped.photoUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, username.hashCode, photoUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['username'] = nativeToJson<String>(username);
    json['photoUrl'] = nativeToJson<String>(photoUrl);
    return json;
  }

  GetReportCommentsCommentsUser({
    required this.id,
    required this.username,
    required this.photoUrl,
  });
}

@immutable
class GetReportCommentsData {
  final List<GetReportCommentsComments> comments;
  GetReportCommentsData.fromJson(dynamic json):
  
  comments = (json['comments'] as List<dynamic>)
        .map((e) => GetReportCommentsComments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportCommentsData otherTyped = other as GetReportCommentsData;
    return comments == otherTyped.comments;
    
  }
  @override
  int get hashCode => comments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['comments'] = comments.map((e) => e.toJson()).toList();
    return json;
  }

  GetReportCommentsData({
    required this.comments,
  });
}

@immutable
class GetReportCommentsVariables {
  final String reportId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetReportCommentsVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportCommentsVariables otherTyped = other as GetReportCommentsVariables;
    return reportId == otherTyped.reportId;
    
  }
  @override
  int get hashCode => reportId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    return json;
  }

  GetReportCommentsVariables({
    required this.reportId,
  });
}

