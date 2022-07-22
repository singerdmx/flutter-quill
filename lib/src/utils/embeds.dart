import 'dart:math';

import 'package:tuple/tuple.dart';

import '../models/documents/nodes/leaf.dart';
import '../widgets/controller.dart';

Tuple2<int, Embed> getEmbedNode(QuillController controller, int offset) {
  var offset = controller.selection.start;
  var embedNode = controller.queryNode(offset);
  if (embedNode == null || !(embedNode is Embed)) {
    offset = max(0, offset - 1);
    embedNode = controller.queryNode(offset);
  }
  if (embedNode != null && embedNode is Embed) {
    return Tuple2(offset, embedNode);
  }

  return throw 'Embed node not found by offset $offset';
}
