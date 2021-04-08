import 'dart:math' as math;

import '../../quill_delta.dart';
import '../attribute.dart';
import '../style.dart';
import 'block.dart';
import 'container.dart';
import 'embed.dart';
import 'leaf.dart';
import 'node.dart';

class Line extends Container<Leaf?> {
  @override
  Leaf get defaultChild => Text();

  @override
  int get length => super.length + 1;

  bool get hasEmbed {
    if (childCount != 1) {
      return false;
    }

    return children.single is Embed;
  }

  Line? get nextLine {
    if (!isLast) {
      return next is Block ? (next as Block).first as Line? : next as Line?;
    }
    if (parent is! Block) {
      return null;
    }

    if (parent!.isLast) {
      return null;
    }
    return parent!.next is Block
        ? (parent!.next as Block).first as Line?
        : parent!.next as Line?;
  }

  @override
  Delta toDelta() {
    final delta = children
        .map((child) => child.toDelta())
        .fold(Delta(), (dynamic a, b) => a.concat(b));
    var attributes = style;
    if (parent is Block) {
      final block = parent as Block;
      attributes = attributes.mergeAll(block.style);
    }
    delta.insert('\n', attributes.toJson());
    return delta;
  }

  @override
  String toPlainText() => '${super.toPlainText()}\n';

  @override
  String toString() {
    final body = children.join(' → ');
    final styleString = style.isNotEmpty ? ' $style' : '';
    return '¶ $body ⏎$styleString';
  }

  @override
  void insert(int index, Object data, Style? style) {
    if (data is Embeddable) {
      _insert(index, data, style);
      return;
    }

    final text = data as String;
    final lineBreak = text.indexOf('\n');
    if (lineBreak < 0) {
      _insert(index, text, style);
      return;
    }

    final prefix = text.substring(0, lineBreak);
    _insert(index, prefix, style);
    if (prefix.isNotEmpty) {
      index += prefix.length;
    }

    final nextLine = _getNextLine(index);

    clearStyle();

    if (parent is Block) {
      _unwrap();
    }

    _format(style);

    // Continue with the remaining
    final remain = text.substring(lineBreak + 1);
    nextLine.insert(0, remain, style);
  }

  @override
  void retain(int index, int? len, Style? style) {
    if (style == null) {
      return;
    }
    final thisLen = length;

    final local = math.min(thisLen - index, len!);

    if (index + local == thisLen && local == 1) {
      assert(style.values.every((attr) => attr.scope == AttributeScope.BLOCK));
      _format(style);
    } else {
      assert(style.values.every((attr) => attr.scope == AttributeScope.INLINE));
      assert(index + local != thisLen);
      super.retain(index, local, style);
    }

    final remain = len - local;
    if (remain > 0) {
      assert(nextLine != null);
      nextLine!.retain(0, remain, style);
    }
  }

  @override
  void delete(int index, int? len) {
    final local = math.min(length - index, len!);
    final deleted = index + local == length;
    if (deleted) {
      clearStyle();
      if (local > 1) {
        super.delete(index, local - 1);
      }
    } else {
      super.delete(index, local);
    }

    final remain = len - local;
    if (remain > 0) {
      assert(nextLine != null);
      nextLine!.delete(0, remain);
    }

    if (deleted && isNotEmpty) {
      assert(nextLine != null);
      nextLine!.moveChildToNewParent(this);
      moveChildToNewParent(nextLine);
    }

    if (deleted) {
      final Node p = parent!;
      unlink();
      p.adjust();
    }
  }

  void _format(Style? newStyle) {
    if (newStyle == null || newStyle.isEmpty) {
      return;
    }

    applyStyle(newStyle);
    final blockStyle = newStyle.getBlockExceptHeader();
    if (blockStyle == null) {
      return;
    }

    if (parent is Block) {
      final parentStyle = (parent as Block).style.getBlockExceptHeader();
      if (blockStyle.value == null) {
        _unwrap();
      } else if (blockStyle != parentStyle) {
        _unwrap();
        final block = Block()..applyAttribute(blockStyle);
        _wrap(block);
        block.adjust();
      }
    } else if (blockStyle.value != null) {
      final block = Block()..applyAttribute(blockStyle);
      _wrap(block);
      block.adjust();
    }
  }

  void _wrap(Block block) {
    assert(parent != null && parent is! Block);
    insertAfter(block);
    unlink();
    block.add(this);
  }

  void _unwrap() {
    if (parent is! Block) {
      throw ArgumentError('Invalid parent');
    }
    final block = parent as Block;

    assert(block.children.contains(this));

    if (isFirst) {
      unlink();
      block.insertBefore(this);
    } else if (isLast) {
      unlink();
      block.insertAfter(this);
    } else {
      final before = block.clone() as Block;
      block.insertBefore(before);

      var child = block.first as Line;
      while (child != this) {
        child.unlink();
        before.add(child);
        child = block.first as Line;
      }
      unlink();
      block.insertBefore(this);
    }
    block.adjust();
  }

  Line _getNextLine(int index) {
    assert(index == 0 || (index > 0 && index < length));

    final line = clone() as Line;
    insertAfter(line);
    if (index == length - 1) {
      return line;
    }

    final query = queryChild(index, false);
    while (!query.node!.isLast) {
      final next = (last as Leaf)..unlink();
      line.addFirst(next);
    }
    final child = query.node as Leaf;
    final cut = child.splitAt(query.offset);
    cut?.unlink();
    line.addFirst(cut);
    return line;
  }

  void _insert(int index, Object data, Style? style) {
    assert(index == 0 || (index > 0 && index < length));

    if (data is String) {
      assert(!data.contains('\n'));
      if (data.isEmpty) {
        return;
      }
    }

    if (isNotEmpty) {
      final result = queryChild(index, true);
      result.node!.insert(result.offset, data, style);
      return;
    }

    final child = Leaf(data);
    add(child);
    child.format(style);
  }

  @override
  Node newInstance() {
    return Line();
  }

  Style collectStyle(int offset, int len) {
    final local = math.min(length - offset, len);
    var res = Style();
    final excluded = <Attribute>{};

    void _handle(Style style) {
      if (res.isEmpty) {
        excluded.addAll(style.values);
      } else {
        for (final attr in res.values) {
          if (!style.containsKey(attr.key)) {
            excluded.add(attr);
          }
        }
      }
      final remain = style.removeAll(excluded);
      res = res.removeAll(excluded);
      res = res.mergeAll(remain);
    }

    final data = queryChild(offset, true);
    var node = data.node as Leaf?;
    if (node != null) {
      res = res.mergeAll(node.style);
      var pos = node.length - data.offset;
      while (!node!.isLast && pos < local) {
        node = node.next as Leaf?;
        _handle(node!.style);
        pos += node.length;
      }
    }

    res = res.mergeAll(style);
    if (parent is Block) {
      final block = parent as Block;
      res = res.mergeAll(block.style);
    }

    final remain = len - local;
    if (remain > 0) {
      _handle(nextLine!.collectStyle(0, remain));
    }

    return res;
  }
}
