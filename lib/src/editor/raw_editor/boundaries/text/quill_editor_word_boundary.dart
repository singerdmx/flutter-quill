import 'package:flutter/services.dart';
import '../quill_editor_text_boundary.dart';

// [UAX #29](https://unicode.org/reports/tr29/) defined word boundaries.
class QuillEditorWordBoundary extends QuillEditorTextBoundary {
  const QuillEditorWordBoundary(this.textLayout, this.textEditingValue);

  final TextLayoutMetrics textLayout;

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).start,
      // Word boundary seems to always report downstream on many platforms.
      affinity: TextAffinity.downstream,
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).end,
      // Word boundary seems to always report downstream on many platforms.
      affinity: TextAffinity.downstream,
    );
  }
}
