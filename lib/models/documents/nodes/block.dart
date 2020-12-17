import 'package:quill_delta/quill_delta.dart';

import 'container.dart';
import 'line.dart';
import 'node.dart';

class Block extends Container<Line> {
  @override
  Line get defaultChild => Line();

  @override
  Delta toDelta() {
    return children
        .map((child) => child.toDelta())
        .fold(Delta(), (a, b) => a.concat(b));
  }

  @override
  adjust() {
    if (isEmpty) {
      Node sibling = previous;
      unlink();
      if (sibling != null) {
        sibling.adjust();
      }
      return;
    }

    Block block = this;
    Node prev = block.previous;
    // merging it with previous block if style is the same
    if (!block.isFirst &&
        block.previous is Block &&
        prev.style == block.style) {
      block.moveChildToNewParent(prev);
      block.unlink();
      block = prev;
    }
    Node next = block.next;
    // merging it with next block if style is the same
    if (!block.isLast && block.next is Block && next.style == block.style) {
      (next as Block).moveChildToNewParent(block);
      next.unlink();
    }
  }

  @override
  Node newInstance() {
    return Block();
  }
}
