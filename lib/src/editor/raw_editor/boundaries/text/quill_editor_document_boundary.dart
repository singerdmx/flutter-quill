import 'package:flutter/services.dart';
import '../quill_editor_text_boundary.dart';

// The document boundary is unique and is a constant function of the input
// position.
class QuillEditorDocumentBoundary extends QuillEditorTextBoundary {
  const QuillEditorDocumentBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      const TextPosition(offset: 0);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textEditingValue.text.length,
      affinity: TextAffinity.upstream,
    );
  }
}
