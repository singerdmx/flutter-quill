import 'dart:math' as math;

import 'package:flutter_quill/models/quill_delta.dart';

import '../style.dart';
import 'embed.dart';
import 'line.dart';
import 'node.dart';

/* A leaf node in document tree */
abstract class Leaf extends Node {
  Object _value;

  Object get value => _value;

  Leaf.val(Object val) : _value = val;

  factory Leaf(Object data) {
    if (data is Embeddable) {
      return Embed(data);
    }
    String text = data as String;
    assert(text.isNotEmpty);
    return Text(text);
  }

  @override
  void applyStyle(Style value) {
    assert((value.isInline || value.isIgnored || value.isEmpty),
        'Unable to apply Style to leaf: $value');
    super.applyStyle(value);
  }

  @override
  Line? get parent => super.parent as Line?;

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
    var data = _value is Embeddable ? (_value as Embeddable).toJson() : _value;
    return Delta()..insert(data, style.toJson());
  }

  @override
  insert(int index, Object data, Style? style) {
    assert(index >= 0 && index <= length);
    Leaf node = Leaf(data);
    if (index < length) {
      splitAt(index)!.insertBefore(node);
    } else {
      insertAfter(node);
    }
    node.format(style);
  }

  @override
  retain(int index, int? len, Style? style) {
    if (style == null) {
      return;
    }

    int local = math.min(this.length - index, len!);
    int remain = len - local;
    Leaf node = _isolate(index, local);

    if (remain > 0) {
      assert(node.next != null);
      node.next!.retain(0, remain, style);
    }
    node.format(style);
  }

  @override
  delete(int index, int? len) {
    assert(index < this.length);

    int local = math.min(this.length - index, len!);
    Leaf target = _isolate(index, local);
    Leaf? prev = target.previous as Leaf?;
    Leaf? next = target.next as Leaf?;
    target.unlink();

    int remain = len - local;
    if (remain > 0) {
      assert(next != null);
      next!.delete(0, remain);
    }

    if (prev != null) {
      prev.adjust();
    }
  }

  @override
  adjust() {
    if (this is Embed) {
      return;
    }

    Text node = this as Text;
    // merging it with previous node if style is the same
    Node? prev = node.previous;
    if (!node.isFirst && prev is Text && prev.style == node.style) {
      prev._value = prev.value + node.value;
      node.unlink();
      node = prev;
    }

    // merging it with next node if style is the same
    Node? next = node.next;
    if (!node.isLast && next is Text && next.style == node.style) {
      node._value = node.value + next.value;
      next.unlink();
    }
  }

  Leaf? cutAt(int index) {
    assert(index >= 0 && index <= length);
    Leaf? cut = splitAt(index);
    cut?.unlink();
    return cut;
  }

  Leaf? splitAt(int index) {
    assert(index >= 0 && index <= length);
    if (index == 0) {
      return this;
    }
    if (index == length) {
      return isLast ? null : next as Leaf?;
    }

    assert(this is Text);
    String text = _value as String;
    _value = text.substring(0, index);
    Leaf split = Leaf(text.substring(index));
    split.applyStyle(style);
    insertAfter(split);
    return split;
  }

  format(Style? style) {
    if (style != null && style.isNotEmpty) {
      applyStyle(style);
    }

    adjust();
  }

  Leaf _isolate(int index, int length) {
    assert(
        index >= 0 && index < this.length && (index + length <= this.length));
    Leaf target = splitAt(index)!;
    target.splitAt(length);
    return target;
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

  @override
  Node newInstance() {
    return Text();
  }
}

/// An embedded node such as image or video
class Embed extends Leaf {
  Embed(Embeddable data) : super.val(data);

  @override
  Embeddable get value => super.value as Embeddable;

  @override
  String toPlainText() {
    return '\uFFFC';
  }

  @override
  Node newInstance() {
    throw UnimplementedError();
  }
}
