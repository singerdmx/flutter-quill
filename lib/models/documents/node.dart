import 'dart:collection';

import 'package:flutter_quill/models/documents/style.dart';

import 'attribute.dart';

/* node in a document tree */
abstract class Node extends LinkedListEntry<Node> {}

abstract class StyledNode implements Node {
  Style get style => _style;
  Style _style = Style();

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
}

abstract class Container<T extends Node> extends Node {
  Container _parent;

  Container get parent => _parent;

  bool get isFirst => list.first == this;

  bool get isLast => list.last == this;
}

/* Root node of document tree */
class Root extends Container<Container<Node>> {}
