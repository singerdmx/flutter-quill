import 'package:flutter/services.dart';
import '../../../../../internal.dart';
import '../../../../controller/quill_controller.dart';
import '../../../raw_editor/config/events/character_shortcuts_events.dart';
import 'on_insert.dart';

Future<void> onReplace(
  TextEditingDeltaReplacement replacement,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  // delete the selection
  final selection = replacement.selection;

  final textReplacement = replacement.replacementText;

  if (selection.isCollapsed) {
    if (textReplacement.length == 1) {
      for (final shortcutEvent in characterShortcutEvents) {
        if (shortcutEvent.character == textReplacement && shortcutEvent.handler(controller)) {
          return;
        }
      }
    }

    if (isIosApp) {
      // remove the trailing '\n' when pressing the return key
      if (textReplacement.endsWith('\n')) {
        replacement = TextEditingDeltaReplacement(
          oldText: replacement.oldText,
          replacementText: replacement.replacementText.substring(
            0,
            replacement.replacementText.length - 1,
          ),
          replacedRange: replacement.replacedRange,
          selection: replacement.selection,
          composing: replacement.composing,
        );
      }
    }

    final insertion = replacement.toInsertion();
    await onInsert(
      insertion,
      controller,
      characterShortcutEvents,
    );
  } else {
    final start = replacement.replacedRange.start;
    final length = replacement.replacedRange.end - start;
    controller.replaceText(
      start,
      length,
      replacement.replacementText,
      TextSelection.collapsed(
        offset: selection.baseOffset,
        affinity: selection.affinity,
      ),
    );
  }
}

extension on TextEditingDeltaReplacement {
  TextEditingDeltaInsertion toInsertion() {
    final text = oldText.replaceRange(
      replacedRange.start,
      replacedRange.end,
      '',
    );
    return TextEditingDeltaInsertion(
      oldText: text,
      textInserted: replacementText,
      insertionOffset: replacedRange.start,
      selection: selection,
      composing: composing,
    );
  }
}
