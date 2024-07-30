import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import '../controller/quill_controller.dart';
import 'config/editor_configurations.dart';

class QuillEditorProvider extends InheritedWidget {
  QuillEditorProvider({
    required super.child,

    /// Controller and configurations are required but should only be provided from one.
    ///
    /// Passing the controller as part of configurations is being deprecated and will be removed in the future.
    /// Prefer: use controller and set QuillEditorConfigurations in the controller.
    /// Current: use configurations and pass QuillController in constructor for configurations.
    QuillController? controller,
    @Deprecated(
        'editorConfigurations are no longer needed and will be removed in future versions. Set configurations in the controller')
    QuillEditorConfigurations? editorConfigurations,
    super.key,
  })  : editorConfigurations = editorConfigurations ??
            controller?.editorConfigurations ??
            const QuillEditorConfigurations(),
        controller = controller ??
            // ignore: deprecated_member_use_from_same_package
            editorConfigurations?.controller ??
            QuillController.basic();

  final QuillController controller;
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
    value.controller.editorConfigurations = value.editorConfigurations;
    return QuillEditorProvider(
      controller: value.controller,
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
