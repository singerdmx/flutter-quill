import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/models/quill_delta.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:tuple/tuple.dart';

class QuillController extends ChangeNotifier {
  final Document document;
  TextSelection selection;
  Style toggledStyle = Style();

  QuillController({required this.document, required this.selection});

  factory QuillController.basic() {
    return QuillController(
        document: Document(), selection: TextSelection.collapsed(offset: 0));
  }

  // item1: Document state before [change].
  //
  // item2: Change delta applied to the document.
  //
  // item3: The source of this change.
  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => document.changes;

  TextEditingValue get plainTextEditingValue => TextEditingValue(
        text: document.toPlainText(),
        selection: selection,
        composing: TextRange.empty,
      );

  Style getSelectionStyle() {
    return document
        .collectStyle(selection.start, selection.end - selection.start)
        .mergeAll(toggledStyle);
  }

  void undo() {
    Tuple2 tup = document.undo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  void _handleHistoryChange(int? len) {
    if (len != 0) {
      // if (this.selection.extentOffset >= document.length) {
      // // cursor exceeds the length of document, position it in the end
      // updateSelection(
      //     TextSelection.collapsed(offset: document.length), ChangeSource.LOCAL);
      updateSelection(
          TextSelection.collapsed(offset: this.selection.baseOffset + len!),
          ChangeSource.LOCAL);
    } else {
      // no need to move cursor
      notifyListeners();
    }
  }

  void redo() {
    Tuple2 tup = document.redo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  get hasUndo => document.hasUndo;

  get hasRedo => document.hasRedo;

  replaceText(int index, int len, Object? data, TextSelection? textSelection) {
    assert(data is String || data is Embeddable);

    Delta? delta;
    if (len > 0 || data is! String || data.isNotEmpty) {
      try {
        delta = document.replace(index, len, data);
      } catch (e) {
        print('document.replace failed: $e');
        throw e;
      }
      bool shouldRetainDelta = toggledStyle.isNotEmpty &&
          delta.isNotEmpty &&
          delta.length <= 2 &&
          delta.last.isInsert;
      if (shouldRetainDelta &&
          toggledStyle.isNotEmpty &&
          delta.length == 2 &&
          delta.last.data == '\n') {
        // if all attributes are inline, shouldRetainDelta should be false
        final anyAttributeNotInline =
            toggledStyle.values.any((attr) => !attr.isInline);
        if (!anyAttributeNotInline) {
          shouldRetainDelta = false;
        }
      }
      if (shouldRetainDelta) {
        Delta retainDelta = Delta()
          ..retain(index)
          ..retain(data is String ? data.length : 1, toggledStyle.toJson());
        document.compose(retainDelta, ChangeSource.LOCAL);
      }
    }

    toggledStyle = Style();
    if (textSelection != null) {
      if (delta == null || delta.isEmpty) {
        _updateSelection(textSelection, ChangeSource.LOCAL);
      } else {
        try {
          Delta user = Delta()
            ..retain(index)
            ..insert(data)
            ..delete(len);
          int positionDelta = getPositionDelta(user, delta);
          _updateSelection(
            textSelection.copyWith(
              baseOffset: textSelection.baseOffset + positionDelta,
              extentOffset: textSelection.extentOffset + positionDelta,
            ),
            ChangeSource.LOCAL,
          );
        } catch (e) {
          print('getPositionDelta or getPositionDelta error: $e');
          throw e;
        }
      }
    }
    notifyListeners();
  }

  formatText(int index, int len, Attribute? attribute) {
    if (len == 0 &&
        attribute!.isInline &&
        attribute.key != Attribute.link.key) {
      toggledStyle = toggledStyle.put(attribute);
    }

    Delta change = document.format(index, len, attribute);
    TextSelection adjustedSelection = selection.copyWith(
        baseOffset: change.transformPosition(selection.baseOffset),
        extentOffset: change.transformPosition(selection.extentOffset));
    if (selection != adjustedSelection) {
      _updateSelection(adjustedSelection, ChangeSource.LOCAL);
    }
    notifyListeners();
  }

  formatSelection(Attribute? attribute) {
    formatText(selection.start, selection.end - selection.start, attribute);
  }

  updateSelection(TextSelection textSelection, ChangeSource source) {
    _updateSelection(textSelection, source);
    notifyListeners();
  }

  compose(Delta delta, TextSelection textSelection, ChangeSource source) {
    if (delta.isNotEmpty) {
      document.compose(delta, source);
    }

    textSelection = selection.copyWith(
        baseOffset: delta.transformPosition(selection.baseOffset, force: false),
        extentOffset:
            delta.transformPosition(selection.extentOffset, force: false));
    if (selection != textSelection) {
      _updateSelection(textSelection, source);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    document.close();
    super.dispose();
  }

  _updateSelection(TextSelection textSelection, ChangeSource source) {
    selection = textSelection;
    int end = document.length - 1;
    selection = selection.copyWith(
        baseOffset: math.min(selection.baseOffset, end),
        extentOffset: math.min(selection.extentOffset, end));
  }
}
