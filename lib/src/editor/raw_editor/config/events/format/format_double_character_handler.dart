import '../../../../../../quill_delta.dart';
import '../../../../../controller/quill_controller.dart';
import '../../../../../document/attribute.dart';
import '../../../../../document/document.dart';

// We currently have only one format style is triggered by double characters.
// **abc** or __abc__ -> bold abc
enum DoubleCharacterFormatStyle {
  bold, // ** | __
  strikethrough, // ~~
}

bool handleFormatByWrappingWithDoubleCharacter({
  // for demonstration purpose, the following comments use * to represent the character from the parameter [char].
  required QuillController controller,
  required String character,
  required DoubleCharacterFormatStyle formatStyle,
}) {
  assert(character.length == 1, 'Expected 1 char, got ${character.length}');
  final selection = controller.selection;
  // if the selection is not collapsed or the cursor is at the first three index range, we don't need to format it.
  if (!selection.isCollapsed || selection.end < 4) {
    return false;
  }

  final plainText = controller.document.toPlainText();

  if (plainText.isEmpty) {
    return false;
  }
  // The plainText should have at least 4 characters,like **a* or **a*.
  // The last char in the plainText should be *[char]. Otherwise, we don't need to format it.
  if (plainText.length < 4 || plainText[selection.end - 1] != character) {
    return false;
  }

  // find all the index of *[char]
  var charIndexList = <int>[];
  for (var i = selection.end - 1; i > 0; i--) {
    // If we found characters that satifies our handler, and it founds
    // a new line, then, need to cancel the handler
    // because bold (and common styles from markdown) cannot
    // be applied between different paragraphs
    if (charIndexList.isNotEmpty && plainText[i] == '\n') return false;
    if (plainText[i] == character) {
      charIndexList.add(i);
    }
    if (charIndexList.length >= 3) break;
  }

  if (charIndexList.length < 3) {
    return false;
  }

  // to fix a char list like: [5, 1, 0] we reverse the
  // list to transform it as: [0, 1 ,5]
  charIndexList = [...charIndexList.reversed];

  // for example: **abc* -> [0, 1, 5]
  // thirdLastCharIndex = 0, secondLastCharIndex = 1, lastCharIndex = 5
  final thirdLastCharIndex = charIndexList[charIndexList.length - 3];
  final secondLastCharIndex = charIndexList[charIndexList.length - 2];
  final lastCharIndex = charIndexList[charIndexList.length - 1];
  // make sure the third *[char] and second *[char] are connected
  // make sure the second *[char] and last *[char] are split by at least one character
  if (secondLastCharIndex != thirdLastCharIndex + 1 ||
      lastCharIndex == secondLastCharIndex + 1) {
    return false;
  }

  // if is needed, we can use this to get the text inside the double chars
  // final offsetOfTextInsideWrapperCharsLeft = thirdLastCharIndex + (secondLastCharIndex - (thirdLastCharIndex - 1));
  // final offsetOfTextInsideWrapperCharsRight = lastCharIndex - 1;

  late final Attribute? style;

  if (formatStyle case DoubleCharacterFormatStyle.bold) {
    style = const BoldAttribute();
  } else if (formatStyle case DoubleCharacterFormatStyle.strikethrough) {
    style = const StrikeThroughAttribute();
  }
  // 1. delete all the *[char]
  // 2. update the style of the text surrounded by the double *[char] to formatted text style
  final deletionDelta = Delta()
    ..retain(thirdLastCharIndex) // get all text before double chars
    ..delete(2) // delete both start double char
    ..retain(
        lastCharIndex -
            (thirdLastCharIndex +
                (secondLastCharIndex - (thirdLastCharIndex - 1))),
        style == null
            ? null
            : {
                style.key: style.value
              }) // retain the text before last double chars and apply the styles
    ..delete(1); // delete last char

  controller
    ..compose(
      deletionDelta,
      selection,
      ChangeSource.local,
    )
    ..moveCursorToPosition(selection.end - 3);
  return true;
}
