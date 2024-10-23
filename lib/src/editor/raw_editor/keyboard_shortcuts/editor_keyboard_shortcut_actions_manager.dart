import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../raw_editor_state.dart';
import '../raw_editor_text_boundaries.dart';
import 'editor_keyboard_shortcut_actions.dart';

@internal
class EditorKeyboardShortcutsActionsManager {
  EditorKeyboardShortcutsActionsManager({
    required this.rawEditorState,
    required this.context,
  });

  final QuillRawEditorState rawEditorState;
  final BuildContext context;

  void _updateSelection(UpdateSelectionIntent intent) {
    rawEditorState.userUpdateTextEditingValue(
      intent.currentTextEditingValue.copyWith(selection: intent.newSelection),
      intent.cause,
    );
  }

  QuillEditorTextBoundary _characterBoundary(
      DirectionalTextEditingIntent intent) {
    final atomicTextBoundary =
        QuillEditorCharacterBoundary(rawEditorState.textEditingValue);
    return QuillEditorCollapsedSelectionBoundary(
        atomicTextBoundary, intent.forward);
  }

  QuillEditorTextBoundary _nextWordBoundary(
      DirectionalTextEditingIntent intent) {
    final QuillEditorTextBoundary atomicTextBoundary;
    final QuillEditorTextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueForTextLayoutMetrics;
    atomicTextBoundary =
        QuillEditorCharacterBoundary(rawEditorState.textEditingValue);
    // This isn't enough. Newline characters.
    boundary = QuillEditorExpandedTextBoundary(
        QuillEditorWhitespaceBoundary(rawEditorState.textEditingValue),
        QuillEditorWordBoundary(
            rawEditorState.renderEditor, rawEditorState.textEditingValue));

    final mixedBoundary = intent.forward
        ? QuillEditorMixedBoundary(atomicTextBoundary, boundary)
        : QuillEditorMixedBoundary(boundary, atomicTextBoundary);
    // Use a _MixedBoundary to make sure we don't leave invalid codepoints in
    // the field after deletion.
    return QuillEditorCollapsedSelectionBoundary(mixedBoundary, intent.forward);
  }

  QuillEditorTextBoundary _linebreak(DirectionalTextEditingIntent intent) {
    final QuillEditorTextBoundary atomicTextBoundary;
    final QuillEditorTextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueforTextLayoutMetrics;
    atomicTextBoundary =
        QuillEditorCharacterBoundary(rawEditorState.textEditingValue);
    boundary = QuillEditorLineBreak(
        rawEditorState.renderEditor, rawEditorState.textEditingValue);

    // The _MixedBoundary is to make sure we don't leave invalid code units in
    // the field after deletion.
    // `boundary` doesn't need to be wrapped in a _CollapsedSelectionBoundary,
    // since the document boundary is unique and the linebreak boundary is
    // already caret-location based.
    return intent.forward
        ? QuillEditorMixedBoundary(
            QuillEditorCollapsedSelectionBoundary(atomicTextBoundary, true),
            boundary)
        : QuillEditorMixedBoundary(
            boundary,
            QuillEditorCollapsedSelectionBoundary(atomicTextBoundary, false),
          );
  }

  void _replaceText(ReplaceTextIntent intent) {
    rawEditorState.userUpdateTextEditingValue(
      intent.currentTextEditingValue
          .replaced(intent.replacementRange, intent.replacementText),
      intent.cause,
    );
  }

  late final Action<ReplaceTextIntent> _replaceTextAction =
      CallbackAction<ReplaceTextIntent>(onInvoke: _replaceText);

  QuillEditorTextBoundary _documentBoundary(
          DirectionalTextEditingIntent intent) =>
      QuillEditorDocumentBoundary(rawEditorState.textEditingValue);

  Action<T> _makeOverridable<T extends Intent>(Action<T> defaultAction) {
    return Action<T>.overridable(
        context: context, defaultAction: defaultAction);
  }

  late final Action<UpdateSelectionIntent> _updateSelectionAction =
      CallbackAction<UpdateSelectionIntent>(onInvoke: _updateSelection);

  late final QuillEditorUpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent> adjacentLineAction =
      QuillEditorUpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent>(rawEditorState);

