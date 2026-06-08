import 'package:city_issues/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a [MaterialApp] with app theme for widget tests.
Widget wrapForTest(
  Widget child, {
  ThemeData? theme,
  ThemeData? darkTheme,
  Widget? home,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(Colors.indigo),
    darkTheme: darkTheme ?? AppTheme.dark(Colors.indigo),
    home: home ?? Scaffold(body: child),
  );
}

/// Pumps [child] inside [wrapForTest] and waits one frame.
Future<void> pumpWidget(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  Size surfaceSize = const Size(400, 800),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(wrapForTest(child, theme: theme));
  await tester.pump();
}

/// Pumps a full-screen widget (e.g. [Scaffold]) as [MaterialApp.home].
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  ThemeData? theme,
  Size surfaceSize = const Size(400, 800),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(Colors.indigo),
      home: screen,
    ),
  );
  await tester.pump();
}
