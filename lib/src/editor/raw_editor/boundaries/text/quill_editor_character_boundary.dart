import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../quill_editor_text_boundary.dart';

// Most apps delete the entire grapheme when the backspace key is pressed.
// Also always put the new caret location to character boundaries to avoid
// sending malformed UTF-16 code units to the paragraph builder.
class QuillEditorCharacterBoundary extends QuillEditorTextBoundary {
  const QuillEditorCharacterBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    return TextPosition(
      offset:
          CharacterRange.at(textEditingValue.text, position.offset, endOffset)
              .stringBeforeLength,
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    final range =
        CharacterRange.at(textEditingValue.text, position.offset, endOffset);
    return TextPosition(
      offset: textEditingValue.text.length - range.stringAfterLength,
    );
  }

  @override
  TextRange getTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    final range =
        CharacterRange.at(textEditingValue.text, position.offset, endOffset);
    return TextRange(
      start: range.stringBeforeLength,
      end: textEditingValue.text.length - range.stringAfterLength,
    );
  }
}
