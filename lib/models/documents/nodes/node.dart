import 'dart:collection';

import '../../quill_delta.dart';
import '../attribute.dart';
import '../style.dart';
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
    return newInstance()..applyStyle(style);
  }

  int getOffset() {
    var offset = 0;

    if (list == null || isFirst) {
      return offset;
    }

    var cur = this;
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

  void adjust() {
    // do nothing
  }

  /// abstract methods begin

  Node newInstance();

  String toPlainText();

  Delta toDelta();

  void insert(int index, Object data, Style? style);

  void retain(int index, int? len, Style? style);

  void delete(int index, int? len);

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
