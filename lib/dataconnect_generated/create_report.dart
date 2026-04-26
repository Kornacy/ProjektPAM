part of 'default_connector.dart';

class CreateReportVariablesBuilder {
  String category;
  Optional<String> _desc = Optional.optional(nativeFromJson, nativeToJson);
  double lat;
  double lng;

  final FirebaseDataConnect _dataConnect;  CreateReportVariablesBuilder desc(String? t) {
   _desc.value = t;
   return this;
  }

  CreateReportVariablesBuilder(this._dataConnect, {required  this.category,required  this.lat,required  this.lng,});
  Deserializer<CreateReportData> dataDeserializer = (dynamic json)  => CreateReportData.fromJson(jsonDecode(json));
  Serializer<CreateReportVariables> varsSerializer = (CreateReportVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateReportData, CreateReportVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateReportData, CreateReportVariables> ref() {
    CreateReportVariables vars= CreateReportVariables(category: category,desc: _desc,lat: lat,lng: lng,);
    return _dataConnect.mutation("CreateReport", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateReportReportInsert {
  final String id;
  CreateReportReportInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportReportInsert otherTyped = other as CreateReportReportInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateReportReportInsert({
    required this.id,
  });
}

@immutable
class CreateReportData {
  final CreateReportReportInsert report_insert;
  CreateReportData.fromJson(dynamic json):
  
  report_insert = CreateReportReportInsert.fromJson(json['report_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportData otherTyped = other as CreateReportData;
    return report_insert == otherTyped.report_insert;
    
  }
  @override
  int get hashCode => report_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['report_insert'] = report_insert.toJson();
    return json;
  }

  CreateReportData({
    required this.report_insert,
  });
}

@immutable
class CreateReportVariables {
  final String category;
  late final Optional<String>desc;
  final double lat;
  final double lng;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateReportVariables.fromJson(Map<String, dynamic> json):
  
  category = nativeFromJson<String>(json['category']),
  lat = nativeFromJson<double>(json['lat']),
  lng = nativeFromJson<double>(json['lng']) {
  
  
  
    desc = Optional.optional(nativeFromJson, nativeToJson);
    desc.value = json['desc'] == null ? null : nativeFromJson<String>(json['desc']);
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportVariables otherTyped = other as CreateReportVariables;
    return category == otherTyped.category && 
    desc == otherTyped.desc && 
    lat == otherTyped.lat && 
    lng == otherTyped.lng;
    
  }
  @override
  int get hashCode => Object.hashAll([category.hashCode, desc.hashCode, lat.hashCode, lng.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['category'] = nativeToJson<String>(category);
    if(desc.state == OptionalState.set) {
      json['desc'] = desc.toJson();
    }
    json['lat'] = nativeToJson<double>(lat);
    json['lng'] = nativeToJson<double>(lng);
    return json;
  }

  CreateReportVariables({
    required this.category,
    required this.desc,
    required this.lat,
    required this.lng,
  });
}

