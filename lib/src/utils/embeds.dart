import 'dart:math';

import 'package:tuple/tuple.dart';

import '../models/documents/nodes/leaf.dart';
import '../widgets/controller.dart';

Tuple2<int, Embed> getEmbedNode(QuillController controller, int offset) {
  var offset = controller.selection.start;
  var imageNode = controller.queryNode(offset);
  if (imageNode == null || !(imageNode is Embed)) {
    offset = max(0, offset - 1);
    imageNode = controller.queryNode(offset);
  }
  if (imageNode != null && imageNode is Embed) {
    return Tuple2(offset, imageNode);
  }

  return throw 'Embed node not found by offset $offset';
}
