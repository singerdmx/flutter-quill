import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import 'config/toolbar_configurations.dart';

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

extension QuillToolbarExt on BuildContext {
  /// return [QuillToolbarConfigurations] as not null
  QuillToolbarConfigurations get requireQuillToolbarConfigurations {
    return QuillToolbarProvider.of(this).toolbarConfigurations;
  }

  /// return nullable [QuillToolbarConfigurations].
  QuillToolbarConfigurations? get quillToolbarConfigurations {
    return QuillToolbarProvider.maybeOf(this)?.toolbarConfigurations;
  }
}
