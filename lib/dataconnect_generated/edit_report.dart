part of 'default.dart';

class EditReportVariablesBuilder {
  String reportId;
  String category;
  Optional<String> _desc = Optional.optional(nativeFromJson, nativeToJson);
  double lat;
  double lng;

  final FirebaseDataConnect _dataConnect;  EditReportVariablesBuilder desc(String? t) {
   _desc.value = t;
   return this;
  }

  EditReportVariablesBuilder(this._dataConnect, {required  this.reportId,required  this.category,required  this.lat,required  this.lng,});
  Deserializer<EditReportData> dataDeserializer = (dynamic json)  => EditReportData.fromJson(jsonDecode(json));
  Serializer<EditReportVariables> varsSerializer = (EditReportVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditReportData, EditReportVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditReportData, EditReportVariables> ref() {
    EditReportVariables vars= EditReportVariables(reportId: reportId,category: category,desc: _desc,lat: lat,lng: lng,);
    return _dataConnect.mutation("EditReport", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditReportData {
  final int report_updateMany;
  EditReportData.fromJson(dynamic json):
  
  report_updateMany = nativeFromJson<int>(json['report_updateMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditReportData otherTyped = other as EditReportData;
    return report_updateMany == otherTyped.report_updateMany;
    
  }
  @override
  int get hashCode => report_updateMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['report_updateMany'] = nativeToJson<int>(report_updateMany);
    return json;
  }

  EditReportData({
    required this.report_updateMany,
  });
}

@immutable
class EditReportVariables {
  final String reportId;
  final String category;
  late final Optional<String>desc;
  final double lat;
  final double lng;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditReportVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']),
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

    final EditReportVariables otherTyped = other as EditReportVariables;
    return reportId == otherTyped.reportId && 
    category == otherTyped.category && 
    desc == otherTyped.desc && 
    lat == otherTyped.lat && 
    lng == otherTyped.lng;
    
  }
  @override
  int get hashCode => Object.hashAll([reportId.hashCode, category.hashCode, desc.hashCode, lat.hashCode, lng.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    json['category'] = nativeToJson<String>(category);
    if(desc.state == OptionalState.set) {
      json['desc'] = desc.toJson();
    }
    json['lat'] = nativeToJson<double>(lat);
    json['lng'] = nativeToJson<double>(lng);
    return json;
  }

  EditReportVariables({
    required this.reportId,
    required this.category,
    required this.desc,
    required this.lat,
    required this.lng,
  });
}

