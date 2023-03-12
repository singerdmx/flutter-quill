import '../documents/nodes/leaf.dart';
import '../documents/nodes/line.dart';

class SegmentLeafNode {
  const SegmentLeafNode(this.line, this.leaf);

  final Line? line;
  final Leaf? leaf;
}