  late final _adjacentPageAction =
      QuillEditorUpdateTextSelectionToAdjacentPageAction<
          ExtendSelectionVerticallyToAdjacentPageIntent>(rawEditorState);

  late final QuillEditorToggleTextStyleAction _formatSelectionAction =
      QuillEditorToggleTextStyleAction(rawEditorState);

  late final QuillEditorIndentSelectionAction _indentSelectionAction =
      QuillEditorIndentSelectionAction(rawEditorState);

  late final QuillEditorOpenSearchAction _openSearchAction =
      QuillEditorOpenSearchAction(rawEditorState);
  late final QuillEditorApplyHeaderAction _applyHeaderAction =
      QuillEditorApplyHeaderAction(rawEditorState);
  late final QuillEditorApplyCheckListAction _applyCheckListAction =
      QuillEditorApplyCheckListAction(rawEditorState);

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    DoNothingAndStopPropagationTextIntent: DoNothingAction(consumesKey: false),
    ReplaceTextIntent: _replaceTextAction,
    UpdateSelectionIntent: _updateSelectionAction,
    DirectionalFocusIntent: DirectionalFocusAction.forTextField(),

    // Delete
    DeleteCharacterIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteCharacterIntent>(
            rawEditorState, _characterBoundary)),
    DeleteToNextWordBoundaryIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteToNextWordBoundaryIntent>(
            rawEditorState, _nextWordBoundary)),
    DeleteToLineBreakIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteToLineBreakIntent>(
            rawEditorState, _linebreak)),

    // Extend/Move Selection
    ExtendSelectionByCharacterIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<ExtendSelectionByCharacterIntent>(
      rawEditorState,
      false,
      _characterBoundary,
    )),
    ExtendSelectionToNextWordBoundaryIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<
                ExtendSelectionToNextWordBoundaryIntent>(
            rawEditorState, true, _nextWordBoundary)),
    ExtendSelectionToLineBreakIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<ExtendSelectionToLineBreakIntent>(
            rawEditorState, true, _linebreak)),
    ExtendSelectionVerticallyToAdjacentLineIntent:
        _makeOverridable(adjacentLineAction),
    ExtendSelectionToDocumentBoundaryIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<
                ExtendSelectionToDocumentBoundaryIntent>(
            rawEditorState, true, _documentBoundary)),
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent: _makeOverridable(
        QuillEditorExtendSelectionOrCaretPositionAction(
            rawEditorState, _nextWordBoundary)),
    ExpandSelectionToDocumentBoundaryIntent: _makeOverridable(
        ExpandSelectionToDocumentBoundaryAction(rawEditorState)),
    ExpandSelectionToLineBreakIntent:
        _makeOverridable(ExpandSelectionToLineBreakAction(rawEditorState)),

    // Copy Paste
    SelectAllTextIntent:
        _makeOverridable(QuillEditorSelectAllAction(rawEditorState)),
    CopySelectionTextIntent:
        _makeOverridable(QuillEditorCopySelectionAction(rawEditorState)),
    PasteTextIntent: _makeOverridable(CallbackAction<PasteTextIntent>(
        onInvoke: (intent) => rawEditorState.pasteText(intent.cause))),

    HideSelectionToolbarIntent:
        _makeOverridable(QuillEditorHideSelectionToolbarAction(rawEditorState)),
    UndoTextIntent:
        _makeOverridable(QuillEditorUndoKeyboardAction(rawEditorState)),
    RedoTextIntent:
        _makeOverridable(QuillEditorRedoKeyboardAction(rawEditorState)),

    OpenSearchIntent: _openSearchAction,

    // Selection Formatting
    ToggleTextStyleIntent: _formatSelectionAction,
    IndentSelectionIntent: _indentSelectionAction,
    QuillEditorApplyHeaderIntent: _applyHeaderAction,
    QuillEditorApplyCheckListIntent: _applyCheckListAction,
    QuillEditorApplyLinkIntent: QuillEditorApplyLinkAction(rawEditorState),
    ScrollToDocumentBoundaryIntent:
        NavigateToDocumentBoundaryAction(rawEditorState),

    //  Paging and scrolling
    ExtendSelectionVerticallyToAdjacentPageIntent: _adjacentPageAction,
    ScrollIntent: QuillEditorScrollAction(rawEditorState),
  };

  Map<Type, Action<Intent>> get actions => _actions;
}
