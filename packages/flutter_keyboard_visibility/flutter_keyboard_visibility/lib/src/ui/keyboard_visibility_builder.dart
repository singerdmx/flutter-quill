import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/src/keyboard_visibility_controller.dart';

/// A convenience builder that exposes if the native keyboard is visible.
class KeyboardVisibilityBuilder extends StatelessWidget {
  /// Optional: pass in a controller you already have created. This is useful
  /// for testing, as you can pass in a mock instance. If no controller is
  /// passed in, one will be created automatically.
  final KeyboardVisibilityController? controller;

  KeyboardVisibilityController get _controller =>
      controller ?? KeyboardVisibilityController();

  const KeyboardVisibilityBuilder({
    Key? key,
    required this.builder,
    this.controller,
  }) : super(key: key);

  /// A builder method that exposes if the native keyboard is visible.
  final Widget Function(BuildContext, bool isKeyboardVisible) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _controller.onChange,
      initialData: _controller.isVisible,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return builder(context, snapshot.data!);
        } else {
          return builder(context, false);
        }
      },
    );
  }
}
