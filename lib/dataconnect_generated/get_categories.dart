part of 'default.dart';

class GetCategoriesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetCategoriesVariablesBuilder(this._dataConnect, );
  Deserializer<GetCategoriesData> dataDeserializer = (dynamic json)  => GetCategoriesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetCategoriesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetCategoriesData, void> ref() {
    
    return _dataConnect.query("GetCategories", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetCategoriesCategories {
  final String id;
  final String name;
  final String iconName;
  GetCategoriesCategories.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  iconName = nativeFromJson<String>(json['iconName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCategoriesCategories otherTyped = other as GetCategoriesCategories;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    iconName == otherTyped.iconName;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, iconName.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['iconName'] = nativeToJson<String>(iconName);
    return json;
  }

  GetCategoriesCategories({
    required this.id,
    required this.name,
    required this.iconName,
  });
}

@immutable
class GetCategoriesData {
  final List<GetCategoriesCategories> categories;
  GetCategoriesData.fromJson(dynamic json):
  
  categories = (json['categories'] as List<dynamic>)
        .map((e) => GetCategoriesCategories.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCategoriesData otherTyped = other as GetCategoriesData;
    return categories == otherTyped.categories;
    
  }
  @override
  int get hashCode => categories.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['categories'] = categories.map((e) => e.toJson()).toList();
    return json;
  }

  GetCategoriesData({
    required this.categories,
  });
}