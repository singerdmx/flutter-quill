import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:quill_delta/quill_delta.dart';

class QuillController extends ChangeNotifier {
  final Document document;
  TextSelection selection;
  Style toggledStyle = Style();

  QuillController({@required this.document, @required this.selection, this.toggledStyle})
      : assert(document != null),
        assert(selection != null);

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

  replaceText(int index, int len, Object data, TextSelection textSelection) {
    assert(data is String || data is Embeddable);

    Delta delta;
    if (len > 0 || data is! String || (data as String).isNotEmpty) {
      delta = document.replace(index, len, data);
      if (delta != null &&
          toggledStyle.isNotEmpty &&
          delta.isNotEmpty &&
          delta.length <= 2 &&
          delta.last.isInsert) {
        Delta retainDelta = Delta()
          ..retain(index)
          ..retain(data is String ? data.length : 1, toggledStyle.toJson());
        document.compose(retainDelta, ChangeSource.LOCAL);
      }
    }

    toggledStyle = Style();
    if (textSelection != null) {
      if (delta == null) {
        _updateSelection(textSelection, ChangeSource.LOCAL);
      } else {
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
      }
    }
    notifyListeners();
  }

  formatText(int index, int len, Attribute attribute) {
    if (len == 0 && attribute.isInline && attribute.key != Attribute.link.key) {
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

  formatSelection(Attribute attribute) {
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
    if (textSelection != null) {
      _updateSelection(textSelection, source);
    } else {
      textSelection = selection.copyWith(
          baseOffset:
              delta.transformPosition(selection.baseOffset, force: false),
          extentOffset:
              delta.transformPosition(selection.extentOffset, force: false));
      if (selection != textSelection) {
        _updateSelection(textSelection, source);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    document.close();
    super.dispose();
  }

  _updateSelection(TextSelection textSelection, ChangeSource source) {
    assert(textSelection != null);
    assert(source != null);
    selection = textSelection;
    int end = document.length - 1;
    selection = selection.copyWith(
        baseOffset: math.min(selection.baseOffset, end),
        extentOffset: math.min(selection.extentOffset, end));
  }
}
