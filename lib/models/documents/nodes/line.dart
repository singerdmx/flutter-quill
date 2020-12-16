import 'package:quill_delta/quill_delta.dart';

import 'block.dart';
import 'container.dart';
import 'leaf.dart';

class Line extends Container<Leaf> {

  @override
  Leaf get defaultChild => Text();

  @override
  int get length => super.length + 1;

  @override
  Delta toDelta() {
    final delta = children
        .map((child) => child.toDelta())
        .fold(Delta(), (a, b) => a.concat(b));
    var attributes = style;
    if (parent is Block) {
      Block block = parent;
      attributes = attributes.mergeAll(block.style);
    }
    delta.insert('\n', attributes.toJson());
    return delta;
  }

  @override
  String toPlainText() => super.toPlainText() + '\n';
}
