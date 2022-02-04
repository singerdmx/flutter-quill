import 'dart:async';

import 'package:tuple/tuple.dart';

import '../quill_delta.dart';
import '../rules/rule.dart';
import 'attribute.dart';
import 'history.dart';
import 'nodes/block.dart';
import 'nodes/container.dart';
import 'nodes/embeddable.dart';
import 'nodes/leaf.dart';
import 'nodes/line.dart';
import 'nodes/node.dart';
import 'style.dart';

/// The rich text document
class Document {
  /// Creates new empty document.
  Document() : _delta = Delta()..insert('\n') {
    _loadDocument(_delta);
  }

  /// Creates new document from provided JSON `data`.
  Document.fromJson(List data) : _delta = _transform(Delta.fromJson(data)) {
    _loadDocument(_delta);
  }

  /// Creates new document from provided `delta`.
  Document.fromDelta(Delta delta) : _delta = delta {
    _loadDocument(delta);
  }

  /// The root node of the document tree
  final Root _root = Root();

  Root get root => _root;

  /// Length of this document.
  int get length => _root.length;

  Delta _delta;

  /// Returns contents of this document as [Delta].
  Delta toDelta() => Delta.from(_delta);

  final Rules _rules = Rules.getInstance();

  void setCustomRules(List<Rule> customRules) {
    _rules.setCustomRules(customRules);
  }

  final StreamController<Tuple3<Delta, Delta, ChangeSource>> _observer =
      StreamController.broadcast();

  final History _history = History();

  /// Stream of [Change]s applied to this document.
  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => _observer.stream;

