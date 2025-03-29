part of 'ime_internals.dart';

void onReplace(
  TextEditingDeltaReplacement replacement,
  QuillController controller,
  List<CharacterShortcutEvent> characterShortcutEvents,
) {
  // delete the selection
  final selection = controller.selection;

  final textReplacement = replacement.replacementText;

  if (selection.isCollapsed && isIosApp && textReplacement.endsWith('\n')) {
    // remove the trailing '\n' when pressing the return key
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
