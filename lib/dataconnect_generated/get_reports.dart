part of 'default.dart';

class GetReportsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetReportsVariablesBuilder(this._dataConnect, );
  Deserializer<GetReportsData> dataDeserializer = (dynamic json)  => GetReportsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetReportsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetReportsData, void> ref() {
    
    return _dataConnect.query("GetReports", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetReportsReports {
  final String id;
  final double latitude;
  final double longitude;
  final String? description;
  final String status;
  final GetReportsReportsCategory category;
  final List<GetReportsReportsReportPhotosOnReport> reportPhotos_on_report;
  final List<GetReportsReportsUpvotesOnReport> upvotes_on_report;
  GetReportsReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  status = nativeFromJson<String>(json['status']),
  category = GetReportsReportsCategory.fromJson(json['category']),
  reportPhotos_on_report = (json['reportPhotos_on_report'] as List<dynamic>)
        .map((e) => GetReportsReportsReportPhotosOnReport.fromJson(e))
        .toList(),
  upvotes_on_report = (json['upvotes_on_report'] as List<dynamic>)
        .map((e) => GetReportsReportsUpvotesOnReport.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportsReports otherTyped = other as GetReportsReports;
    return id == otherTyped.id && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude && 
    description == otherTyped.description && 
    status == otherTyped.status && 
    category == otherTyped.category && 
    reportPhotos_on_report == otherTyped.reportPhotos_on_report && 
    upvotes_on_report == otherTyped.upvotes_on_report;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, latitude.hashCode, longitude.hashCode, description.hashCode, status.hashCode, category.hashCode, reportPhotos_on_report.hashCode, upvotes_on_report.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['status'] = nativeToJson<String>(status);
    json['category'] = category.toJson();
    json['reportPhotos_on_report'] = reportPhotos_on_report.map((e) => e.toJson()).toList();
    json['upvotes_on_report'] = upvotes_on_report.map((e) => e.toJson()).toList();
    return json;
  }

  GetReportsReports({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.status,
    required this.category,
    required this.reportPhotos_on_report,
    required this.upvotes_on_report,
  });
}

@immutable
class GetReportsReportsCategory {
  final String name;
  final String iconName;
  final String pinColor;
  GetReportsReportsCategory.fromJson(dynamic json):
  
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

    final GetReportsReportsCategory otherTyped = other as GetReportsReportsCategory;
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

  GetReportsReportsCategory({
    required this.name,
    required this.iconName,
    required this.pinColor,
  });
}

@immutable
class GetReportsReportsReportPhotosOnReport {
  final String id;
  final String imageUrl;
  GetReportsReportsReportPhotosOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportsReportsReportPhotosOnReport otherTyped = other as GetReportsReportsReportPhotosOnReport;
    return id == otherTyped.id && 
    imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, imageUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  GetReportsReportsReportPhotosOnReport({
    required this.id,
    required this.imageUrl,
  });
}

@immutable
class GetReportsReportsUpvotesOnReport {
  final String id;
  final GetReportsReportsUpvotesOnReportUser user;
  GetReportsReportsUpvotesOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  user = GetReportsReportsUpvotesOnReportUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportsReportsUpvotesOnReport otherTyped = other as GetReportsReportsUpvotesOnReport;
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

  GetReportsReportsUpvotesOnReport({
    required this.id,
    required this.user,
  });
}

@immutable
class GetReportsReportsUpvotesOnReportUser {
  final String id;
  GetReportsReportsUpvotesOnReportUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportsReportsUpvotesOnReportUser otherTyped = other as GetReportsReportsUpvotesOnReportUser;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetReportsReportsUpvotesOnReportUser({
    required this.id,
  });
}

@immutable
class GetReportsData {
  final List<GetReportsReports> reports;
  GetReportsData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => GetReportsReports.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetReportsData otherTyped = other as GetReportsData;
    return reports == otherTyped.reports;
    
  }
  @override
  int get hashCode => reports.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    return json;
  }

  GetReportsData({
    required this.reports,
  });
}

