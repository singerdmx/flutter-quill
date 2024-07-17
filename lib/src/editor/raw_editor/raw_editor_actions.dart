import 'package:flutter/material.dart';

import '../../../translations.dart';
import '../../document/attribute.dart';
import '../../toolbar/buttons/link_style2_button.dart';
import '../../toolbar/buttons/search/search_dialog.dart';
import '../editor.dart';
import '../widgets/link.dart';
import 'raw_editor_state.dart';
import 'raw_editor_text_boundaries.dart';

// -------------------------------  Text Actions -------------------------------
class QuillEditorDeleteTextAction<T extends DirectionalTextEditingIntent>
    extends ContextAction<T> {
  QuillEditorDeleteTextAction(this.state, this.getTextBoundariesForIntent);

  final QuillRawEditorState state;
  final QuillEditorTextBoundary Function(T intent) getTextBoundariesForIntent;

  TextRange _expandNonCollapsedRange(TextEditingValue value) {
    final TextRange selection = value.selection;
    assert(selection.isValid);
    assert(!selection.isCollapsed);
    final atomicBoundary = QuillEditorCharacterBoundary(value);

    return TextRange(
      start: atomicBoundary
          .getLeadingTextBoundaryAt(TextPosition(offset: selection.start))
          .offset,
      end: atomicBoundary
          .getTrailingTextBoundaryAt(TextPosition(offset: selection.end - 1))
          .offset,
    );
  }

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final selection = state.textEditingValue.selection;
    assert(selection.isValid);

    if (!selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(
            state.textEditingValue,
            '',
            _expandNonCollapsedRange(state.textEditingValue),
            SelectionChangedCause.keyboard),
      );
    }

    final textBoundary = getTextBoundariesForIntent(intent);
    if (!textBoundary.textEditingValue.selection.isValid) {
      return null;
    }
    if (!textBoundary.textEditingValue.selection.isCollapsed) {
      return Actions.invoke(
        context!,
        ReplaceTextIntent(
            state.textEditingValue,
            '',
            _expandNonCollapsedRange(textBoundary.textEditingValue),
            SelectionChangedCause.keyboard),
      );
    }

    return Actions.invoke(
      context!,
      ReplaceTextIntent(
        textBoundary.textEditingValue,
        '',
        textBoundary
            .getTextBoundaryAt(textBoundary.textEditingValue.selection.base),
        SelectionChangedCause.keyboard,
      ),
    );
  }

  @override
  bool get isActionEnabled =>
      !state.widget.configurations.readOnly &&
      state.textEditingValue.selection.isValid;
}

class QuillEditorUpdateTextSelectionAction<
    T extends DirectionalCaretMovementIntent> extends ContextAction<T> {
  QuillEditorUpdateTextSelectionAction(this.state,
      this.ignoreNonCollapsedSelection, this.getTextBoundariesForIntent);

  final QuillRawEditorState state;
  final bool ignoreNonCollapsedSelection;
  final QuillEditorTextBoundary Function(T intent) getTextBoundariesForIntent;

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final selection = state.textEditingValue.selection;
    assert(selection.isValid);

    final collapseSelection = intent.collapseSelection ||
        !state.widget.configurations.selectionEnabled;
    // Collapse to the logical start/end.
    TextSelection collapse(TextSelection selection) {
      assert(selection.isValid);
      assert(!selection.isCollapsed);
      return selection.copyWith(
        baseOffset: intent.forward ? selection.end : selection.start,
        extentOffset: intent.forward ? selection.end : selection.start,
      );
    }

    if (!selection.isCollapsed &&
        !ignoreNonCollapsedSelection &&
        collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(
          state.textEditingValue,
          collapse(selection),
          SelectionChangedCause.keyboard,
        ),
      );
    }

    final textBoundary = getTextBoundariesForIntent(intent);
    final textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }
    if (!textBoundarySelection.isCollapsed &&
        !ignoreNonCollapsedSelection &&
        collapseSelection) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(state.textEditingValue,
            collapse(textBoundarySelection), SelectionChangedCause.keyboard),
      );
    }

    final extent = textBoundarySelection.extent;
    final newExtent = intent.forward
        ? textBoundary.getTrailingTextBoundaryAt(extent)
        : textBoundary.getLeadingTextBoundaryAt(extent);

    final newSelection = collapseSelection
        ? TextSelection.fromPosition(newExtent)
        : textBoundarySelection.extendTo(newExtent);

    // If collapseAtReversal is true and would have an effect, collapse it.
    if (!selection.isCollapsed &&
        intent.collapseAtReversal &&
        (selection.baseOffset < selection.extentOffset !=
            newSelection.baseOffset < newSelection.extentOffset)) {
      return Actions.invoke(
        context!,
        UpdateSelectionIntent(
          state.textEditingValue,
          TextSelection.fromPosition(selection.base),
          SelectionChangedCause.keyboard,
        ),
      );
    }

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection,
          SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}

