import '../../../../../controller/quill_controller.dart';
import '../../../../../document/attribute.dart';
import '../../../../../document/document.dart';

enum BlockFormatStyle {
  todo,
  bullet,
  ordered,
  header,
}

bool handleFormatBlockStyleBySpaceEvent({
  required QuillController controller,
  required String character,
  required BlockFormatStyle formatStyle,
}) {
  assert(character.trim().isNotEmpty && character != '\n',
      'Expected character that cannot be empty, a whitespace or a new line. Got $character');
  if (formatStyle == BlockFormatStyle.todo) {
    _updateSelectionForKeyPhrase(character, Attribute.unchecked, controller);
    return true;
  } else if (formatStyle == BlockFormatStyle.bullet) {
    _updateSelectionForKeyPhrase(character, Attribute.ul, controller);
    return true;
  } else if (formatStyle == BlockFormatStyle.ordered) {
    _updateSelectionForKeyPhrase(character, Attribute.ol, controller);
    return true;
  } else if (formatStyle == BlockFormatStyle.header) {
    var headerAttribute = Attribute.header as Attribute<int?>;
    final count = _count(character, '#');
    if (count == 1) {
      headerAttribute = Attribute.h1;
    } else if (count == 2) {
      headerAttribute = Attribute.h2;
    } else if (count == 3) {
      headerAttribute = Attribute.h3;
    }
    _updateSelectionForKeyPhrase(character, headerAttribute, controller);
    return true;
  }

  return false;
}

void _updateSelectionForKeyPhrase(
    String phrase, Attribute attribute, QuillController controller) {
  controller.replaceText(controller.selection.baseOffset - phrase.length,
      phrase.length, '\n', null);
  _moveCursor(-phrase.length, controller);
  controller
    ..formatSelection(attribute)
    // Remove the added newline.
    ..replaceText(controller.selection.baseOffset + 1, 1, '', null);
}

void _moveCursor(int chars, QuillController controller) {
  final selection = controller.selection;
  controller.updateSelection(
      controller.selection.copyWith(
          baseOffset: selection.baseOffset + chars,
          extentOffset: selection.baseOffset + chars),
      ChangeSource.local);
}

int _count(String char, String matchChar) {
  var count = 0;
  for (var i = 0; i < char.length; i++) {
    if (char[i] == matchChar) {
      count++;
    } else {
      break;
    }
  }
  return count;
}