  /// Inserts [data] in this document at specified [index].
  ///
  /// The `data` parameter can be either a String or an instance of
  /// [Embeddable].
  ///
  /// Applies heuristic rules before modifying this document and
  /// produces a change event with its source set to [ChangeSource.local].
  ///
  /// Returns an instance of [Delta] actually composed into this document.
  Delta insert(int index, Object? data, {int replaceLength = 0}) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);
    if (data is Embeddable) {
      data = data.toJson();
    } else if ((data as String).isEmpty) {
      return Delta();
    }

    final delta = _rules.apply(RuleType.INSERT, this, index,
        data: data, len: replaceLength);
    compose(delta, ChangeSource.LOCAL);
    return delta;
  }

  /// Deletes [length] of characters from this document starting at [index].
  ///
  /// This method applies heuristic rules before modifying this document and
  /// produces a [Change] with source set to [ChangeSource.local].
  ///
  /// Returns an instance of [Delta] actually composed into this document.
  Delta delete(int index, int len) {
    assert(index >= 0 && len > 0);
    final delta = _rules.apply(RuleType.DELETE, this, index, len: len);
    if (delta.isNotEmpty) {
      compose(delta, ChangeSource.LOCAL);
    }
    return delta;
  }

  /// Replaces [length] of characters starting at [index] with [data].
  ///
  /// This method applies heuristic rules before modifying this document and
  /// produces a change event with its source set to [ChangeSource.local].
  ///
  /// Returns an instance of [Delta] actually composed into this document.
  Delta replace(int index, int len, Object? data) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);

    final dataIsNotEmpty = (data is String) ? data.isNotEmpty : true;

    assert(dataIsNotEmpty || len > 0);

    var delta = Delta();

    // We have to insert before applying delete rules
    // Otherwise delete would be operating on stale document snapshot.
    if (dataIsNotEmpty) {
      delta = insert(index, data, replaceLength: len);
    }

    if (len > 0) {
      final deleteDelta = delete(index, len);
      delta = delta.compose(deleteDelta);
    }

    return delta;
  }

  /// Formats segment of this document with specified [attribute].
  ///
  /// Applies heuristic rules before modifying this document and
  /// produces a change event with its source set to [ChangeSource.local].
  ///
  /// Returns an instance of [Delta] actually composed into this document.
  /// The returned [Delta] may be empty in which case this document remains
  /// unchanged and no change event is published to the [changes] stream.
  Delta format(int index, int len, Attribute? attribute) {
    assert(index >= 0 && len >= 0 && attribute != null);

    var delta = Delta();

    final formatDelta = _rules.apply(RuleType.FORMAT, this, index,
        len: len, attribute: attribute);
    if (formatDelta.isNotEmpty) {
      compose(formatDelta, ChangeSource.LOCAL);
      delta = delta.compose(formatDelta);
    }

    return delta;
  }

  /// Only attributes applied to all characters within this range are
  /// included in the result.
  Style collectStyle(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).collectStyle(res.offset, len);
  }

  /// Returns all styles for each node within selection
  List<Tuple2<int, Style>> collectAllIndividualStyles(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).collectAllIndividualStyles(res.offset, len);
  }

  /// Returns all styles for any character within the specified text range.
  List<Style> collectAllStyles(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).collectAllStyles(res.offset, len);
  }

  /// Returns plain text within the specified text range.
  String getPlainText(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).getPlainText(res.offset, len);
  }

  /// Returns [Line] located at specified character [offset].
  ChildQuery queryChild(int offset) {
    // TODO: prevent user from moving caret after last line-break.
    final res = _root.queryChild(offset, true);
    if (res.node is Line) {
      return res;
    }
    final block = res.node as Block;
    return block.queryChild(res.offset, true);
  }

  /// Given offset, find its leaf node in document
  Tuple2<Line?, Leaf?> querySegmentLeafNode(int offset) {
    final result = queryChild(offset);
    if (result.node == null) {
      return const Tuple2(null, null);
    }

    final line = result.node as Line;
    final segmentResult = line.queryChild(result.offset, false);
    if (segmentResult.node == null) {
      return Tuple2(line, null);
    }
    final segment = segmentResult.node as Leaf;
    return Tuple2(line, segment);
  }

  /// Composes [change] Delta into this document.
  ///
  /// Use this method with caution as it does not apply heuristic rules to the
  /// [change].
  ///
  /// It is callers responsibility to ensure that the [change] conforms to
  /// the document model semantics and can be composed with the current state
  /// of this document.
  ///
  /// In case the [change] is invalid, behavior of this method is unspecified.
  void compose(Delta delta, ChangeSource changeSource) {
    assert(!_observer.isClosed);
    delta.trim();
    assert(delta.isNotEmpty);

    var offset = 0;
    delta = _transform(delta);
    final originalDelta = toDelta();
    for (final op in delta.toList()) {
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      if (op.isInsert) {
        // Must normalize data before inserting into the document, makes sure
        // that any embedded objects are converted into EmbeddableObject type.
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
      throw '_delta compose failed';
    }

    if (_delta != _root.toDelta()) {
      throw 'Compose failed';
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

  bool get hasUndo => _history.hasUndo;

  bool get hasRedo => _history.hasRedo;

  static Delta _transform(Delta delta) {
    final res = Delta();
    final ops = delta.toList();
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      res.push(op);
      _autoAppendNewlineAfterEmbeddable(i, ops, op, res, BlockEmbed.videoType);
    }
    return res;
  }

  static void _autoAppendNewlineAfterEmbeddable(
      int i, List<Operation> ops, Operation op, Delta res, String type) {
    final nextOpIsEmbed = i + 1 < ops.length &&
        ops[i + 1].isInsert &&
        ops[i + 1].data is Map &&
        (ops[i + 1].data as Map).containsKey(type);
    if (nextOpIsEmbed &&
        op.data is String &&
        (op.data as String).isNotEmpty &&
        !(op.data as String).endsWith('\n')) {
      res.push(Operation.insert('\n'));
    }
    // embed could be image or video
    final opInsertEmbed =
        op.isInsert && op.data is Map && (op.data as Map).containsKey(type);
    final nextOpIsLineBreak = i + 1 < ops.length &&
        ops[i + 1].isInsert &&
        ops[i + 1].data is String &&
        (ops[i + 1].data as String).startsWith('\n');
    if (opInsertEmbed && (i + 1 == ops.length - 1 || !nextOpIsLineBreak)) {
      // automatically append '\n' for embeddable
      res.push(Operation.insert('\n'));
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

  void close() {
    _observer.close();
    _history.clear();
  }

  /// Returns plain text representation of this document.
  String toPlainText() => _root.children.map((e) => e.toPlainText()).join();

  void _loadDocument(Delta doc) {
    if (doc.isEmpty) {
      throw ArgumentError.value(doc, 'Document Delta cannot be empty.');
    }

    assert((doc.last.data as String).endsWith('\n'));

    var offset = 0;
    for (final op in doc.toList()) {
      if (!op.isInsert) {
        throw ArgumentError.value(doc,
            'Document can only contain insert operations but ${op.key} found.');
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

    final node = root.children.first;
    if (!node.isLast) {
      return false;
    }

    final delta = node.toDelta();
    return delta.length == 1 &&
        delta.first.data == '\n' &&
        delta.first.key == 'insert';
  }
}

/// Source of a [Change].
enum ChangeSource {
  /// Change originated from a local action. Typically triggered by user.
  LOCAL,

  /// Change originated from a remote action.
  REMOTE,
}
