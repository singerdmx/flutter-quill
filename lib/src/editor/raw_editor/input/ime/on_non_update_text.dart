import 'dart:io';
import 'package:flutter/services.dart';
import '../../../../../flutter_quill.dart';

Future<void> onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
  QuillController controller,
) async {
  final effectiveSelection = TextSelection.collapsed(offset: nonTextUpdate.selection.baseOffset);
  // when typing characters with CJK IME on Windows, a non-text update is sent
  // with the selection range.
  if (Platform.isWindows) {
    if (nonTextUpdate.composing == TextRange.empty && nonTextUpdate.selection.isCollapsed) {
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
