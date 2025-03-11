import 'package:flutter/services.dart';

import '../../../../controller/quill_controller.dart';
import '../../../raw_editor/config/events/character_shortcuts_events.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  final selection = controller.selection;

  final insertionText = insertion.textInserted;

  if (insertionText.length == 1 && !insertionText.contains('\n')) {
    for (final shortcutEvent in characterShortcutEvents) {
      if (shortcutEvent.character == insertionText &&
          shortcutEvent.handler(controller)) {
        return;
      }
    }
  }

  controller.replaceText(
    selection.baseOffset,
    selection.extentOffset - selection.baseOffset,
    insertionText,
    TextSelection.collapsed(
        offset: selection.extentOffset + insertionText.length),
  );
}
