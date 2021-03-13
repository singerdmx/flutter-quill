import 'dart:collection';

import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/models/quill_delta.dart';

import '../attribute.dart';
import 'container.dart';
import 'line.dart';

/* node in a document tree */
abstract class Node extends LinkedListEntry<Node> {
  Container? parent;
  Style _style = Style();

  Style get style => _style;

  void applyAttribute(Attribute attribute) {
    _style = _style.merge(attribute);
  }

  void applyStyle(Style value) {
    _style = _style.mergeAll(value);
  }

  void clearStyle() {
    _style = Style();
  }

  bool get isFirst => list!.first == this;

  bool get isLast => list!.last == this;

  int get length;

  Node clone() {
    Node node = newInstance();
    node.applyStyle(style);
    return node;
  }

  int getOffset() {
    int offset = 0;

    if (list == null || isFirst) {
      return offset;
    }

    Node cur = this;
    do {
      cur = cur.previous!;
      offset += cur.length;
    } while (!cur.isFirst);
    return offset;
  }

  int getDocumentOffset() {
    final parentOffset = (parent is! Root) ? parent!.getDocumentOffset() : 0;
    return parentOffset + getOffset();
  }

  bool containsOffset(int offset) {
    final o = getDocumentOffset();
    return o <= offset && offset < o + length;
  }

  @override
  void insertBefore(Node entry) {
    assert(entry.parent == null && parent != null);
    entry.parent = parent;
    super.insertBefore(entry);
  }

  @override
  void insertAfter(Node entry) {
    assert(entry.parent == null && parent != null);
    entry.parent = parent;
    super.insertAfter(entry);
  }

  @override
  void unlink() {
    assert(parent != null);
    parent = null;
    super.unlink();
  }

  adjust() {
    // do nothing
  }

  /// abstract methods begin

  Node newInstance();

  String toPlainText();

  Delta toDelta();

  insert(int index, Object data, Style? style);

  retain(int index, int? len, Style? style);

  delete(int index, int? len);

  /// abstract methods end

}

/* Root node of document tree */
class Root extends Container<Container<Node?>> {
  @override
  Container<Node?> get defaultChild => Line();

  @override
  Delta toDelta() => children
      .map((child) => child.toDelta())
      .fold(Delta(), (a, b) => a.concat(b));

  @override
  Node newInstance() {
    return Root();
  }
}
