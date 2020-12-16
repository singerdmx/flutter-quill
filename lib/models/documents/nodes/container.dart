import 'dart:collection';

import 'node.dart';

/* Container of multiple nodes */
abstract class Container<T extends Node> extends Node {
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
    assert(node.parent == null);
    node.parent = this;
    _children.add(node);
  }

  addFirst(T node) {
    assert(node.parent == null);
    node.parent = this;
    _children.addFirst(node);
  }

  void remove(T node) {
    assert(node.parent == this);
    node.parent = null;
    _children.remove(node);
  }

  @override
  String toPlainText() => children.map((child) => child.toPlainText()).join();

  @override
  int get length => _children.fold(0, (cur, node) => cur + node.length);

  @override
  String toString() => _children.join('\n');
}
