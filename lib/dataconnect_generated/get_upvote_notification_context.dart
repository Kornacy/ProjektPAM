part of 'default.dart';

class GetUpvoteNotificationContextVariablesBuilder {
  String reportId;
  String upvoterId;

  final FirebaseDataConnect _dataConnect;
  GetUpvoteNotificationContextVariablesBuilder(this._dataConnect, {required  this.reportId,required  this.upvoterId,});
  Deserializer<GetUpvoteNotificationContextData> dataDeserializer = (dynamic json)  => GetUpvoteNotificationContextData.fromJson(jsonDecode(json));
  Serializer<GetUpvoteNotificationContextVariables> varsSerializer = (GetUpvoteNotificationContextVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUpvoteNotificationContextData, GetUpvoteNotificationContextVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUpvoteNotificationContextData, GetUpvoteNotificationContextVariables> ref() {
    GetUpvoteNotificationContextVariables vars= GetUpvoteNotificationContextVariables(reportId: reportId,upvoterId: upvoterId,);
    return _dataConnect.query("GetUpvoteNotificationContext", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUpvoteNotificationContextReports {
  final String id;
  final String? description;
  final GetUpvoteNotificationContextReportsUser user;
  final GetUpvoteNotificationContextReportsCategory category;
  GetUpvoteNotificationContextReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  user = GetUpvoteNotificationContextReportsUser.fromJson(json['user']),
  category = GetUpvoteNotificationContextReportsCategory.fromJson(json['category']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextReports otherTyped = other as GetUpvoteNotificationContextReports;
    return id == otherTyped.id && 
    description == otherTyped.description && 
    user == otherTyped.user && 
    category == otherTyped.category;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, description.hashCode, user.hashCode, category.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['user'] = user.toJson();
    json['category'] = category.toJson();
    return json;
  }

  GetUpvoteNotificationContextReports({
    required this.id,
    this.description,
    required this.user,
    required this.category,
  });
}

@immutable
class GetUpvoteNotificationContextReportsUser {
  final String id;
  final String? fcmToken;
  GetUpvoteNotificationContextReportsUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  fcmToken = json['fcmToken'] == null ? null : nativeFromJson<String>(json['fcmToken']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextReportsUser otherTyped = other as GetUpvoteNotificationContextReportsUser;
    return id == otherTyped.id && 
    fcmToken == otherTyped.fcmToken;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, fcmToken.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if (fcmToken != null) {
      json['fcmToken'] = nativeToJson<String?>(fcmToken);
    }
    return json;
  }

  GetUpvoteNotificationContextReportsUser({
    required this.id,
    this.fcmToken,
  });
}

@immutable
class GetUpvoteNotificationContextReportsCategory {
  final String name;
  GetUpvoteNotificationContextReportsCategory.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextReportsCategory otherTyped = other as GetUpvoteNotificationContextReportsCategory;
    return name == otherTyped.name;
    
  }
  @override
  int get hashCode => name.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetUpvoteNotificationContextReportsCategory({
    required this.name,
  });
}

@immutable
class GetUpvoteNotificationContextUpvoter {
  final String username;
  GetUpvoteNotificationContextUpvoter.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextUpvoter otherTyped = other as GetUpvoteNotificationContextUpvoter;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  GetUpvoteNotificationContextUpvoter({
    required this.username,
  });
}

@immutable
class GetUpvoteNotificationContextData {
  final List<GetUpvoteNotificationContextReports> reports;
  final List<GetUpvoteNotificationContextUpvoter> upvoter;
  GetUpvoteNotificationContextData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => GetUpvoteNotificationContextReports.fromJson(e))
        .toList(),
  upvoter = (json['upvoter'] as List<dynamic>)
        .map((e) => GetUpvoteNotificationContextUpvoter.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextData otherTyped = other as GetUpvoteNotificationContextData;
    return reports == otherTyped.reports && 
    upvoter == otherTyped.upvoter;
    
  }
  @override
  int get hashCode => Object.hashAll([reports.hashCode, upvoter.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    json['upvoter'] = upvoter.map((e) => e.toJson()).toList();
    return json;
  }

  GetUpvoteNotificationContextData({
    required this.reports,
    required this.upvoter,
  });
}

@immutable
class GetUpvoteNotificationContextVariables {
  final String reportId;
  final String upvoterId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUpvoteNotificationContextVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']),
  upvoterId = nativeFromJson<String>(json['upvoterId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUpvoteNotificationContextVariables otherTyped = other as GetUpvoteNotificationContextVariables;
    return reportId == otherTyped.reportId && 
    upvoterId == otherTyped.upvoterId;
    
  }
  @override
  int get hashCode => Object.hashAll([reportId.hashCode, upvoterId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    json['upvoterId'] = nativeToJson<String>(upvoterId);
    return json;
  }

  GetUpvoteNotificationContextVariables({
    required this.reportId,
    required this.upvoterId,
  });
}

