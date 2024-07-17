import 'dart:collection';

import '../../../../quill_delta.dart';
import '../../editor/embed/embed_editor_builder.dart';
import '../attribute.dart';
import '../style.dart';
import 'container.dart';
import 'line.dart';

/// An abstract node in a document tree.
///
/// Represents a segment of a Quill document with specified [offset]
/// and [length].
///
/// The [offset] property is relative to [parent]. See also [documentOffset]
/// which provides absolute offset of this node within the document.
///
/// The current parent node is exposed by the [parent] property. A node is
/// considered [mounted] when the [parent] property is not `null`.
abstract base class Node extends LinkedListEntry<Node> {
  /// Current parent of this node. May be null if this node is not mounted.
  QuillContainer? parent;

  /// The style attributes
  /// Note: This is not the same as style attribute of css
  ///
  /// Example:
  ///
  ///   {
  ///   "insert": {
  ///     "image": "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png"
  ///   },
  ///   "attributes": { // this one
  ///     "width": "230",
  ///     "style": "display: block; margin: auto; width: 500px;" // Not this
  ///   }
  /// },
  Style get style => _style;
  Style _style = const Style();

  /// Returns `true` if this node is the first node in the [parent] list.
  bool get isFirst => list!.first == this;

  /// Returns `true` if this node is the last node in the [parent] list.
  bool get isLast => list!.last == this;

  /// Length of this node in characters.
  int get length;

  void clearLengthCache();

  Node clone() => newInstance()..applyStyle(style);

  int? _offset;

  /// Offset in characters of this node relative to [parent] node.
  ///
  /// To get offset of this node in the document see [documentOffset].
  int get offset {
    if (_offset != null) {
      return _offset!;
    }

    if (list == null || isFirst) {
      return 0;
    }
    var offset = 0;
    for (final node in list!) {
      if (node == this) {
        break;
      }
      offset += node.length;
    }

    _offset = offset;
    return _offset!;
  }

  void clearOffsetCache() {
    _offset = null;
    final next = this.next;
    if (next != null) {
      next.clearOffsetCache();
    }
  }

  /// Offset in characters of this node in the document.
  int get documentOffset {
    if (parent == null) {
      return offset;
    }
    final parentOffset = (parent is! Root) ? parent!.documentOffset : 0;
    return parentOffset + offset;
  }

  /// Returns `true` if this node contains character at specified [offset] in
  /// the document.
  bool containsOffset(int offset) {
    final o = documentOffset;
    return o <= offset && offset < o + length;
  }

  void applyAttribute(Attribute attribute) {
    _style = _style.merge(attribute);
  }

  void applyStyle(Style value) {
    _style = _style.mergeAll(value);
  }

  void clearStyle() {
    _style = const Style();
  }

  @override
  void insertBefore(Node entry) {
    assert(entry.parent == null && parent != null);
    entry.parent = parent;
    super.insertBefore(entry);
    clearLengthCache();
  }

  @override
  void insertAfter(Node entry) {
    assert(entry.parent == null && parent != null);
    entry.parent = parent;
    super.insertAfter(entry);
    clearLengthCache();
  }

  @override
  void unlink() {
    assert(parent != null);
    clearLengthCache();
    parent = null;
    super.unlink();
  }

  void adjust() {
    /* no-op */
  }

  /// abstract methods begin

  Node newInstance();

  String toPlainText([
    Iterable<EmbedBuilder>? embedBuilders,
    EmbedBuilder? unknownEmbedBuilder,
  ]);

  Delta toDelta();

  void insert(int index, Object data, Style? style);

  void retain(int index, int? len, Style? style);

  void delete(int index, int? len);

  /// abstract methods end
}

/// Root node of document tree.
base class Root extends QuillContainer<QuillContainer<Node?>> {
  @override
  Node newInstance() => Root();

  @override
  QuillContainer<Node?> get defaultChild => Line();

  @override
  Delta toDelta() => children
      .map((child) => child.toDelta())
      .fold(Delta(), (a, b) => a.concat(b));
}
