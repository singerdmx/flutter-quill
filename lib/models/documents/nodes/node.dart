import 'dart:collection';

import 'package:flutter_quill/models/documents/style.dart';

import '../attribute.dart';

/* node in a document tree */
class Node extends LinkedListEntry<Node> {
  Container _parent;
  Style _style = Style();

  Style get style => _style;

  Container get parent => _parent;

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

  @override
  void insertBefore(Node entry) {
    assert(entry._parent == null && _parent != null);
    entry._parent = _parent;
    super.insertBefore(entry);
  }

  @override
  void insertAfter(Node entry) {
    assert(entry._parent == null && _parent != null);
    entry._parent = _parent;
    super.insertAfter(entry);
  }

  @override
  void unlink() {
    assert(_parent != null);
    _parent = null;
    super.unlink();
  }
}

abstract class Container<T extends Node> extends Node {}

/* Root node of document tree */
class Root extends Container<Container<Node>> {}
