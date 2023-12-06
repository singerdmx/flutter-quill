import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import '../../models/config/quill_configurations.dart';
import '../../models/config/toolbar/toolbar_configurations.dart';

class QuillSimpleToolbarProvider extends InheritedWidget {
  const QuillSimpleToolbarProvider({
    required super.child,
    required this.toolbarConfigurations,
    super.key,
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillSimpleToolbarConfigurations toolbarConfigurations;

  @override
  bool updateShouldNotify(covariant QuillSimpleToolbarProvider oldWidget) {
    return oldWidget.toolbarConfigurations != toolbarConfigurations;
  }

  static QuillSimpleToolbarProvider? maybeOf(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context
        .dependOnInheritedWidgetOfExactType<QuillSimpleToolbarProvider>();
  }

  static QuillSimpleToolbarProvider of(BuildContext context) {
    final provider = maybeOf(context);
    if (provider == null) {
      if (kDebugMode) {
        debugPrint(
          'The quill toolbar provider must be provided in the widget tree.',
        );
      }
      throw ArgumentError.checkNotNull(
        'You are using a widget in the Flutter quill library that require '
            'The Quill toolbar provider widget to be in the parent widget tree '
            'because '
            'The provider is $provider. Please make sure to wrap this widget'
            ' with'
            ' QuillToolbarProvider widget. '
            'You might using QuillToolbar so make sure to'
            ' wrap them with the quill provider widget and setup the required '
            'configurations',
        'QuillSimpleToolbarProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillSimpleToolbarProvider] instance as value instead of creating
  /// new widget
  static QuillSimpleToolbarProvider value({
    required QuillSimpleToolbarProvider value,
    required Widget child,
  }) {
    return QuillSimpleToolbarProvider(
      toolbarConfigurations: value.toolbarConfigurations,
      child: child,
    );
  }
}

// Not really needed
class QuillToolbarProvider extends InheritedWidget {
  const QuillToolbarProvider({
    required super.child,
    required this.toolbarConfigurations,
    super.key,
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillToolbarConfigurations toolbarConfigurations;

  @override
  bool updateShouldNotify(covariant QuillToolbarProvider oldWidget) {
    return oldWidget.toolbarConfigurations != toolbarConfigurations;
  }

  static QuillToolbarProvider? maybeOf(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context.dependOnInheritedWidgetOfExactType<QuillToolbarProvider>();
  }

  static QuillToolbarProvider of(BuildContext context) {
    final provider = maybeOf(context);
    if (provider == null) {
      if (kDebugMode) {
        debugPrint(
          'The quill toolbar provider must be provided in the widget tree.',
        );
      }
      throw ArgumentError.checkNotNull(
        'You are using a widget in the Flutter quill library that require '
            'The Quill toolbar provider widget to be in the parent widget tree '
            'because '
            'The provider is $provider. Please make sure to wrap this widget'
            ' with'
            ' QuillBaseToolbarProvider widget. '
            'You might using QuillBaseToolbar so make sure to'
            ' wrap them with the quill provider widget and setup the required '
            'configurations',
        'QuillToolbarProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillToolbarConfigurations] instance as value
  /// instead of creating new widget
  static QuillToolbarProvider value({
    required QuillToolbarConfigurations value,
    required Widget child,
  }) {
    return QuillToolbarProvider(
      toolbarConfigurations: value,
      child: child,
    );
  }
}

class QuillEditorProvider extends InheritedWidget {
  const QuillEditorProvider({
    required super.child,
    required this.editorConfigurations,
    super.key,
  });

  /// The configurations for the quill editor widget of flutter quill
  final QuillEditorConfigurations editorConfigurations;

  @override
  bool updateShouldNotify(covariant QuillEditorProvider oldWidget) {
    return oldWidget.editorConfigurations != editorConfigurations;
  }

  static QuillEditorProvider? maybeOf(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context.dependOnInheritedWidgetOfExactType<QuillEditorProvider>();
  }

  static QuillEditorProvider of(BuildContext context) {
    final provider = maybeOf(context);
    if (provider == null) {
      if (kDebugMode) {
        debugPrint(
          'The quill editor provider must be provided in the widget tree.',
        );
      }
      throw ArgumentError.checkNotNull(
        'You are using a widget in the Flutter quill library that require '
            'The Quill editor provider widget to be in the parent widget tree '
            'because '
            'The provider is $provider. Please make sure to wrap this widget'
            ' with'
            ' QuillEditorProvider widget. '
            'You might using QuillEditor so make sure to'
            ' wrap them with the quill provider widget and setup the required '
            'configurations',
        'QuillEditorProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillEditorProvider] instance as value instead of creating
  /// new widget
  static QuillEditorProvider value({
    required QuillEditorProvider value,
    required Widget child,
  }) {
    return QuillEditorProvider(
      editorConfigurations: value.editorConfigurations,
      child: child,
    );
  }
}
