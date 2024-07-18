import 'package:flutter/foundation.dart' show immutable;

import '../../document/nodes/leaf.dart';
import '../../document/nodes/line.dart';

@immutable
class SegmentLeafNode {
  const SegmentLeafNode(this.line, this.leaf);

  final Line? line;
  final Leaf? leaf;
}
