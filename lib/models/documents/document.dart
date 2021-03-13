import 'dart:async';

import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:flutter_quill/models/documents/nodes/container.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/models/quill_delta.dart';
import 'package:tuple/tuple.dart';

import '../rules/rule.dart';
import 'attribute.dart';
import 'history.dart';
import 'nodes/embed.dart';
import 'nodes/node.dart';

/// The rich text document
class Document {
  /// The root node of the document tree
  final Root _root = Root();

  Root get root => _root;

  int get length => _root.length;

  Delta _delta;

  Delta toDelta() => Delta.from(_delta);

  final Rules _rules = Rules.getInstance();

  final StreamController<Tuple3<Delta, Delta, ChangeSource>> _observer =
      StreamController.broadcast();

  final History _history = History();

  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => _observer.stream;

  Document() : _delta = Delta()..insert('\n') {
    _loadDocument(_delta);
  }

  Document.fromJson(List data) : _delta = _transform(Delta.fromJson(data)) {
    _loadDocument(_delta);
  }

  Delta insert(int index, Object? data) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);
    if (data is Embeddable) {
      data = data.toJson();
    } else if ((data as String).isEmpty) {
      return Delta();
    }

    Delta delta = _rules.apply(RuleType.INSERT, this, index, data: data);
    compose(delta, ChangeSource.LOCAL);
    return delta;
  }

  Delta delete(int index, int len) {
    assert(index >= 0 && len > 0);
    Delta delta = _rules.apply(RuleType.DELETE, this, index, len: len);
    if (delta.isNotEmpty) {
      compose(delta, ChangeSource.LOCAL);
    }
    return delta;
  }

  Delta replace(int index, int len, Object? data) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);

    bool dataIsNotEmpty = (data is String) ? data.isNotEmpty : true;

    assert(dataIsNotEmpty || len > 0);

    Delta delta = Delta();

    if (dataIsNotEmpty) {
      delta = insert(index + len, data);
    }

    if (len > 0) {
      Delta deleteDelta = delete(index, len);
      delta = delta.compose(deleteDelta);
    }

    return delta;
  }

  Delta format(int index, int len, Attribute? attribute) {
    assert(index >= 0 && len >= 0 && attribute != null);

    Delta delta = Delta();

    Delta formatDelta = _rules.apply(RuleType.FORMAT, this, index,
        len: len, attribute: attribute);
    if (formatDelta.isNotEmpty) {
      compose(formatDelta, ChangeSource.LOCAL);
      delta = delta.compose(formatDelta);
    }

    return delta;
  }

  Style collectStyle(int index, int len) {
    ChildQuery res = queryChild(index);
    return (res.node as Line).collectStyle(res.offset, len);
  }

  ChildQuery queryChild(int offset) {
    ChildQuery res = _root.queryChild(offset, true);
    if (res.node is Line) {
      return res;
    }
    Block block = res.node as Block;
    return block.queryChild(res.offset, true);
  }

  compose(Delta delta, ChangeSource changeSource) {
    assert(!_observer.isClosed);
    delta.trim();
    assert(delta.isNotEmpty);

    int offset = 0;
    delta = _transform(delta);
    Delta originalDelta = toDelta();
    for (Operation op in delta.toList()) {
      Style? style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      if (op.isInsert) {
        _root.insert(offset, _normalize(op.data), style);
      } else if (op.isDelete) {
        _root.delete(offset, op.length);
      } else if (op.attributes != null) {
        _root.retain(offset, op.length, style);
      }

      if (!op.isDelete) {
        offset += op.length!;
      }
    }
    try {
      _delta = _delta.compose(delta);
    } catch (e) {
      throw ('_delta compose failed');
    }

    if (_delta != _root.toDelta()) {
      throw ('Compose failed');
    }
    final change = Tuple3(originalDelta, delta, changeSource);
    _observer.add(change);
    _history.handleDocChange(change);
  }

  Tuple2 undo() {
    return _history.undo(this);
  }

  Tuple2 redo() {
    return _history.redo(this);
  }

  get hasUndo => _history.hasUndo;

  get hasRedo => _history.hasRedo;

  static Delta _transform(Delta delta) {
    Delta res = Delta();
    List<Operation> ops = delta.toList();
    for (int i = 0; i < ops.length; i++) {
      Operation op = ops[i];
      res.push(op);
      _handleImageInsert(i, ops, op, res);
    }
    return res;
  }

  static void _handleImageInsert(
      int i, List<Operation> ops, Operation op, Delta res) {
    bool nextOpIsImage =
        i + 1 < ops.length && ops[i + 1].isInsert && ops[i + 1].data is! String;
    if (nextOpIsImage && !(op.data as String).endsWith('\n')) {
      res.push(Operation.insert('\n', null));
    }
    // Currently embed is equivalent to image and hence `is! String`
    bool opInsertImage = op.isInsert && op.data is! String;
    bool nextOpIsLineBreak = i + 1 < ops.length &&
        ops[i + 1].isInsert &&
        ops[i + 1].data is String &&
        (ops[i + 1].data as String).startsWith('\n');
    if (opInsertImage && (i + 1 == ops.length - 1 || !nextOpIsLineBreak)) {
      // automatically append '\n' for image
      res.push(Operation.insert('\n', null));
    }
  }

  Object _normalize(Object? data) {
    if (data is String) {
      return data;
    }

    if (data is Embeddable) {
      return data;
    }
    return Embeddable.fromJson(data as Map<String, dynamic>);
  }

  close() {
    _observer.close();
    _history.clear();
  }

  String toPlainText() => _root.children.map((e) => e.toPlainText()).join('');

  _loadDocument(Delta doc) {
    assert((doc.last.data as String).endsWith('\n'));
    int offset = 0;
    for (final op in doc.toList()) {
      if (!op.isInsert) {
        throw ArgumentError.value(doc,
            'Document Delta can only contain insert operations but ${op.key} found.');
      }
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;
      final data = _normalize(op.data);
      _root.insert(offset, data, style);
      offset += op.length!;
    }
    final node = _root.last;
    if (node is Line &&
        node.parent is! Block &&
        node.style.isEmpty &&
        _root.childCount > 1) {
      _root.remove(node);
    }
  }

  bool isEmpty() {
    if (root.children.length != 1) {
      return false;
    }

    final Node node = root.children.first;
    if (!node.isLast) {
      return false;
    }

    Delta delta = node.toDelta();
    return delta.length == 1 &&
        delta.first.data == '\n' &&
        delta.first.key == 'insert';
  }
}

enum ChangeSource {
  LOCAL,
  REMOTE,
}
