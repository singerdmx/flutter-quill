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
  const QuillTestApp({
    required this.child,
    super.key,
  });

  /// Creates a [QuillTestApp] with a [Scaffold] wrapping the given [body] widget.
static Widget withScaffold(Widget child) {
  return MaterialApp(
    localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
    supportedLocales: FlutterQuillLocalizations.supportedLocales,
    home: Scaffold(
      body: child,
    ),
  );
}

  /// Creates a [QuillTestApp] with the specified [home] widget.
  factory QuillTestApp.home(Widget home,
          {LocalizationsAvailableCallback? onLocalizationsAvailable}) =>
      QuillTestApp(
        child: home,
      );

  /// The home widget for the application.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: child,
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
