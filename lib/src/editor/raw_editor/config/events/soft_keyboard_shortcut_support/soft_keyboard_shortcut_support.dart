import 'package:meta/meta.dart' show experimental;

import '../../../../../../quill_delta.dart';
import '../../../../../common/utils/cast.dart';
import '../../../../../common/utils/platform.dart';
import '../../../../../controller/quill_controller.dart';
import '../../../../../document/attribute.dart';
import '../../../../../document/nodes/leaf.dart' as leaf;
import '../../../../../document/nodes/line.dart';
import '../events.dart';
import 'standard_char_shortcuts/soft_keyboard_standard_shortcut_events.dart';

part 'soft_keyboard_shortcut_support_internal.dart';

/// Provides space/character event emulation on platforms that are not
/// equipped with hardware keyboard (e.g. Android/iOS).
///
/// Emulation is based on delta update, so it happens after the change
/// is committed to the document rather than on key press.
@experimental
class QuillSoftKeyboardShortcutSupport {
  QuillSoftKeyboardShortcutSupport({
    List<SpaceShortcutEvent>? spaceEvents,
    List<CharacterShortcutEvent>? charactedEvents,
  }) {
    assert(isSupported, assertMessage);
    _spaceEvents = spaceEvents ?? defaultSpaceEvents;
    _charactedEvents = charactedEvents ?? defaultCharacterEvents;
  }

  late List<SpaceShortcutEvent> _spaceEvents;
  late List<CharacterShortcutEvent> _charactedEvents;

  static List<SpaceShortcutEvent> get defaultSpaceEvents =>
      softKeyboardStandardSpaceShorcutEvents;
  static List<CharacterShortcutEvent> get defaultCharacterEvents =>
      softKeyboardStandardCharactersShortcutEvents;

  QuillController? _controller;

  void attachTo(QuillController controller) {
    detach();
    controller.addOnReplacedText(onReplacedText);
    _controller = controller;
  }

  void detach() {
    _controller?.removeOnReplacedText(onReplacedText);
    _controller = null;
  }

  void onReplacedText(int index, int len, Object? data, Delta? delta,
      ReplaceTextSource source) {
    final controller = _controller;
    var isNewCharDelta = false;
    if (source != ReplaceTextSource.inputClient || controller == null) {
      return;
    }

    if (len == 0 && data is String && data.length == 1) {
      isNewCharDelta = true;
    }

    if (delta != null && isNewCharDelta) {
      _onNewChar(delta, controller, _spaceEvents, _charactedEvents);
    }
  }

  static bool _onNewChar(
      Delta diffDelta,
      QuillController controller,
      List<SpaceShortcutEvent> spaceEvents,
      List<CharacterShortcutEvent> characterEvents) {
    assert(isSupported, assertMessage);

    final containsSelection =
        controller.selection.baseOffset != controller.selection.extentOffset;

    final keyPressed = _lastSingleChar(diffDelta);
    if (keyPressed == ' ') {
      final result = _handleSpaceKey(
        controller,
        spaceEvents,
      );

      if (result) {
        controller.removeLastChar();

        return true;
      }
    } else if (keyPressed != null && keyPressed != '\n' && !containsSelection) {
      for (final charEvents in characterEvents) {
        if (keyPressed == charEvents.character) {
          final executed = charEvents.execute(controller);

          if (executed) {
            controller.removeLastChar(endFormatting: true);

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
