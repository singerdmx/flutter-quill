import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import 'config/simple_toolbar_configurations.dart';

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

extension QuillSimpleToolbarExt on BuildContext {
  QuillSimpleToolbarConfigurations get requireQuillSimpleToolbarConfigurations {
    return QuillSimpleToolbarProvider.of(this).toolbarConfigurations;
  }

  QuillSimpleToolbarConfigurations? get quillSimpleToolbarConfigurations {
    return QuillSimpleToolbarProvider.maybeOf(this)?.toolbarConfigurations;
  }

  QuillToolbarBaseButtonOptions? get quillToolbarBaseButtonOptions {
    return quillSimpleToolbarConfigurations?.buttonOptions.base;
  }
}
