import 'package:flutter_keyboard_visibility/src/keyboard_visibility_handler.dart';

/// Provides direct information about keyboard visibility and allows you
/// to subscribe to changes.
class KeyboardVisibilityController {
  KeyboardVisibilityController._();

  /// Constructs a singleton instance of [KeyboardVisibilityController].
  ///
  /// [KeyboardVisibilityController] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // EventChannel because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  factory KeyboardVisibilityController() => _instance;

  static final KeyboardVisibilityController _instance =
      KeyboardVisibilityController._();

  Stream<bool> get onChange => KeyboardVisibilityHandler.onChange;

  bool get isVisible => KeyboardVisibilityHandler.isVisible;
}
