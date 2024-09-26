import 'package:flutter/material.dart'
    show
        AxisDirection,
        Intent,
        RedoTextIntent,
        ScrollIncrementType,
        ScrollIntent,
        ScrollToDocumentBoundaryIntent,
        SelectionChangedCause,
        SingleActivator,
        UndoTextIntent;
import 'package:flutter/services.dart'
    show LogicalKeyboardKey, SelectionChangedCause;

import '../../document/attribute.dart';
import '../raw_editor/raw_editor_actions.dart'
    show
        HideSelectionToolbarIntent,
        IndentSelectionIntent,
        OpenSearchIntent,
        QuillEditorApplyCheckListIntent,
        QuillEditorApplyHeaderIntent,
        QuillEditorApplyLinkIntent,
        QuillEditorInsertEmbedIntent,
        ToggleTextStyleIntent;

Map<SingleActivator, Intent> defaultSinlgeActivatorActions(
        bool isDesktopMacOS) =>
    {
      const SingleActivator(
        LogicalKeyboardKey.escape,
      ): const HideSelectionToolbarIntent(),
      SingleActivator(
        LogicalKeyboardKey.keyZ,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const UndoTextIntent(SelectionChangedCause.keyboard),
      SingleActivator(
        LogicalKeyboardKey.keyY,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const RedoTextIntent(SelectionChangedCause.keyboard),

      // Selection formatting.
      SingleActivator(
        LogicalKeyboardKey.keyB,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ToggleTextStyleIntent(Attribute.bold),
      SingleActivator(
        LogicalKeyboardKey.keyU,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ToggleTextStyleIntent(Attribute.underline),
      SingleActivator(
        LogicalKeyboardKey.keyI,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ToggleTextStyleIntent(Attribute.italic),
      SingleActivator(
        LogicalKeyboardKey.keyS,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const ToggleTextStyleIntent(Attribute.strikeThrough),
      SingleActivator(
        LogicalKeyboardKey.backquote,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ToggleTextStyleIntent(Attribute.inlineCode),
      SingleActivator(
        LogicalKeyboardKey.tilde,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const ToggleTextStyleIntent(Attribute.codeBlock),
      SingleActivator(
        LogicalKeyboardKey.keyB,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const ToggleTextStyleIntent(Attribute.blockQuote),
      SingleActivator(
        LogicalKeyboardKey.keyK,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyLinkIntent(),

      // Lists
      SingleActivator(
        LogicalKeyboardKey.keyL,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const ToggleTextStyleIntent(Attribute.ul),
      SingleActivator(
        LogicalKeyboardKey.keyO,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const ToggleTextStyleIntent(Attribute.ol),
      SingleActivator(
        LogicalKeyboardKey.keyC,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const QuillEditorApplyCheckListIntent(),

      // Indents
      SingleActivator(
        LogicalKeyboardKey.keyM,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const IndentSelectionIntent(true),
      SingleActivator(
        LogicalKeyboardKey.keyM,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
        shift: true,
      ): const IndentSelectionIntent(false),

      // Headers
      SingleActivator(
        LogicalKeyboardKey.digit1,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h1),
      SingleActivator(
        LogicalKeyboardKey.digit2,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h2),
      SingleActivator(
        LogicalKeyboardKey.digit3,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h3),
      SingleActivator(
        LogicalKeyboardKey.digit4,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h4),
      SingleActivator(
        LogicalKeyboardKey.digit5,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h5),
      SingleActivator(
        LogicalKeyboardKey.digit6,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.h6),
      SingleActivator(
        LogicalKeyboardKey.digit0,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorApplyHeaderIntent(Attribute.header),

      SingleActivator(
        LogicalKeyboardKey.keyG,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const QuillEditorInsertEmbedIntent(Attribute.image),

      SingleActivator(
        LogicalKeyboardKey.keyF,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const OpenSearchIntent(),

      // Navigate to the start or end of the document
      SingleActivator(
        LogicalKeyboardKey.home,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollToDocumentBoundaryIntent(forward: false),
      SingleActivator(
        LogicalKeyboardKey.end,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollToDocumentBoundaryIntent(forward: true),

      //  Arrow key scrolling
      SingleActivator(
        LogicalKeyboardKey.arrowUp,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollIntent(direction: AxisDirection.up),
      SingleActivator(
        LogicalKeyboardKey.arrowDown,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollIntent(direction: AxisDirection.down),
      SingleActivator(
        LogicalKeyboardKey.pageUp,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollIntent(
          direction: AxisDirection.up, type: ScrollIncrementType.page),
      SingleActivator(
        LogicalKeyboardKey.pageDown,
        control: !isDesktopMacOS,
        meta: isDesktopMacOS,
      ): const ScrollIntent(
          direction: AxisDirection.down, type: ScrollIncrementType.page),
    };
