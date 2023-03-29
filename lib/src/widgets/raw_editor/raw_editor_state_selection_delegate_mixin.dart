import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../models/documents/document.dart';
import '../../models/documents/nodes/leaf.dart';
import '../../utils/delta.dart';
import '../editor.dart';

mixin RawEditorStateSelectionDelegateMixin on EditorState
    implements TextSelectionDelegate {
  @override
  TextEditingValue get textEditingValue {
    return widget.controller.plainTextEditingValue;
  }

  set textEditingValue(TextEditingValue value) {
    final cursorPosition = value.selection.extentOffset;
    final oldText = widget.controller.document.toPlainText();
    final newText = value.text;
    final diff = getDiff(oldText, newText, cursorPosition);
    if (diff.deleted == '' && diff.inserted == '') {
      // Only changing selection range
      widget.controller.updateSelection(value.selection, ChangeSource.LOCAL);
      return;
    }

    final insertedText = _adjustInsertedText(diff.inserted);

    widget.controller.replaceText(
        diff.start, diff.deleted.length, insertedText, value.selection);

    _applyPasteStyle(insertedText, diff.start);
  }

  void _applyPasteStyle(String insertedText, int start) {
    if (insertedText == pastePlainText && pastePlainText != '') {
      final pos = start;
      for (var i = 0; i < pasteStyle.length; i++) {
        final offset = pasteStyle[i].offset;
        final style = pasteStyle[i].value;
        widget.controller.formatTextStyle(
            pos + offset,
            i == pasteStyle.length - 1
                ? pastePlainText.length - offset
                : pasteStyle[i + 1].offset,
            style);
      }
    }
  }

  String _adjustInsertedText(String text) {
    // For clip from editor, it may contain image, a.k.a 65532 or '\uFFFC'.
    // For clip from browser, image is directly ignore.
    // Here we skip image when pasting.
    if (!text.codeUnits.contains(Embed.kObjectReplacementInt)) {
      return text;
    }

    final sb = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == Embed.kObjectReplacementInt) {
        continue;
      }
      sb.write(text[i]);
    }
    return sb.toString();
  }

  @override
  void bringIntoView(TextPosition position) {
    // Ignore errors if position is invalid (i.e. paste on iOS when editor
    // has no content and user pasted from toolbar)
    try {
      final localRect = renderEditor.getLocalRectForCaret(position);
      final targetOffset = _getOffsetToRevealCaret(localRect, position);

      if (scrollController.hasClients) {
        scrollController.jumpTo(targetOffset.offset);
      }
      renderEditor.showOnScreen(rect: targetOffset.rect);
    } catch (_) {}
  }

  // Finds the closest scroll offset to the current scroll offset that fully
  // reveals the given caret rect. If the given rect's main axis extent is too
  // large to be fully revealed in `renderEditable`, it will be centered along
  // the main axis.
  //
  // If this is a multiline EditableText (which means the Editable can only
  // scroll vertically), the given rect's height will first be extended to match
  // `renderEditable.preferredLineHeight`, before the target scroll offset is
  // calculated.
  RevealedOffset _getOffsetToRevealCaret(Rect rect, TextPosition position) {
    // Make sure scrollController is attached
    if (scrollController.hasClients &&
        !scrollController.position.allowImplicitScrolling) {
      return RevealedOffset(offset: scrollController.offset, rect: rect);
    }

    final editableSize = renderEditor.size;
    final double additionalOffset;
    final Offset unitOffset;

    // The caret is vertically centered within the line. Expand the caret's
    // height so that it spans the line because we're going to ensure that the
    // entire expanded caret is scrolled into view.
    final expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: math.max(rect.height, renderEditor.preferredLineHeight(position)),
    );

    additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : 0.0
            .clamp(expandedRect.bottom - editableSize.height, expandedRect.top);
    unitOffset = const Offset(0, 1);

    // No overscrolling when encountering tall fonts/scripts that extend past
    // the ascent.
    var targetOffset = additionalOffset;
    if (scrollController.hasClients) {
      targetOffset = (additionalOffset + scrollController.offset).clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );
    }

    final offsetDelta =
        (scrollController.hasClients ? scrollController.offset : 0) -
            targetOffset;
    return RevealedOffset(
        rect: rect.shift(unitOffset * offsetDelta), offset: targetOffset);
  }

  @override
  void hideToolbar([bool hideHandles = true]) {
    // If the toolbar is currently visible.
    if (selectionOverlay?.toolbar != null) {
      hideHandles ? selectionOverlay?.hide() : selectionOverlay?.hideToolbar();
    }
  }

  @override
  void userUpdateTextEditingValue(
      TextEditingValue value, SelectionChangedCause cause) {
    textEditingValue = value;
  }

  @override
  bool get cutEnabled => widget.contextMenuBuilder != null && !widget.readOnly;

  @override
  bool get copyEnabled => widget.contextMenuBuilder != null;

  @override
  bool get pasteEnabled =>
      widget.contextMenuBuilder != null && !widget.readOnly;

  @override
  bool get selectAllEnabled => widget.contextMenuBuilder != null;
}
