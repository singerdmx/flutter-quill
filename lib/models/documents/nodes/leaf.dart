import 'package:quill_delta/quill_delta.dart';

import 'node.dart';

/* A leaf node in document tree */
abstract class Leaf extends Node {
  Object _value;

  Object get value => _value;

  Leaf.val(Object val)
      : assert(val != null),
        _value = val;

  @override
  int get length {
    if (_value is String) {
      return (_value as String).length;
    }
    // return 1 for embedded object
    return 1;
  }

  @override
  Delta toDelta() {
    return null; // TODO
  }
}

class Text extends Leaf {
  Text([String text = ''])
      : assert(!text.contains('\n')),
        super.val(text);

  @override
  String get value => _value as String;

  @override
  String toPlainText() {
    return value;
  }
}
