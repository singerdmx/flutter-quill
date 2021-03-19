import 'dart:collection';

import '../style.dart';
import 'node.dart';

/* Container of multiple nodes */
abstract class Container<T extends Node?> extends Node {
  final LinkedList<Node> _children = LinkedList<Node>();

  LinkedList<Node> get children => _children;

  int get childCount => _children.length;

  Node get first => _children.first;

  Node get last => _children.last;

  bool get isEmpty => _children.isEmpty;

  bool get isNotEmpty => _children.isNotEmpty;

  /// abstract methods begin

  T get defaultChild;

  /// abstract methods end

  add(T node) {
    assert(node?.parent == null);
    node?.parent = this;
    _children.add(node as Node);
  }

  addFirst(T node) {
    assert(node?.parent == null);
    node?.parent = this;
    _children.addFirst(node as Node);
  }

  void remove(T node) {
    assert(node?.parent == this);
    node?.parent = null;
    _children.remove(node as Node);
  }

  void moveChildToNewParent(Container? newParent) {
    if (isEmpty) {
      return;
    }

    T? last = newParent!.isEmpty ? null : newParent.last as T?;
    while (isNotEmpty) {
      T child = first as T;
      child?.unlink();
      newParent.add(child);
    }

    if (last != null) last.adjust();
  }

  ChildQuery queryChild(int offset, bool inclusive) {
    if (offset < 0 || offset > length) {
      return ChildQuery(null, 0);
    }

    for (Node node in children) {
      int len = node.length;
      if (offset < len || (inclusive && offset == len && (node.isLast))) {
        return ChildQuery(node, offset);
      }
      offset -= len;
    }
    return ChildQuery(null, 0);
  }

  @override
  String toPlainText() => children.map((child) => child.toPlainText()).join();

  @override
  int get length => _children.fold(0, (cur, node) => cur + node.length);

  @override
  insert(int index, Object data, Style? style) {
    assert(index == 0 || (index > 0 && index < length));

    if (isNotEmpty) {
      ChildQuery child = queryChild(index, false);
      child.node!.insert(child.offset, data, style);
      return;
    }

    // empty
    assert(index == 0);
    T node = defaultChild;
    add(node);
    node?.insert(index, data, style);
  }

  @override
  retain(int index, int? length, Style? attributes) {
    assert(isNotEmpty);
    ChildQuery child = queryChild(index, false);
    child.node!.retain(child.offset, length, attributes);
  }

  @override
  delete(int index, int? length) {
    assert(isNotEmpty);
    ChildQuery child = queryChild(index, false);
    child.node!.delete(child.offset, length);
  }

  @override
  String toString() => _children.join('\n');
}

/// Query of a child in a Container
class ChildQuery {
  final Node? node; // null if not found

  final int offset;

  ChildQuery(this.node, this.offset);
}