class QuillEditorExtendSelectionOrCaretPositionAction extends ContextAction<
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent> {
  QuillEditorExtendSelectionOrCaretPositionAction(
      this.state, this.getTextBoundariesForIntent);

  final QuillRawEditorState state;
  final QuillEditorTextBoundary Function(
          ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent)
      getTextBoundariesForIntent;

  @override
  Object? invoke(ExtendSelectionToNextWordBoundaryOrCaretLocationIntent intent,
      [BuildContext? context]) {
    final selection = state.textEditingValue.selection;
    assert(selection.isValid);

    final textBoundary = getTextBoundariesForIntent(intent);
    final textBoundarySelection = textBoundary.textEditingValue.selection;
    if (!textBoundarySelection.isValid) {
      return null;
    }

    final extent = textBoundarySelection.extent;
    final newExtent = intent.forward
        ? textBoundary.getTrailingTextBoundaryAt(extent)
        : textBoundary.getLeadingTextBoundaryAt(extent);

    final newSelection = (newExtent.offset - textBoundarySelection.baseOffset) *
                (textBoundarySelection.extentOffset -
                    textBoundarySelection.baseOffset) <
            0
        ? textBoundarySelection.copyWith(
            extentOffset: textBoundarySelection.baseOffset,
            affinity: textBoundarySelection.extentOffset >
                    textBoundarySelection.baseOffset
                ? TextAffinity.downstream
                : TextAffinity.upstream,
          )
        : textBoundarySelection.extendTo(newExtent);

    return Actions.invoke(
      context!,
      UpdateSelectionIntent(textBoundary.textEditingValue, newSelection,
          SelectionChangedCause.keyboard),
    );
  }

  @override
  bool get isActionEnabled =>
      state.widget.configurations.selectionEnabled &&
      state.textEditingValue.selection.isValid;
}

