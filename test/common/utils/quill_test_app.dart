import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_test/flutter_test.dart';

typedef LocalizationsAvailableCallback = void Function(
    FlutterQuillLocalizations quillLocalizations);

/// A utility for testing widgets within an application widget configured with
/// the necessary localizations.
///
/// Simplifies test setup, enabling concise test cases such as:
///
/// ```dart
/// testWidgets('Test description', (tester) async {
///   final exampleWidget = ...;
///   await tester.pumpWidget(QuillTestApp.withScaffold(exampleWidget));
/// });
/// ```
///
/// Instead of requiring the verbose setup:
///
/// ```dart
/// testWidgets('Test description', (tester) async {
///   final exampleWidget = ...;
///   await tester.pumpWidget(MaterialApp(
///     localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
///     supportedLocales: FlutterQuillLocalizations.supportedLocales,
///     home: Scaffold(body: exampleWidget),
///   ));
/// });
/// ```
class QuillTestApp extends StatelessWidget {
  /// Constructs a [QuillTestApp] instance.
  ///
  /// Either [home] or [scaffoldBody] must be provided.
  /// Throws an [ArgumentError] if both are provided.
  QuillTestApp({
    required this.home,
    required this.scaffoldBody,
    this.onLocalizationsAvailable,
    super.key,
  }) {
    if (home != null && scaffoldBody != null) {
      throw ArgumentError('Either the home or scaffoldBody must be null');
    }
  }

  /// Creates a [QuillTestApp] with a [Scaffold] wrapping the given [body] widget.
  factory QuillTestApp.withScaffold(Widget body,
          {LocalizationsAvailableCallback? onLocalizationsAvailable}) =>
      QuillTestApp(
        home: null,
        scaffoldBody: body,
        onLocalizationsAvailable: onLocalizationsAvailable,
      );

  /// Creates a [QuillTestApp] with the specified [home] widget.
  factory QuillTestApp.home(Widget home,
          {LocalizationsAvailableCallback? onLocalizationsAvailable}) =>
      QuillTestApp(
        home: home,
        scaffoldBody: null,
        onLocalizationsAvailable: onLocalizationsAvailable,
      );

  /// The home widget for the application.
  ///
  /// If [home] is not null, [scaffoldBody] must be null.
  final Widget? home;

  /// The body widget for a [Scaffold] used as the application home.
  ///
  /// If [scaffoldBody] is not null, [home] must be null.
  final Widget? scaffoldBody;

  final LocalizationsAvailableCallback? onLocalizationsAvailable;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        if (onLocalizationsAvailable != null) {
          onLocalizationsAvailable?.call(context.loc);
        }
        return home ??
            Scaffold(
              body: scaffoldBody,
            );
      }),
    );
  }
}

extension LocalizationsExt on WidgetTester {
  /// Retrieves the localizations during a test.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// testWidgets('Verifies localized text', (tester) async {
  ///   final localizations = tester.localizationsFromElement(ImageOptionsMenu);
  ///
  ///   expect(find.text(localizations.successImageDownloaded), findsOneWidget);
  /// });
  /// ```
  FlutterQuillLocalizations localizationsFromElement(Type type) =>
      (element(find.byType(type)) as BuildContext).loc;
}
