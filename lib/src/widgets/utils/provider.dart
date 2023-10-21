import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show BuildContext, InheritedWidget, Widget;

import '../../models/config/quill_configurations.dart';

class QuillProvider extends InheritedWidget {
  const QuillProvider({
    required this.configurations,
    required super.child,
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
