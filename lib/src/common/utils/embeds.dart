import 'dart:math';

import '../../controller/quill_controller.dart';
import '../../document/nodes/leaf.dart';
import '../structs/offset_value.dart';

OffsetValue<Embed> getEmbedNode(QuillController controller, int offset) {
  var offset = controller.selection.start;
  var embedNode = controller.queryNode(offset);
  if (embedNode == null || embedNode is! Embed) {
    offset = max(0, offset - 1);
    embedNode = controller.queryNode(offset);
  }
  if (embedNode != null && embedNode is Embed) {
    return OffsetValue(offset, embedNode);
  }

  return throw ArgumentError('Embed node not found by offset $offset');
}
