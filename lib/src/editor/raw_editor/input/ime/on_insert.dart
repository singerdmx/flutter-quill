import 'package:flutter/services.dart';

import '../../../../controller/quill_controller.dart';
import '../../../raw_editor/config/events/character_shortcuts_events.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  final selection = insertion.selection;

  final insertionText = insertion.textInserted;

  if (insertionText.length == 1 && !insertionText.contains('\n')) {
    for (final shortcutEvent in characterShortcutEvents) {
      if (shortcutEvent.character == insertionText && shortcutEvent.handler(controller)) {
        return;
      }
    }
  }

  controller.replaceText(
    insertion.insertionOffset,
    selection.extentOffset - selection.baseOffset,
    insertionText,
    TextSelection.collapsed(
      offset: insertion.insertionOffset + insertionText.length,
      affinity: selection.affinity,
    ),
  );
}
