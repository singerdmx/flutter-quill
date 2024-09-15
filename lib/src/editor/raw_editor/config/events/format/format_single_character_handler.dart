import '../../../../../../quill_delta.dart';
import '../../../../../controller/quill_controller.dart';
import '../../../../../document/attribute.dart';
import '../../../../../document/document.dart';

enum SingleCharacterFormatStyle {
  code,
  italic,
  strikethrough,
}

// for demonstration purpose, the following comments use * to represent the character from the parameter [char].
bool handleFormatByWrappingWithSingleCharacter({
  required QuillController controller,
  required String character,
  required SingleCharacterFormatStyle formatStyle,
}) {
  assert(character.length == 1, 'Expected 1 char, got ${character.length}.');
  final selection = controller.selection;
  // If the selection is not collapsed or the cursor is at the first two index range, we don't need to format it.
  if (!selection.isCollapsed || selection.end < 2) {
    return false;
  }

  final plainText = controller.document.toPlainText();

  if (plainText.isEmpty) {
    return false;
  }

  // The plainText should have at least 2 characters, like *a.
  if (plainText.length < 2) {
    return false;
  }

  var lastCharIndex = -1;
  // found the nearest using the caret position as base
  for (var i = selection.end - 1; i > 0; i--) {
    // If we found characters that satifies our handler, and it founds
    // a new line, then, need to cancel the handler
    // because bold (and common styles from markdown) cannot
    // be applied between different paragraphs
    if (plainText[i] == '\n' && lastCharIndex == -1) return false;

    if (plainText[i] == character) {
      lastCharIndex = i;
      break;
    }
  }

  // We check this because we don't know if the text that we are trying
  // to detect, is at the start of the document (this is because by some weird
  // reason, the for never detects the character)
  if (plainText[0] == character) {
    lastCharIndex = _toSafeInteger(lastCharIndex);
  }
  if (lastCharIndex == -1) {
    return false;
  }

  final textAfterLastChar =
      plainText.substring(lastCharIndex + 1, selection.end);
  final textAfterLastCharIsEmpty = textAfterLastChar.trim().isEmpty;

  // The following conditions won't trigger the single character formatting:
  // 1. There is no 'Character' in the plainText since by default is -1.
  if (textAfterLastCharIsEmpty) {
    return false;
  }

  // If it is in a double character case, we should skip the single character formatting.
  // For example, adding * after **a*, it should skip the single character formatting and it
  // will be handled by double character formatting.
  if ((character == '*' || character == '_' || character == '~') &&
      (lastCharIndex >= 1) &&
      (plainText[lastCharIndex - 1] == character)) {
    return false;
  }

  late final Attribute? style;

  if (formatStyle case SingleCharacterFormatStyle.italic) {
    style = const ItalicAttribute();
  } else if (formatStyle case SingleCharacterFormatStyle.strikethrough) {
    style = const StrikeThroughAttribute();
  } else if (formatStyle case SingleCharacterFormatStyle.code) {
    style = const InlineCodeAttribute();
  }
  // 1. delete all the *[char]
  // 2. update the style of the text surrounded by the *[char] to a formatted text style
  final deletionDelta = Delta()
    ..retain(lastCharIndex) // get all text before chars
    ..delete(1) // delete both start char
    ..retain(
        (selection.end - 2) - (lastCharIndex - 1),
        style == null
            ? null
            : {
                style.key: style.value
              }); // retain the text before that the new char that we type on keyboard

  controller
    ..compose(
      deletionDelta,
      selection,
      ChangeSource.local,
    )
    ..moveCursorToPosition(selection.end - 1);
  return true;
}

int _toSafeInteger(int value) => value <= -1 ? 0 : value;
