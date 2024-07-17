import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import 'config/editor_configurations.dart';

class QuillEditorProvider extends InheritedWidget {
  const QuillEditorProvider({
    required super.child,
    required this.editorConfigurations,
    super.key,
  });

  final QuillEditorConfigurations editorConfigurations;

  @override
  bool updateShouldNotify(covariant QuillEditorProvider oldWidget) {
    return oldWidget.editorConfigurations != editorConfigurations;
  }

  static QuillEditorProvider? maybeOf(BuildContext context) {
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

extension QuillEditorExt on BuildContext {
  QuillEditorConfigurations get requireQuillEditorConfigurations {
    return QuillEditorProvider.of(this).editorConfigurations;
  }

  QuillEditorConfigurations? get quillEditorConfigurations {
    return QuillEditorProvider.maybeOf(this)?.editorConfigurations;
  }

  QuillEditorElementOptions? get quillEditorElementOptions {
    return quillEditorConfigurations?.elementOptions;
  }

  QuillEditorElementOptions get requireQuillEditorElementOptions {
    return requireQuillEditorConfigurations.elementOptions;
  }
}
