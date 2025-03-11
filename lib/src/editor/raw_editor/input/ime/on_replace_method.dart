import 'dart:io';

import 'package:flutter/services.dart';

import '../../../../controller/quill_controller.dart';
import '../../../raw_editor/config/events/character_shortcuts_events.dart';
import 'on_insert.dart';

Future<void> onReplace(
  TextEditingDeltaReplacement replacement,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  // delete the selection
  final selection = controller.selection;

  final textReplacement = replacement.replacementText;

  if (selection.isCollapsed) {
    if (textReplacement.length == 1) {
      for (final shortcutEvent in characterShortcutEvents) {
        if (shortcutEvent.character == textReplacement &&
            shortcutEvent.handler(controller)) {
          return;
        }
      }
    }

    if (Platform.isIOS) {
      // remove the trailing '\n' when pressing the return key
      if (textReplacement.endsWith('\n')) {
        replacement = TextEditingDeltaReplacement(
          oldText: replacement.oldText,
          replacementText: replacement.replacementText
              .substring(0, replacement.replacementText.length - 1),
          replacedRange: replacement.replacedRange,
          selection: replacement.selection,
          composing: replacement.composing,
        );
      }
    }

    final start = replacement.replacedRange.start;
    final length = replacement.replacedRange.end - start;
    controller.replaceText(
      start,
      length,
      textReplacement,
      TextSelection.collapsed(
          offset: replacement.selection.baseOffset + textReplacement.length),
    );
  } else {
    controller.replaceText(
      selection.baseOffset,
      selection.extentOffset - selection.baseOffset,
      '',
      TextSelection.collapsed(
        offset: selection.baseOffset,
      ),
    );
    // insert the replacement
    final insertion = replacement.toInsertion();
    await onInsert(
      insertion,
      controller,
      characterShortcutEvents,
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
