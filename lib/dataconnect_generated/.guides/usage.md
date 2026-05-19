# Basic Usage

```dart
DefaultConnector.instance.UpsertUser(upsertUserVariables).execute();
DefaultConnector.instance.CreateReport(createReportVariables).execute();
DefaultConnector.instance.AddPhoto(addPhotoVariables).execute();
DefaultConnector.instance.UpvoteReport(upvoteReportVariables).execute();
DefaultConnector.instance.GetReports().execute();
DefaultConnector.instance.GetActiveReports().execute();
DefaultConnector.instance.GetMyReports().execute();
DefaultConnector.instance.GetCategories().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await DefaultConnector.instance.CreateReport({ ... })
.desc(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

