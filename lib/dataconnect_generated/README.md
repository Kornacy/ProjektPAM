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


### GetActiveReports
#### Required Arguments
```dart
// No required arguments
DefaultConnector.instance.getActiveReports().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetActiveReportsData, void>`
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

final result = await DefaultConnector.instance.getActiveReports();
GetActiveReportsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = DefaultConnector.instance.getActiveReports().ref();
ref.execute();

ref.subscribe(...);
```


### GetMyReports
#### Required Arguments
```dart
// No required arguments
DefaultConnector.instance.getMyReports().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetMyReportsData, void>`
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

final result = await DefaultConnector.instance.getMyReports();
GetMyReportsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = DefaultConnector.instance.getMyReports().ref();
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


### GetReportComments
#### Required Arguments
```dart
String reportId = ...;
DefaultConnector.instance.getReportComments(
  reportId: reportId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetReportCommentsData, GetReportCommentsVariables>`
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

final result = await DefaultConnector.instance.getReportComments(
  reportId: reportId,
);
GetReportCommentsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;

final ref = DefaultConnector.instance.getReportComments(
  reportId: reportId,
).ref();
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


### RemoveReportPhoto
#### Required Arguments
```dart
String photoId = ...;
DefaultConnector.instance.removeReportPhoto(
  photoId: photoId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<RemoveReportPhotoData, RemoveReportPhotoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.removeReportPhoto(
  photoId: photoId,
);
RemoveReportPhotoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String photoId = ...;

final ref = DefaultConnector.instance.removeReportPhoto(
  photoId: photoId,
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


### RemoveUpvote
#### Required Arguments
```dart
String reportId = ...;
DefaultConnector.instance.removeUpvote(
  reportId: reportId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<RemoveUpvoteData, RemoveUpvoteVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.removeUpvote(
  reportId: reportId,
);
RemoveUpvoteData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;

final ref = DefaultConnector.instance.removeUpvote(
  reportId: reportId,
).ref();
ref.execute();
```


### AddComment
#### Required Arguments
```dart
String reportId = ...;
String content = ...;
DefaultConnector.instance.addComment(
  reportId: reportId,
  content: content,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AddCommentData, AddCommentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.addComment(
  reportId: reportId,
  content: content,
);
AddCommentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;
String content = ...;

final ref = DefaultConnector.instance.addComment(
  reportId: reportId,
  content: content,
).ref();
ref.execute();
```


### EditComment
#### Required Arguments
```dart
String commentId = ...;
String content = ...;
DefaultConnector.instance.editComment(
  commentId: commentId,
  content: content,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EditCommentData, EditCommentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.editComment(
  commentId: commentId,
  content: content,
);
EditCommentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String commentId = ...;
String content = ...;

final ref = DefaultConnector.instance.editComment(
  commentId: commentId,
  content: content,
).ref();
ref.execute();
```


### DeleteComment
#### Required Arguments
```dart
String commentId = ...;
DefaultConnector.instance.deleteComment(
  commentId: commentId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteCommentData, DeleteCommentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.deleteComment(
  commentId: commentId,
);
DeleteCommentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String commentId = ...;

final ref = DefaultConnector.instance.deleteComment(
  commentId: commentId,
).ref();
ref.execute();
```


### EditReport
#### Required Arguments
```dart
String reportId = ...;
String category = ...;
double lat = ...;
double lng = ...;
DefaultConnector.instance.editReport(
  reportId: reportId,
  category: category,
  lat: lat,
  lng: lng,
).execute();
```

#### Optional Arguments
We return a builder for each query. For EditReport, we created `EditReportBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class EditReportVariablesBuilder {
  ...
   EditReportVariablesBuilder desc(String? t) {
   _desc.value = t;
   return this;
  }

  ...
}
DefaultConnector.instance.editReport(
  reportId: reportId,
  category: category,
  lat: lat,
  lng: lng,
)
.desc(desc)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<EditReportData, EditReportVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.editReport(
  reportId: reportId,
  category: category,
  lat: lat,
  lng: lng,
);
EditReportData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;
String category = ...;
double lat = ...;
double lng = ...;

final ref = DefaultConnector.instance.editReport(
  reportId: reportId,
  category: category,
  lat: lat,
  lng: lng,
).ref();
ref.execute();
```


### DeleteReport
#### Required Arguments
```dart
String reportId = ...;
DefaultConnector.instance.deleteReport(
  reportId: reportId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteReportData, DeleteReportVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.deleteReport(
  reportId: reportId,
);
DeleteReportData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String reportId = ...;

final ref = DefaultConnector.instance.deleteReport(
  reportId: reportId,
).ref();
ref.execute();
```


### DeleteAccount
#### Required Arguments
```dart
// No required arguments
DefaultConnector.instance.deleteAccount().execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteAccountData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await DefaultConnector.instance.deleteAccount();
DeleteAccountData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = DefaultConnector.instance.deleteAccount().ref();
ref.execute();
```

