part of 'default.dart';

class UpdateFcmTokenVariablesBuilder {
  String token;

  final FirebaseDataConnect _dataConnect;
  UpdateFcmTokenVariablesBuilder(this._dataConnect, {required  this.token,});
  Deserializer<UpdateFcmTokenData> dataDeserializer = (dynamic json)  => UpdateFcmTokenData.fromJson(jsonDecode(json));
  Serializer<UpdateFcmTokenVariables> varsSerializer = (UpdateFcmTokenVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateFcmTokenData, UpdateFcmTokenVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateFcmTokenData, UpdateFcmTokenVariables> ref() {
    UpdateFcmTokenVariables vars= UpdateFcmTokenVariables(token: token,);
    return _dataConnect.mutation("UpdateFcmToken", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateFcmTokenUserUpdate {
  final String id;
  UpdateFcmTokenUserUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateFcmTokenUserUpdate otherTyped = other as UpdateFcmTokenUserUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateFcmTokenUserUpdate({
    required this.id,
  });
}

@immutable
class UpdateFcmTokenData {
  final UpdateFcmTokenUserUpdate? user_update;
  UpdateFcmTokenData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateFcmTokenUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateFcmTokenData otherTyped = other as UpdateFcmTokenData;
    return user_update == otherTyped.user_update;
    
  }
  @override
  int get hashCode => user_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    return json;
  }

  UpdateFcmTokenData({
    this.user_update,
  });
}

@immutable
class UpdateFcmTokenVariables {
  final String token;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateFcmTokenVariables.fromJson(Map<String, dynamic> json):
  
  token = nativeFromJson<String>(json['token']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateFcmTokenVariables otherTyped = other as UpdateFcmTokenVariables;
    return token == otherTyped.token;
    
  }
  @override
  int get hashCode => token.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['token'] = nativeToJson<String>(token);
    return json;
  }

  UpdateFcmTokenVariables({
    required this.token,
  });
}

