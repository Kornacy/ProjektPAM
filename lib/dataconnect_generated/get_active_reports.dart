part of 'default.dart';

class GetActiveReportsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetActiveReportsVariablesBuilder(this._dataConnect, );
  Deserializer<GetActiveReportsData> dataDeserializer = (dynamic json)  => GetActiveReportsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetActiveReportsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetActiveReportsData, void> ref() {
    
    return _dataConnect.query("GetActiveReports", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetActiveReportsReports {
  final String id;
  final double latitude;
  final double longitude;
  final String? description;
  final String status;
  final GetActiveReportsReportsCategory category;
  final List<GetActiveReportsReportsReportPhotosOnReport> reportPhotos_on_report;
  final List<GetActiveReportsReportsUpvotesOnReport> upvotes_on_report;
  GetActiveReportsReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  status = nativeFromJson<String>(json['status']),
  category = GetActiveReportsReportsCategory.fromJson(json['category']),
  reportPhotos_on_report = (json['reportPhotos_on_report'] as List<dynamic>)
        .map((e) => GetActiveReportsReportsReportPhotosOnReport.fromJson(e))
        .toList(),
  upvotes_on_report = (json['upvotes_on_report'] as List<dynamic>)
        .map((e) => GetActiveReportsReportsUpvotesOnReport.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveReportsReports otherTyped = other as GetActiveReportsReports;
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

  GetActiveReportsReports({
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
class GetActiveReportsReportsCategory {
  final String name;
  final String iconName;
  final String pinColor;
  GetActiveReportsReportsCategory.fromJson(dynamic json):
  
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

    final GetActiveReportsReportsCategory otherTyped = other as GetActiveReportsReportsCategory;
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

  GetActiveReportsReportsCategory({
    required this.name,
    required this.iconName,
    required this.pinColor,
  });
}

@immutable
class GetActiveReportsReportsReportPhotosOnReport {
  final String imageUrl;
  GetActiveReportsReportsReportPhotosOnReport.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveReportsReportsReportPhotosOnReport otherTyped = other as GetActiveReportsReportsReportPhotosOnReport;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  GetActiveReportsReportsReportPhotosOnReport({
    required this.imageUrl,
  });
}

@immutable
class GetActiveReportsReportsUpvotesOnReport {
  final String id;
  final GetActiveReportsReportsUpvotesOnReportUser user;
  GetActiveReportsReportsUpvotesOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  user = json['user'] == null
      ? GetActiveReportsReportsUpvotesOnReportUser(id: '')
      : GetActiveReportsReportsUpvotesOnReportUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveReportsReportsUpvotesOnReport otherTyped = other as GetActiveReportsReportsUpvotesOnReport;
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

  GetActiveReportsReportsUpvotesOnReport({
    required this.id,
    required this.user,
  });
}

@immutable
class GetActiveReportsReportsUpvotesOnReportUser {
  final String id;
  GetActiveReportsReportsUpvotesOnReportUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveReportsReportsUpvotesOnReportUser otherTyped = other as GetActiveReportsReportsUpvotesOnReportUser;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetActiveReportsReportsUpvotesOnReportUser({
    required this.id,
  });
}

@immutable
class GetActiveReportsData {
  final List<GetActiveReportsReports> reports;
  GetActiveReportsData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => GetActiveReportsReports.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetActiveReportsData otherTyped = other as GetActiveReportsData;
    return reports == otherTyped.reports;
    
  }
  @override
  int get hashCode => reports.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    return json;
  }

  GetActiveReportsData({
    required this.reports,
  });
}

