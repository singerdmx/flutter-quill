import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_test/flutter_test.dart';

class QuillTestApp extends StatelessWidget {
  QuillTestApp({
    required this.home,
    required this.scaffoldBody,
    super.key,
  }) {
    if (home != null && scaffoldBody != null) {
      throw ArgumentError('Either the home or scaffoldBody must be null');
    }
  }

  factory QuillTestApp.withScaffold(Widget body) =>
      QuillTestApp(home: null, scaffoldBody: body);

  factory QuillTestApp.home(Widget home) =>
      QuillTestApp(home: home, scaffoldBody: null);

  final Widget? home;
  final Widget? scaffoldBody;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: home ??
          Scaffold(
            body: scaffoldBody,
          ),
    );
  }
}

extension LocalizationsExt on WidgetTester {
  FlutterQuillLocalizations localizationsFromElement(Type type) =>
      (element(find.byType(type)) as BuildContext).loc;
}
