import 'dart:async';

import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:flutter_quill/models/documents/nodes/container.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:tuple/tuple.dart';

import '../rules/rule.dart';
import 'attribute.dart';
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

  Delta insert(int index, Object data) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);
    if (data is Embeddable) {
      data = (data as Embeddable).toJson();
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

  Delta replace(int index, int len, Object data) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);

    bool dataIsNotEmpty = (data is String) ? data.isNotEmpty : true;

    assert(dataIsNotEmpty || len > 0);

    Delta delta = Delta();

    if (dataIsNotEmpty) {
      delta = insert(index + length, data);
    }

    if (len > 0) {
      Delta deleteDelta = delete(index, len);
      delta = delta.compose(deleteDelta);
    }

    return delta;
  }

  Delta format(int index, int len, Attribute attribute) {
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
    Block block = res.node;
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
      Style style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      if (op.isInsert) {
        _root.insert(offset, _normalize(op.data), style);
      } else if (op.isDelete) {
        _root.delete(offset, op.length);
      } else if (op.attributes != null) {
        _root.retain(offset, op.length, style);
      }

      if (!op.isDelete) {
        offset += op.length;
      }
    }
    _delta = _delta.compose(delta);

    if (_delta != _root.toDelta()) {
      throw ('Compose failed');
    }
    _observer.add(Tuple3(originalDelta, delta, changeSource));
  }

  static Delta _transform(Delta delta) {
    Delta res = Delta();
    for (Operation op in delta.toList()) {
      // TODO
      res.push(op);
    }
    return res;
  }

  Object _normalize(Object data) {
    return data is String
        ? data
        : data is Embeddable
            ? data
            : Embeddable.fromJson(data);
  }

  close() {
    _observer.close();
  }
}

enum ChangeSource {
  LOCAL,
  REMOTE,
}
