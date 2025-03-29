part of 'ime_internals.dart';

void onInsert(
  TextEditingDeltaInsertion insertion,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) {
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
    insertion.insertionOffset,
    selection.extentOffset - selection.baseOffset,
    insertionText,
    TextSelection.collapsed(
      offset: insertion.insertionOffset + insertionText.length,
      affinity: selection.affinity,
    ),
  );
}
