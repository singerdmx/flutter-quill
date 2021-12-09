import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../editor.dart';

mixin RawEditorStateSelectionDelegateMixin on EditorState
    implements TextSelectionDelegate {
  @override
  TextEditingValue get textEditingValue {
    return getTextEditingValue();
  }

  @override
  set textEditingValue(TextEditingValue value) {
    // deprecated
    setTextEditingValue(value, SelectionChangedCause.keyboard);
  }

  @override
  void bringIntoView(TextPosition position) {
    final localRect = getRenderEditor()!.getLocalRectForCaret(position);
    final targetOffset = _getOffsetToRevealCaret(localRect, position);

    scrollController.jumpTo(targetOffset.offset);
    getRenderEditor()!.showOnScreen(rect: targetOffset.rect);
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
    if (!scrollController.position.allowImplicitScrolling) {
      return RevealedOffset(offset: scrollController.offset, rect: rect);
    }

    final editableSize = getRenderEditor()!.size;
    final double additionalOffset;
    final Offset unitOffset;

    // The caret is vertically centered within the line. Expand the caret's
    // height so that it spans the line because we're going to ensure that the
    // entire expanded caret is scrolled into view.
    final expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: math.max(
          rect.height, getRenderEditor()!.preferredLineHeight(position)),
    );

    additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : 0.0
            .clamp(expandedRect.bottom - editableSize.height, expandedRect.top);
    unitOffset = const Offset(0, 1);

    // No overscrolling when encountering tall fonts/scripts that extend past
    // the ascent.
    final targetOffset = (additionalOffset + scrollController.offset).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );

    final offsetDelta = scrollController.offset - targetOffset;
    return RevealedOffset(
        rect: rect.shift(unitOffset * offsetDelta), offset: targetOffset);
  }

  @override
  void hideToolbar([bool hideHandles = true]) {
    if (getSelectionOverlay()?.toolbar != null) {
      getSelectionOverlay()?.hideToolbar();
    }
  }

  @override
  void userUpdateTextEditingValue(
      TextEditingValue value, SelectionChangedCause cause) {
    setTextEditingValue(value, cause);
  }

  @override
  bool get cutEnabled => widget.toolbarOptions.cut && !widget.readOnly;

  @override
  bool get copyEnabled => widget.toolbarOptions.copy;

  @override
  bool get pasteEnabled => widget.toolbarOptions.paste && !widget.readOnly;

  @override
  bool get selectAllEnabled => widget.toolbarOptions.selectAll;

  void setSelection(TextSelection nextSelection, SelectionChangedCause cause) {
    if (nextSelection == textEditingValue.selection) {
      return;
    }
    setTextEditingValue(
      textEditingValue.copyWith(selection: nextSelection),
      cause,
    );
  }

  @override
  void copySelection(SelectionChangedCause cause) {
    final selection = textEditingValue.selection;
    if (selection.isCollapsed || !selection.isValid) {
      return;
    }
    Clipboard.setData(
        ClipboardData(text: selection.textInside(textEditingValue.text)));

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar(false);

      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          // Collapse the selection and hide the toolbar and handles.
          userUpdateTextEditingValue(
            TextEditingValue(
              text: textEditingValue.text,
              selection: TextSelection.collapsed(
                  offset: textEditingValue.selection.end),
            ),
            SelectionChangedCause.toolbar,
          );
          break;
      }
    }
  }

  @override
  void cutSelection(SelectionChangedCause cause) {
    final selection = textEditingValue.selection;
    if (readOnly || !selection.isValid || selection.isCollapsed) {
      return;
    }
    final text = textEditingValue.text;
    Clipboard.setData(ClipboardData(text: selection.textInside(text)));
    setTextEditingValue(
      TextEditingValue(
        text: selection.textBefore(text) + selection.textAfter(text),
        selection: TextSelection.collapsed(
          offset: math.min(selection.start, selection.end),
          affinity: selection.affinity,
        ),
      ),
      cause,
    );

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    final selection = textEditingValue.selection;
    if (readOnly || !selection.isValid) {
      return;
    }
    final text = textEditingValue.text;
    // See https://github.com/flutter/flutter/issues/11427
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) {
      return;
    }
    setTextEditingValue(
      TextEditingValue(
        text:
            selection.textBefore(text) + data.text! + selection.textAfter(text),
        selection: TextSelection.collapsed(
          offset: math.min(selection.start, selection.end) + data.text!.length,
          affinity: selection.affinity,
        ),
      ),
      cause,
    );

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  void selectAll(SelectionChangedCause cause) {
    setSelection(
      textEditingValue.selection.copyWith(
        baseOffset: 0,
        extentOffset: textEditingValue.text.length,
      ),
      cause,
    );

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
    }
  }
}
