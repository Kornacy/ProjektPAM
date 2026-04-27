# default_connector SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
DefaultConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetReports
#### Required Arguments
```dart
// No required arguments
DefaultConnector.instance.getReports().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetReportsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getReports();
GetReportsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = DefaultConnector.instance.getReports().ref();
ref.execute();

ref.subscribe(...);
```


### GetCategories
#### Required Arguments
```dart
// No required arguments
DefaultConnector.instance.getCategories().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetCategoriesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await DefaultConnector.instance.getCategories();
GetCategoriesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = DefaultConnector.instance.getCategories().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### UpsertUser
#### Required Arguments
```dart
String email = ...;
DefaultConnector.instance.upsertUser(
  email: email,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertUser, we created `UpsertUserBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertUserVariablesBuilder {
  ...
   UpsertUserVariablesBuilder username(String? t) {
   _username.value = t;
   return this;
  }
  UpsertUserVariablesBuilder photoUrl(String? t) {
   _photoUrl.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.upsertUser(
  email: email,
)
.username(username)
.photoUrl(photoUrl)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertUserData, UpsertUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.upsertUser(
  email: email,
);
UpsertUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String email = ...;

final ref = DefaultConnector.instance.upsertUser(
  email: email,
).ref();
ref.execute();
```


### CreateReport
#### Required Arguments
```dart
String category = ...;
double lat = ...;
double lng = ...;
DefaultConnector.instance.createReport(
  category: category,
  lat: lat,
  lng: lng,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateReport, we created `CreateReportBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateReportVariablesBuilder {
  ...
   CreateReportVariablesBuilder desc(String? t) {
   _desc.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.createReport(
  category: category,
  lat: lat,
  lng: lng,
)
.desc(desc)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateReportData, CreateReportVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.createReport(
  category: category,
  lat: lat,
  lng: lng,
);
CreateReportData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String category = ...;
double lat = ...;
double lng = ...;

final ref = DefaultConnector.instance.createReport(
  category: category,
  lat: lat,
  lng: lng,
).ref();
ref.execute();
```


### AddPhoto
#### Required Arguments
```dart
String reportId = ...;
String url = ...;
DefaultConnector.instance.addPhoto(
  reportId: reportId,
  url: url,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AddPhotoData, AddPhotoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.addPhoto(
  reportId: reportId,
  url: url,
);
AddPhotoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;
String url = ...;

final ref = DefaultConnector.instance.addPhoto(
  reportId: reportId,
  url: url,
).ref();
ref.execute();
```


### UpvoteReport
#### Required Arguments
```dart
String reportId = ...;
DefaultConnector.instance.upvoteReport(
  reportId: reportId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpvoteReportData, UpvoteReportVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.upvoteReport(
  reportId: reportId,
);
UpvoteReportData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;

final ref = DefaultConnector.instance.upvoteReport(
  reportId: reportId,
).ref();
ref.execute();
```

