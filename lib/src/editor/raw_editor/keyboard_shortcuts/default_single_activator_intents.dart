import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../../common/utils/platform.dart';
import '../../../document/attribute.dart';
import 'editor_keyboard_shortcut_actions.dart';

final _isDesktopMacOS = isMacOS;

@internal
Map<SingleActivator, Intent> defaultSinlgeActivatorIntents() {
  return {
    const SingleActivator(
      LogicalKeyboardKey.escape,
    ): const HideSelectionToolbarIntent(),
    SingleActivator(
      LogicalKeyboardKey.keyZ,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const UndoTextIntent(SelectionChangedCause.keyboard),
    SingleActivator(
      LogicalKeyboardKey.keyY,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const RedoTextIntent(SelectionChangedCause.keyboard),

    // Selection formatting.
    SingleActivator(
      LogicalKeyboardKey.keyB,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ToggleTextStyleIntent(Attribute.bold),
    SingleActivator(
      LogicalKeyboardKey.keyU,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ToggleTextStyleIntent(Attribute.underline),
    SingleActivator(
      LogicalKeyboardKey.keyI,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ToggleTextStyleIntent(Attribute.italic),
    SingleActivator(
      LogicalKeyboardKey.keyS,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const ToggleTextStyleIntent(Attribute.strikeThrough),
    SingleActivator(
      LogicalKeyboardKey.backquote,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ToggleTextStyleIntent(Attribute.inlineCode),
    SingleActivator(
      LogicalKeyboardKey.tilde,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const ToggleTextStyleIntent(Attribute.codeBlock),
    SingleActivator(
      LogicalKeyboardKey.keyB,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const ToggleTextStyleIntent(Attribute.blockQuote),
    SingleActivator(
      LogicalKeyboardKey.keyK,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyLinkIntent(),

    // Lists
    SingleActivator(
      LogicalKeyboardKey.keyL,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const ToggleTextStyleIntent(Attribute.ul),
    SingleActivator(
      LogicalKeyboardKey.keyO,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const ToggleTextStyleIntent(Attribute.ol),
    SingleActivator(
      LogicalKeyboardKey.keyC,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const QuillEditorApplyCheckListIntent(),

    // Indents
    SingleActivator(
      LogicalKeyboardKey.keyM,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const IndentSelectionIntent(true),
    SingleActivator(
      LogicalKeyboardKey.keyM,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
      shift: true,
    ): const IndentSelectionIntent(false),

    // Headers
    SingleActivator(
      LogicalKeyboardKey.digit1,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h1),
    SingleActivator(
      LogicalKeyboardKey.digit2,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h2),
    SingleActivator(
      LogicalKeyboardKey.digit3,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h3),
    SingleActivator(
      LogicalKeyboardKey.digit4,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h4),
    SingleActivator(
      LogicalKeyboardKey.digit5,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h5),
    SingleActivator(
      LogicalKeyboardKey.digit6,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.h6),
    SingleActivator(
      LogicalKeyboardKey.digit0,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorApplyHeaderIntent(Attribute.header),

    SingleActivator(
      LogicalKeyboardKey.keyG,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const QuillEditorInsertEmbedIntent(Attribute.image),

    SingleActivator(
      LogicalKeyboardKey.keyF,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const OpenSearchIntent(),

    // Vertical caret navigation on the web.
    //
    // On the web, the framework's DefaultTextEditingShortcuts maps the arrow
    // keys to DoNothingAndStopPropagationTextIntent so that the *browser*
    // performs the caret movement on the hidden DOM input. That is correct
    // for DOM-rendered text fields, but the Quill editor is rendered by
    // Flutter: the hidden element has a completely different text layout
    // (width, font, wrapping), so the browser-computed caret lands on an
    // arbitrary visual column. Binding the vertical movements here (this
    // Shortcuts widget sits closer to the focused node, so it takes
    // precedence over DefaultTextEditingShortcuts) makes them run through
    // the editor's own geometry instead. Horizontal movements are left to
    // the browser: they are plain character offsets and map 1:1.
    if (kIsWeb) ...{
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false,
            collapseSelection: true,
          ),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true,
            collapseSelection: true,
          ),
      const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
          const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false,
            collapseSelection: false,
          ),
      const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
          const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true,
            collapseSelection: false,
          ),
    },

    //  Arrow key scrolling
    SingleActivator(
      LogicalKeyboardKey.arrowUp,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ScrollIntent(direction: AxisDirection.up),
    SingleActivator(
      LogicalKeyboardKey.arrowDown,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ScrollIntent(direction: AxisDirection.down),
    SingleActivator(
      LogicalKeyboardKey.pageUp,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ScrollIntent(
        direction: AxisDirection.up, type: ScrollIncrementType.page),
    SingleActivator(
      LogicalKeyboardKey.pageDown,
      control: !_isDesktopMacOS,
      meta: _isDesktopMacOS,
    ): const ScrollIntent(
        direction: AxisDirection.down, type: ScrollIncrementType.page),
  };
}
