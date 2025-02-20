import 'package:flutter/services.dart';

import '../quill_editor_text_boundary.dart';

// Expands the innerTextBoundary with outerTextBoundary.
class QuillEditorExpandedTextBoundary extends QuillEditorTextBoundary {
  QuillEditorExpandedTextBoundary(
      this.innerTextBoundary, this.outerTextBoundary);

  final QuillEditorTextBoundary innerTextBoundary;
  final QuillEditorTextBoundary outerTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(innerTextBoundary.textEditingValue ==
        outerTextBoundary.textEditingValue);
    return innerTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getLeadingTextBoundaryAt(
      innerTextBoundary.getLeadingTextBoundaryAt(position),
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getTrailingTextBoundaryAt(
      innerTextBoundary.getTrailingTextBoundaryAt(position),
    );
  }
}