class QuillEditorUpdateTextSelectionToAdjacentLineAction<
    T extends DirectionalCaretMovementIntent> extends ContextAction<T> {
  QuillEditorUpdateTextSelectionToAdjacentLineAction(this.state);

  final QuillRawEditorState state;

  QuillVerticalCaretMovementRun? _verticalMovementRun;
  TextSelection? _runSelection;

  void stopCurrentVerticalRunIfSelectionChanges() {
    final runSelection = _runSelection;
    if (runSelection == null) {
      assert(_verticalMovementRun == null);
      return;
    }
    _runSelection = state.textEditingValue.selection;
    final currentSelection = state.controller.selection;
    final continueCurrentRun = currentSelection.isValid &&
        currentSelection.isCollapsed &&
        currentSelection.baseOffset == runSelection.baseOffset &&
        currentSelection.extentOffset == runSelection.extentOffset;
    if (!continueCurrentRun) {
      _verticalMovementRun = null;
      _runSelection = null;
    }
  }

  @override
  void invoke(T intent, [BuildContext? context]) {
    assert(state.textEditingValue.selection.isValid);

    final collapseSelection = intent.collapseSelection ||
        !state.widget.configurations.selectionEnabled;
    final value = state.textEditingValue;
    if (!value.selection.isValid) {
      return;
    }

    final currentRun = _verticalMovementRun ??
        state.renderEditor
            .startVerticalCaretMovement(state.renderEditor.selection.extent);

    final shouldMove =
        intent.forward ? currentRun.moveNext() : currentRun.movePrevious();
    final newExtent = shouldMove
        ? currentRun.current
        : (intent.forward
            ? TextPosition(offset: state.textEditingValue.text.length)
            : const TextPosition(offset: 0));
    final newSelection = collapseSelection
        ? TextSelection.fromPosition(newExtent)
        : value.selection.extendTo(newExtent);

    Actions.invoke(
      context!,
      UpdateSelectionIntent(
          value, newSelection, SelectionChangedCause.keyboard),
    );
    if (state.textEditingValue.selection == newSelection) {
      _verticalMovementRun = currentRun;
      _runSelection = newSelection;
    }
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}

class QuillEditorSelectAllAction extends ContextAction<SelectAllTextIntent> {
  QuillEditorSelectAllAction(this.state);

  final QuillRawEditorState state;

  @override
  Object? invoke(SelectAllTextIntent intent, [BuildContext? context]) {
    return Actions.invoke(
      context!,
      UpdateSelectionIntent(
        state.textEditingValue,
        TextSelection(
            baseOffset: 0, extentOffset: state.textEditingValue.text.length),
        intent.cause,
      ),
    );
  }

  @override
  bool get isActionEnabled => state.widget.configurations.selectionEnabled;
}

class QuillEditorCopySelectionAction
    extends ContextAction<CopySelectionTextIntent> {
  QuillEditorCopySelectionAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(CopySelectionTextIntent intent, [BuildContext? context]) {
    if (intent.collapseSelection) {
      state.cutSelection(intent.cause);
    } else {
      state.copySelection(intent.cause);
    }
  }

  @override
  bool get isActionEnabled =>
      state.textEditingValue.selection.isValid &&
      !state.textEditingValue.selection.isCollapsed;
}

//Intent class for "escape" key to dismiss selection toolbar in Windows platform
class HideSelectionToolbarIntent extends Intent {
  const HideSelectionToolbarIntent();
}

class QuillEditorHideSelectionToolbarAction
    extends ContextAction<HideSelectionToolbarIntent> {
  QuillEditorHideSelectionToolbarAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(HideSelectionToolbarIntent intent, [BuildContext? context]) {
    state.hideToolbar();
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}

class QuillEditorUndoKeyboardAction extends ContextAction<UndoTextIntent> {
  QuillEditorUndoKeyboardAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(UndoTextIntent intent, [BuildContext? context]) {
    if (state.controller.hasUndo) {
      state.controller.undo();
    }
  }

  @override
  bool get isActionEnabled => true;
}

class QuillEditorRedoKeyboardAction extends ContextAction<RedoTextIntent> {
  QuillEditorRedoKeyboardAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(RedoTextIntent intent, [BuildContext? context]) {
    if (state.controller.hasRedo) {
      state.controller.redo();
    }
  }

  @override
  bool get isActionEnabled => true;
}

class ToggleTextStyleIntent extends Intent {
  const ToggleTextStyleIntent(this.attribute);

  final Attribute attribute;
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class QuillEditorToggleTextStyleAction extends Action<ToggleTextStyleIntent> {
  QuillEditorToggleTextStyleAction(this.state);

  final QuillRawEditorState state;

  bool _isStyleActive(Attribute styleAttr, Map<String, Attribute> attrs) {
    if (styleAttr.key == Attribute.list.key) {
      final attribute = attrs[styleAttr.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == styleAttr.value;
    }
    return attrs.containsKey(styleAttr.key);
  }

  @override
  void invoke(ToggleTextStyleIntent intent, [BuildContext? context]) {
    final isActive = _isStyleActive(
        intent.attribute, state.controller.getSelectionStyle().attributes);
    state.controller.formatSelection(
        isActive ? Attribute.clone(intent.attribute, null) : intent.attribute);
  }

  @override
  bool get isActionEnabled => true;
}

class IndentSelectionIntent extends Intent {
  const IndentSelectionIntent(this.isIncrease);

  final bool isIncrease;
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class QuillEditorIndentSelectionAction extends Action<IndentSelectionIntent> {
  QuillEditorIndentSelectionAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(IndentSelectionIntent intent, [BuildContext? context]) {
    state.controller.indentSelection(intent.isIncrease);
  }

  @override
  bool get isActionEnabled => true;
}

class OpenSearchIntent extends Intent {
  const OpenSearchIntent();
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class QuillEditorOpenSearchAction extends ContextAction<OpenSearchIntent> {
  QuillEditorOpenSearchAction(this.state);

  final QuillRawEditorState state;

  @override
  Future invoke(OpenSearchIntent intent, [BuildContext? context]) async {
    if (context == null) {
      throw ArgumentError(
        'The context should not be null to use invoke() method',
      );
    }
    await showDialog<String>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => FlutterQuillLocalizationsWidget(
        child: QuillToolbarSearchDialog(
          controller: state.controller,
        ),
      ),
    );
  }

  @override
  bool get isActionEnabled => true;
}

class QuillEditorApplyHeaderIntent extends Intent {
  const QuillEditorApplyHeaderIntent(this.header);

  final Attribute header;
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class QuillEditorApplyHeaderAction
    extends Action<QuillEditorApplyHeaderIntent> {
  QuillEditorApplyHeaderAction(this.state);

  final QuillRawEditorState state;

  Attribute<dynamic> _getHeaderValue() {
    return state.controller
            .getSelectionStyle()
            .attributes[Attribute.header.key] ??
        Attribute.header;
  }

  @override
  void invoke(QuillEditorApplyHeaderIntent intent, [BuildContext? context]) {
    final attribute =
        _getHeaderValue() == intent.header ? Attribute.header : intent.header;
    state.controller.formatSelection(attribute);
  }

  @override
  bool get isActionEnabled => true;
}

class QuillEditorApplyCheckListIntent extends Intent {
  const QuillEditorApplyCheckListIntent();
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class QuillEditorApplyCheckListAction
    extends Action<QuillEditorApplyCheckListIntent> {
  QuillEditorApplyCheckListAction(this.state);

  final QuillRawEditorState state;

  bool _getIsToggled() {
    final attrs = state.controller.getSelectionStyle().attributes;
    var attribute = state.controller.toolbarButtonToggler[Attribute.list.key];

    if (attribute == null) {
      attribute = attrs[Attribute.list.key];
    } else {
      // checkbox tapping causes controller.selection to go to offset 0
      state.controller.toolbarButtonToggler.remove(Attribute.list.key);
    }

    if (attribute == null) {
      return false;
    }
    return attribute.value == Attribute.unchecked.value ||
        attribute.value == Attribute.checked.value;
  }

  @override
  void invoke(QuillEditorApplyCheckListIntent intent, [BuildContext? context]) {
    state.controller.formatSelection(_getIsToggled()
        ? Attribute.clone(Attribute.unchecked, null)
        : Attribute.unchecked);
  }

  @override
  bool get isActionEnabled => true;
}

class QuillEditorApplyLinkIntent extends Intent {
  const QuillEditorApplyLinkIntent();
}

class QuillEditorApplyLinkAction extends Action<QuillEditorApplyLinkIntent> {
  QuillEditorApplyLinkAction(this.state);

  final QuillRawEditorState state;

  @override
  Object? invoke(QuillEditorApplyLinkIntent intent) async {
    final initialTextLink = QuillTextLink.prepare(state.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: state.context,
      builder: (context) {
        return LinkStyleDialog(
          text: initialTextLink.text,
          link: initialTextLink.link,
          dialogTheme: state.widget.configurations.dialogTheme,
        );
      },
    );

    if (textLink != null) {
      textLink.submit(state.controller);
    }
    return null;
  }
}

class QuillEditorInsertEmbedIntent extends Intent {
  const QuillEditorInsertEmbedIntent(this.type);

  final Attribute type;
}

class NavigateToDocumentBoundaryAction
    extends ContextAction<ScrollToDocumentBoundaryIntent> {
  NavigateToDocumentBoundaryAction(this.state);

  final QuillRawEditorState state;

  @override
  Object? invoke(
    ScrollToDocumentBoundaryIntent intent, [
    BuildContext? context,
  ]) {
    return Actions.invoke(
      context!,
      UpdateSelectionIntent(
        state.textEditingValue,
        intent.forward
            ? TextSelection.collapsed(
                offset: state.controller.plainTextEditingValue.text.length,
              )
            : const TextSelection.collapsed(offset: 0),
        SelectionChangedCause.keyboard,
      ),
    );
  }
}

/// An [Action] that scrolls the Quill editor scroll bar by the amount configured
/// in the [ScrollIntent] given to it.
///
/// The default for a [ScrollIntent.type] set to [ScrollIncrementType.page] is 80% of the
/// size of the scroll window, and for [ScrollIncrementType.line], 50 logical pixels.
/// Modelled on 'class ScrollAction' in flutter's scrollable_helpers.dart
class QuillEditorScrollAction extends ContextAction<ScrollIntent> {
  QuillEditorScrollAction(this.state);

  final QuillRawEditorState state;

  @override
  void invoke(ScrollIntent intent, [BuildContext? context]) {
    final sc = state.scrollController;
    final increment = switch (intent.type) {
      ScrollIncrementType.line => 50.0,
      ScrollIncrementType.page => 0.8 * sc.position.viewportDimension,
    };
    sc.position.moveTo(
      sc.position.pixels +
          (intent.direction == AxisDirection.down ? increment : -increment),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}

/// An [Action] that moves the caret by a page.
///
/// The default movement is 80% of the size of the scroll window.
/// Modelled on 'class _UpdateTextSelectionVerticallyAction' in flutter's editable_text.dart
class QuillEditorUpdateTextSelectionToAdjacentPageAction<
    T extends DirectionalCaretMovementIntent> extends ContextAction<T> {
  QuillEditorUpdateTextSelectionToAdjacentPageAction(this.state);

  final QuillRawEditorState state;

  QuillVerticalCaretMovementRun? _verticalMovementRun;
  TextSelection? _runSelection;

  void stopCurrentVerticalRunIfSelectionChanges() {
    final runSelection = _runSelection;
    if (runSelection == null) {
      assert(_verticalMovementRun == null);
      return;
    }
    _runSelection = state.textEditingValue.selection;
    final currentSelection = state.controller.selection;
    final continueCurrentRun = currentSelection.isValid &&
        currentSelection.isCollapsed &&
        currentSelection.baseOffset == runSelection.baseOffset &&
        currentSelection.extentOffset == runSelection.extentOffset;
    if (!continueCurrentRun) {
      _verticalMovementRun = null;
      _runSelection = null;
    }
  }

  @override
  void invoke(T intent, [BuildContext? context]) {
    assert(state.textEditingValue.selection.isValid);

    final collapseSelection = intent.collapseSelection ||
        !state.widget.configurations.selectionEnabled;
    final value = state.textEditingValue;
    if (!value.selection.isValid) {
      return;
    }

    final currentRun = state.renderEditor
        .startVerticalCaretMovement(state.renderEditor.selection.extent);

    final pageOffset = 0.8 * state.scrollController.position.viewportDimension;
    currentRun.moveVertical(intent.forward ? pageOffset : -pageOffset);
    final newExtent = currentRun.current;
    final newSelection = collapseSelection
        ? TextSelection.fromPosition(newExtent)
        : value.selection.extendTo(newExtent);

    Actions.invoke(
      context!,
      UpdateSelectionIntent(
          value, newSelection, SelectionChangedCause.keyboard),
    );
    if (state.textEditingValue.selection == newSelection) {
      _verticalMovementRun = currentRun;
      _runSelection = newSelection;
    }
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}
