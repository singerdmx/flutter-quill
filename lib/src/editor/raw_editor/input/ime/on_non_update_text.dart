import 'package:flutter/services.dart';
import '../../../../../flutter_quill.dart';
import '../../../../../internal.dart';

void onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
  QuillController controller,
) {
  final effectiveSelection = nonTextUpdate.selection;
  // when typing characters with CJK IME on Windows, a non-text update is sent
  // with the selection range.
  if (isWindowsApp) {
    if (nonTextUpdate.composing == TextRange.empty &&
        nonTextUpdate.selection.isCollapsed) {
      controller.updateSelection(
        effectiveSelection,
        ChangeSource.local,
      );
    }
    return;
  }
  controller.updateSelection(
    effectiveSelection,
    ChangeSource.local,
  );
}
