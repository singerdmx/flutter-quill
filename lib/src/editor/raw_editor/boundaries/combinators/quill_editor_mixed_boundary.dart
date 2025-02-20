import 'package:flutter/material.dart';
import '../quill_editor_text_boundary.dart';

// A _TextBoundary that creates a [TextRange] where its start is from the
// specified leading text boundary and its end is from the specified trailing
// text boundary.
class QuillEditorMixedBoundary extends QuillEditorTextBoundary {
  QuillEditorMixedBoundary(this.leadingTextBoundary, this.trailingTextBoundary);

  final QuillEditorTextBoundary leadingTextBoundary;
  final QuillEditorTextBoundary trailingTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(leadingTextBoundary.textEditingValue ==
        trailingTextBoundary.textEditingValue);
    return leadingTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      leadingTextBoundary.getLeadingTextBoundaryAt(position);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) =>
      trailingTextBoundary.getTrailingTextBoundaryAt(position);
}
