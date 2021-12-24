import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuillPressedKeys extends ChangeNotifier {
  static QuillPressedKeys of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_QuillPressedKeysAccess>();
    return widget!.pressedKeys;
  }

  bool _metaPressed = false;
  bool _controlPressed = false;

  /// Whether meta key is currently pressed.
  bool get metaPressed => _metaPressed;

  /// Whether control key is currently pressed.
  bool get controlPressed => _controlPressed;

  void _updatePressedKeys(Set<LogicalKeyboardKey> pressedKeys) {
    final meta = pressedKeys.contains(LogicalKeyboardKey.metaLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.metaRight);
    final control = pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.controlRight);
    if (_metaPressed != meta || _controlPressed != control) {
      _metaPressed = meta;
      _controlPressed = control;
      notifyListeners();
    }
  }
}

class QuillKeyboardListener extends StatefulWidget {
  const QuillKeyboardListener({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  QuillKeyboardListenerState createState() => QuillKeyboardListenerState();
}

class QuillKeyboardListenerState extends State<QuillKeyboardListener> {
  final QuillPressedKeys _pressedKeys = QuillPressedKeys();

  bool _keyEvent(KeyEvent event) {
    _pressedKeys
        ._updatePressedKeys(HardwareKeyboard.instance.logicalKeysPressed);
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyEvent);
    _pressedKeys
        ._updatePressedKeys(HardwareKeyboard.instance.logicalKeysPressed);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyEvent);
    _pressedKeys.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _QuillPressedKeysAccess(
      pressedKeys: _pressedKeys,
      child: widget.child,
    );
  }
}

class _QuillPressedKeysAccess extends InheritedWidget {
  const _QuillPressedKeysAccess({
    required this.pressedKeys,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final QuillPressedKeys pressedKeys;

  @override
  bool updateShouldNotify(covariant _QuillPressedKeysAccess oldWidget) {
    return oldWidget.pressedKeys != pressedKeys;
  }
}
