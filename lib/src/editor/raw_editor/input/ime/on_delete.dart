import 'package:flutter/services.dart';
import '../../../../../flutter_quill.dart';

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  QuillController controller,
) async {
  final selection = controller.selection;
  if (selection.isCollapsed) {
    final start = deletion.deletedRange.start;
    final length = deletion.deletedRange.end - start;
    controller.replaceText(
      start + 1,
      length,
      '',
      TextSelection.collapsed(
        offset: (selection.baseOffset - 1).nonNegative,
        affinity: controller.selection.affinity,
      ),
    );
    return;
  }
  controller.replaceText(
    selection.baseOffset,
    selection.extentOffset - selection.baseOffset,
    '',
    TextSelection.collapsed(
      offset: selection.start,
      affinity: selection.affinity,
    ),
  );
}

extension on int {
  int get nonNegative => this < 0 ? 0 : this;
}
