import '../../../../../quill_delta.dart';
import '../../../../common/utils/cast.dart';
import '../../../../common/utils/platform.dart';
import '../../../../controller/quill_controller.dart';
import '../../../../document/attribute.dart';
import '../../../../document/nodes/leaf.dart' as leaf;
import '../../../../document/nodes/line.dart';
import 'character_shortcuts_events.dart';
import 'space_shortcut_events.dart';

part 'soft_keyboard_shortcut_support_internal.dart';

/// Provides space/character event emulation on platforms that are not
/// equipped with hardware keyboard (e.g. Android/iOS).
///
/// Emulation is based on diff between delta, so it happens after the change
/// is committed to the document rather than on key press.
class QuillSoftKeyboardShortcutSupport {
  QuillSoftKeyboardShortcutSupport({
    required QuillController controller,
    required List<SpaceShortcutEvent> spaceEvents,
    required List<CharacterShortcutEvent> characterEvents,
  })  : _controller = controller,
        _spaceEvents = spaceEvents,
        _characterEvents = characterEvents;

  final List<SpaceShortcutEvent> _spaceEvents;
  final List<CharacterShortcutEvent> _characterEvents;
  final QuillController _controller;

  bool onNewChar(Delta diffDelta) {
    final containsSelection =
        _controller.selection.baseOffset != _controller.selection.extentOffset;

    final keyPressed = _lastSingleChar(diffDelta);
    if (keyPressed == ' ') {
      final result = _handleSpaceKey(
        _controller,
        _spaceEvents,
      );

      if (result) {
        _controller.removeLastChar();

        return true;
      }
    } else if (keyPressed != null && keyPressed != '\n' && !containsSelection) {
      for (final charEvents in _characterEvents) {
        if (keyPressed == charEvents.character) {
          final executed = charEvents.execute(_controller);

          if (executed) {
            _controller.removeLastChar(endFormatting: true);

            return true;
          }
        }
      }
    }

    return false;
  }

  static String? _lastSingleChar(Delta diff) {
    if (diff.operations.length == 2) {
      final firstOp = diff.operations.first;
      final lastOp = diff.operations.last;
      if (firstOp.isRetain && lastOp.isInsert && lastOp.length == 1) {
        final lastOpData = lastOp.data;
        if (lastOpData is String) {
          return lastOpData;
        }
      }
    }

    return null;
  }

  /// this class should only be used on mobile devices to emulate space/character
  /// key press events
  static bool get isSupported => isAndroidApp || isIosApp;

  /// shared assert message
  static const assertMessage =
      'softKeyboardShortcutSupport should only be used on Android/iOS';
}
