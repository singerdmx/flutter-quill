import 'dart:io';
import 'package:flutter/services.dart';
import '../../../../../flutter_quill.dart';

Future<void> onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
  QuillController controller,
) async {
  // update the selection on Windows
  //
  // when typing characters with CJK IME on Windows, a non-text update is sent
  // with the selection range.
  if (Platform.isWindows) {
    if (nonTextUpdate.composing == TextRange.empty && nonTextUpdate.selection.isCollapsed) {
      controller.updateSelection(
        TextSelection.collapsed(
          offset: nonTextUpdate.selection.start,
        ),
        ChangeSource.local,
      );
    }
  } else if (Platform.isLinux || Platform.isMacOS) {
    controller.updateSelection(
      TextSelection.collapsed(
        offset: nonTextUpdate.selection.start,
      ),
      ChangeSource.local,
    );
  }
}
