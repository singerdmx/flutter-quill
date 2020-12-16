import 'dart:collection';

import 'package:flutter_quill/models/documents/style.dart';
import 'package:quill_delta/quill_delta.dart';

import '../attribute.dart';
import 'container.dart';
import 'line.dart';

/* node in a document tree */
abstract class Node extends LinkedListEntry<Node> {
  Container parent;
  Style _style = Style();

  Style get style => _style;

  void applyAttribute(Attribute attribute) {
    _style = _style.merge(attribute);
  }

  void applyStyle(Style value) {
    if (value == null) {
      throw ArgumentError('null value');
    }
    _style = _style.mergeAll(value);
  }

  void clearStyle() {
    _style = Style();
  }

  bool get isFirst => list.first == this;

  bool get isLast => list.last == this;

  int get length;

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

  /// abstract methods begin

  String toPlainText();

  Delta toDelta();

  /// abstract methods end

}

/* Root node of document tree */
class Root extends Container<Container<Node>> {
  @override
  Container<Node> get defaultChild => Line();

  @override
  Delta toDelta() => children
      .map((child) => child.toDelta())
      .fold(Delta(), (a, b) => a.concat(b));
}
