import 'package:flutter/services.dart';
import '../../../../../flutter_quill.dart';

void onDelete(
  TextEditingDeltaDeletion deletion,
  QuillController controller,
) {
  final start = deletion.deletedRange.start;
  final length = deletion.deletedRange.end - start;
  controller.replaceText(
    start,
    length,
    '',
    TextSelection.collapsed(
      offset: deletion.selection.baseOffset.nonNegative,
      affinity: controller.selection.affinity,
    ),
  );
}

extension on int {
  int get nonNegative => this < 0 ? 0 : this;
}
