import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum InputShortcut { CUT, COPY, PASTE, SELECT_ALL }

typedef CursorMoveCallback = void Function(
    LogicalKeyboardKey key, bool wordModifier, bool lineModifier, bool shift);
typedef InputShortcutCallback = void Function(InputShortcut? shortcut);
typedef OnDeleteCallback = void Function(bool forward);

class KeyboardListener {
  KeyboardListener(this.onCursorMove, this.onShortcut, this.onDelete);

  final CursorMoveCallback onCursorMove;
  final InputShortcutCallback onShortcut;
  final OnDeleteCallback onDelete;

  static final Set<LogicalKeyboardKey> _moveKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
  };

  static final Set<LogicalKeyboardKey> _shortcutKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.delete,
    LogicalKeyboardKey.backspace,
  };

  static final Set<LogicalKeyboardKey> _nonModifierKeys = <LogicalKeyboardKey>{
    ..._shortcutKeys,
    ..._moveKeys,
  };

  static final Set<LogicalKeyboardKey> _modifierKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.alt,
  };

  static final Set<LogicalKeyboardKey> _macOsModifierKeys =
      <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.alt,
  };

  static final Set<LogicalKeyboardKey> _interestingKeys = <LogicalKeyboardKey>{
    ..._modifierKeys,
    ..._macOsModifierKeys,
    ..._nonModifierKeys,
  };

  static final Map<LogicalKeyboardKey, InputShortcut> _keyToShortcut = {
    LogicalKeyboardKey.keyX: InputShortcut.CUT,
    LogicalKeyboardKey.keyC: InputShortcut.COPY,
    LogicalKeyboardKey.keyV: InputShortcut.PASTE,
    LogicalKeyboardKey.keyA: InputShortcut.SELECT_ALL,
  };

  KeyEventResult handleRawKeyEvent(RawKeyEvent event) {
    if (kIsWeb) {
      // On web platform, we ignore the key because it's already processed.
      return KeyEventResult.ignored;
    }

    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final keysPressed =
        LogicalKeyboardKey.collapseSynonyms(RawKeyboard.instance.keysPressed);
    final key = event.logicalKey;
    final isMacOS = event.data is RawKeyEventDataMacOs;
    if (!_nonModifierKeys.contains(key) ||
        keysPressed
                .difference(isMacOS ? _macOsModifierKeys : _modifierKeys)
                .length >
            1 ||
        keysPressed.difference(_interestingKeys).isNotEmpty) {
      return KeyEventResult.ignored;
    }

    if (_moveKeys.contains(key)) {
      onCursorMove(
          key,
          isMacOS ? event.isAltPressed : event.isControlPressed,
          isMacOS ? event.isMetaPressed : event.isAltPressed,
          event.isShiftPressed);
    } else if (isMacOS
        ? event.isMetaPressed
        : event.isControlPressed && _shortcutKeys.contains(key)) {
      onShortcut(_keyToShortcut[key]);
    } else if (key == LogicalKeyboardKey.delete) {
      onDelete(true);
    } else if (key == LogicalKeyboardKey.backspace) {
      onDelete(false);
    }
    return KeyEventResult.ignored;
  }
}
