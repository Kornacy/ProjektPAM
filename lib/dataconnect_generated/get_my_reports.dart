part of 'default.dart';

class GetMyReportsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetMyReportsVariablesBuilder(this._dataConnect, );
  Deserializer<GetMyReportsData> dataDeserializer = (dynamic json)  => GetMyReportsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetMyReportsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetMyReportsData, void> ref() {
    
    return _dataConnect.query("GetMyReports", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetMyReportsReports {
  final String id;
  final double latitude;
  final double longitude;
  final String? description;
  final String status;
  final Timestamp createdAt;
  final GetMyReportsReportsCategory category;
  final List<GetMyReportsReportsReportPhotosOnReport> reportPhotos_on_report;
  final List<GetMyReportsReportsUpvotesOnReport> upvotes_on_report;
  final GetMyReportsReportsUser user;
  GetMyReportsReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  status = nativeFromJson<String>(json['status']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  category = GetMyReportsReportsCategory.fromJson(json['category']),
  reportPhotos_on_report = (json['reportPhotos_on_report'] as List<dynamic>)
        .map((e) => GetMyReportsReportsReportPhotosOnReport.fromJson(e))
        .toList(),
  upvotes_on_report = (json['upvotes_on_report'] as List<dynamic>)
        .map((e) => GetMyReportsReportsUpvotesOnReport.fromJson(e))
        .toList(),
  user = GetMyReportsReportsUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReports otherTyped = other as GetMyReportsReports;
    return id == otherTyped.id && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude && 
    description == otherTyped.description && 
    status == otherTyped.status && 
    createdAt == otherTyped.createdAt && 
    category == otherTyped.category && 
    reportPhotos_on_report == otherTyped.reportPhotos_on_report && 
    upvotes_on_report == otherTyped.upvotes_on_report && 
    user == otherTyped.user;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, latitude.hashCode, longitude.hashCode, description.hashCode, status.hashCode, createdAt.hashCode, category.hashCode, reportPhotos_on_report.hashCode, upvotes_on_report.hashCode, user.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['status'] = nativeToJson<String>(status);
    json['createdAt'] = createdAt.toJson();
    json['category'] = category.toJson();
    json['reportPhotos_on_report'] = reportPhotos_on_report.map((e) => e.toJson()).toList();
    json['upvotes_on_report'] = upvotes_on_report.map((e) => e.toJson()).toList();
    json['user'] = user.toJson();
    return json;
  }

  GetMyReportsReports({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.status,
    required this.createdAt,
    required this.category,
    required this.reportPhotos_on_report,
    required this.upvotes_on_report,
    required this.user,
  });
}

@immutable
class GetMyReportsReportsCategory {
  final String name;
  final String iconName;
  final String pinColor;
  GetMyReportsReportsCategory.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']),
  iconName = nativeFromJson<String>(json['iconName']),
  pinColor = nativeFromJson<String>(json['pinColor']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReportsCategory otherTyped = other as GetMyReportsReportsCategory;
    return name == otherTyped.name && 
    iconName == otherTyped.iconName && 
    pinColor == otherTyped.pinColor;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, iconName.hashCode, pinColor.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['iconName'] = nativeToJson<String>(iconName);
    json['pinColor'] = nativeToJson<String>(pinColor);
    return json;
  }

  GetMyReportsReportsCategory({
    required this.name,
    required this.iconName,
    required this.pinColor,
  });
}

@immutable
class GetMyReportsReportsReportPhotosOnReport {
  final String imageUrl;
  GetMyReportsReportsReportPhotosOnReport.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReportsReportPhotosOnReport otherTyped = other as GetMyReportsReportsReportPhotosOnReport;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  GetMyReportsReportsReportPhotosOnReport({
    required this.imageUrl,
  });
}

@immutable
class GetMyReportsReportsUpvotesOnReport {
  final String id;
  final GetMyReportsReportsUpvotesOnReportUser user;
  GetMyReportsReportsUpvotesOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  user = json['user'] == null
      ? GetMyReportsReportsUpvotesOnReportUser(id: '')
      : GetMyReportsReportsUpvotesOnReportUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReportsUpvotesOnReport otherTyped = other as GetMyReportsReportsUpvotesOnReport;
    return id == otherTyped.id && 
    user == otherTyped.user;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, user.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['user'] = user.toJson();
    return json;
  }

  GetMyReportsReportsUpvotesOnReport({
    required this.id,
    required this.user,
  });
}

@immutable
class GetMyReportsReportsUpvotesOnReportUser {
  final String id;
  GetMyReportsReportsUpvotesOnReportUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReportsUpvotesOnReportUser otherTyped = other as GetMyReportsReportsUpvotesOnReportUser;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetMyReportsReportsUpvotesOnReportUser({
    required this.id,
  });
}

@immutable
class GetMyReportsReportsUser {
  final String id;
  GetMyReportsReportsUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsReportsUser otherTyped = other as GetMyReportsReportsUser;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetMyReportsReportsUser({
    required this.id,
  });
}

@immutable
class GetMyReportsData {
  final List<GetMyReportsReports> reports;
  GetMyReportsData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => GetMyReportsReports.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyReportsData otherTyped = other as GetMyReportsData;
    return reports == otherTyped.reports;
    
  }
  @override
  int get hashCode => reports.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    return json;
  }

  GetMyReportsData({
    required this.reports,
  });
}

