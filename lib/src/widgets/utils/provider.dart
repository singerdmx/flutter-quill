import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import '../../models/config/quill_configurations.dart';
import '../../models/config/toolbar/base_toolbar_configurations.dart';

class QuillProvider extends InheritedWidget {
  const QuillProvider({
    required this.configurations,
    required super.child,
    super.key,
  });

  /// Controller object which establishes a link between a rich text document
  /// and this editor.
  ///
  /// Must not be null.
  final QuillConfigurations configurations;

  @override
  bool updateShouldNotify(covariant QuillProvider oldWidget) {
    return oldWidget.configurations != configurations;
  }

  static QuillProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<QuillProvider>();
  }

  static QuillProvider ofNotNull(BuildContext context) {
    final provider = of(context);
    if (provider == null) {
      if (kDebugMode) {
        debugPrint(
          'The quill provider must be provided in the widget tree.',
        );
      }
      throw ArgumentError.checkNotNull(
        'You are using a widget in the Flutter quill library that require '
            'The Quill provider widget to be in the parent widget tree '
            'because '
            'The provider is $provider. Please make sure to wrap this widget'
            ' with'
            ' QuillProvider widget. '
            'You might using QuillEditor and QuillToolbar so make sure to'
            ' wrap them with the quill provider widget and setup the required '
            'configurations',
        'QuillProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillProvider] instance as value instead of creating new
  /// widget
  static QuillProvider value({
    required QuillProvider value,
    required Widget child,
  }) {
    return QuillProvider(
      configurations: value.configurations,
      child: child,
    );
  }
}

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

  static QuillToolbarProvider? of(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context.dependOnInheritedWidgetOfExactType<QuillToolbarProvider>();
  }

  static QuillToolbarProvider ofNotNull(BuildContext context) {
    final provider = of(context);
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
        'QuillProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillToolbarProvider] instance as value instead of creating
  /// new widget
  static QuillToolbarProvider value({
    required QuillToolbarProvider value,
    required Widget child,
  }) {
    return QuillToolbarProvider(
      toolbarConfigurations: value.toolbarConfigurations,
      child: child,
    );
  }
}

// Not really needed
class QuillBaseToolbarProvider extends InheritedWidget {
  const QuillBaseToolbarProvider({
    required super.child,
    required this.toolbarConfigurations,
    super.key,
  });

  /// The configurations for the toolbar widget of flutter quill
  final QuillBaseToolbarConfigurations toolbarConfigurations;

  @override
  bool updateShouldNotify(covariant QuillBaseToolbarProvider oldWidget) {
    return oldWidget.toolbarConfigurations != toolbarConfigurations;
  }

  static QuillBaseToolbarProvider? of(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context
        .dependOnInheritedWidgetOfExactType<QuillBaseToolbarProvider>();
  }

  static QuillBaseToolbarProvider ofNotNull(BuildContext context) {
    final provider = of(context);
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
        'QuillProvider',
      );
    }
    return provider;
  }

  /// To pass the [QuillBaseToolbarConfigurations] instance as value
  /// instead of creating new widget
  static QuillBaseToolbarProvider value({
    required QuillBaseToolbarConfigurations value,
    required Widget child,
  }) {
    return QuillBaseToolbarProvider(
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

  static QuillEditorProvider? of(BuildContext context) {
    /// The configurations for the quill editor widget of flutter quill
    return context.dependOnInheritedWidgetOfExactType<QuillEditorProvider>();
  }

  static QuillEditorProvider ofNotNull(BuildContext context) {
    final provider = of(context);
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
        'QuillProvider',
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
