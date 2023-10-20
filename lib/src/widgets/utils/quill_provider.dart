import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart' show InheritedWidget, BuildContext;

import '../../core/quill_configurations.dart';

class QuillProvider extends InheritedWidget {
  const QuillProvider({
    required this.configurations,
    required super.child,
  });

  final QuillConfigurations configurations;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    throw false;
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
      throw ArgumentError.checkNotNull(provider, 'QuillProvider');
    }
    return provider;
  }
}
