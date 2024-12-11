import 'dart:async' show StreamSubscription;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:math' as math;
import 'dart:ui' as ui hide TextStyle;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility_temp_fork/flutter_keyboard_visibility_temp_fork.dart'
    show KeyboardVisibilityController;

import '../../common/structs/horizontal_spacing.dart';
import '../../common/structs/offset_value.dart';
import '../../common/structs/vertical_spacing.dart';
import '../../common/utils/platform.dart';
import '../../controller/quill_controller.dart';
import '../../delta/delta_diff.dart';
import '../../document/attribute.dart';
import '../../document/document.dart';
import '../../document/nodes/block.dart';
import '../../document/nodes/line.dart';
import '../../document/nodes/node.dart';
import '../editor.dart';
import '../widgets/cursor.dart';
import '../widgets/default_styles.dart';
import '../widgets/link.dart';
import '../widgets/proxy.dart';
import '../widgets/text/text_block.dart';
import '../widgets/text/text_line.dart';
import '../widgets/text/text_selection.dart';
import 'keyboard_shortcuts/editor_keyboard_shortcut_actions_manager.dart';
import 'keyboard_shortcuts/editor_keyboard_shortcuts.dart';
import 'raw_editor.dart';
import 'raw_editor_render_object.dart';
import 'raw_editor_state_selection_delegate_mixin.dart';
import 'raw_editor_state_text_input_client_mixin.dart';
import 'scribble_focusable.dart';

class QuillRawEditorState extends EditorState
    with
        AutomaticKeepAliveClientMixin<QuillRawEditor>,
        WidgetsBindingObserver,
        TickerProviderStateMixin<QuillRawEditor>,
        RawEditorStateTextInputClientMixin,
        RawEditorStateSelectionDelegateMixin {
  late final EditorKeyboardShortcutsActionsManager _shortcutActionsManager;

  final GlobalKey _editorKey = GlobalKey();

  KeyboardVisibilityController? _keyboardVisibilityController;
  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  bool _keyboardVisible = false;

  // Selection overlay
  @override
  EditorTextSelectionOverlay? get selectionOverlay => _selectionOverlay;
  EditorTextSelectionOverlay? _selectionOverlay;

  @override
  ScrollController get scrollController => _scrollController;
  late ScrollController _scrollController;

  // Cursors
  late CursorCont _cursorCont;

  QuillController get controller => widget.controller;

  // Focus
  bool _didAutoFocus = false;

  bool get _hasFocus => widget.config.focusNode.hasFocus;

  // Theme
  DefaultStyles? _styles;

  // for pasting style
  @override
  List<OffsetValue> get pasteStyleAndEmbed => controller.pasteStyleAndEmbed;

  @override
  String get pastePlainText => controller.pastePlainText;

  ClipboardStatusNotifier? _clipboardStatus;
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  TextDirection get _textDirection => Directionality.of(context);

  @override
  bool get dirty => _dirty;
  bool _dirty = false;

  @override
  void insertContent(KeyboardInsertedContent content) {
    assert(widget.config.contentInsertionConfiguration?.allowedMimeTypes
            .contains(content.mimeType) ??
        false);
    widget.config.contentInsertionConfiguration?.onContentInserted
        .call(content);
  }

  /// Copy current selection to [Clipboard].
  @override
  void copySelection(SelectionChangedCause cause) {
    if (!controller.clipboardSelection(true)) return;

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();

      // Collapse the selection and hide the toolbar and handles.
      userUpdateTextEditingValue(
        TextEditingValue(
          text: textEditingValue.text,
          selection:
              TextSelection.collapsed(offset: textEditingValue.selection.end),
        ),
        SelectionChangedCause.toolbar,
      );
    }
  }

  /// Cut current selection to [Clipboard].
  @override
  void cutSelection(SelectionChangedCause cause) {
    if (!controller.clipboardSelection(false)) return;

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  /// Paste text from [Clipboard].
  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    if (controller.readOnly) {
      return;
    }

    if (await controller.clipboardPaste()) {
      bringIntoView(textEditingValue.selection.extent);
      return;
    }
  }

  /// Select the entire text value.
  @override
  void selectAll(SelectionChangedCause cause) {
    userUpdateTextEditingValue(
      textEditingValue.copyWith(
        selection: TextSelection(
            baseOffset: 0, extentOffset: textEditingValue.text.length),
      ),
      cause,
    );

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
    }
  }

  /// Returns the [ContextMenuButtonItem]s representing the buttons in this
  /// platform's default selection menu for [QuillRawEditor].
  /// Copied from [EditableTextState].
  List<ContextMenuButtonItem> get contextMenuButtonItems {
    return EditableText.getEditableButtonItems(
      clipboardStatus:
          (_clipboardStatus != null) ? _clipboardStatus!.value : null,
      onCopy: copyEnabled
          ? () => copySelection(SelectionChangedCause.toolbar)
          : null,
      onCut:
          cutEnabled ? () => cutSelection(SelectionChangedCause.toolbar) : null,
      onPaste:
          pasteEnabled ? () => pasteText(SelectionChangedCause.toolbar) : null,
      onSelectAll: selectAllEnabled
          ? () => selectAll(SelectionChangedCause.toolbar)
          : null,
      onLookUp: lookUpEnabled
          ? () => lookUpSelection(SelectionChangedCause.toolbar)
          : null,
      onSearchWeb: searchWebEnabled
          ? () => searchWebForSelection(SelectionChangedCause.toolbar)
          : null,
      onShare: shareEnabled
          ? () => shareSelection(SelectionChangedCause.toolbar)
          : null,
      onLiveTextInput: liveTextInputEnabled ? () {} : null,
    );
  }

  /// Look up the current selection,
  /// as in the "Look Up" edit menu button on iOS.
  ///
  /// Currently this is only implemented for iOS.
  ///
  /// Throws an error if the selection is empty or collapsed.
  Future<void> lookUpSelection(SelectionChangedCause cause) async {
    final text = textEditingValue.selection.textInside(textEditingValue.text);
    if (text.isEmpty) {
      return;
    }
    await SystemChannels.platform.invokeMethod(
      'LookUp.invoke',
      text,
    );
  }

  /// Launch a web search on the current selection,
  /// as in the "Search Web" edit menu button on iOS.
  ///
  /// Currently this is only implemented for iOS.
  ///
  /// When 'obscureText' is true or the selection is empty,
  /// this function will not do anything
  Future<void> searchWebForSelection(SelectionChangedCause cause) async {
    final text = textEditingValue.selection.textInside(textEditingValue.text);
    if (text.isNotEmpty) {
      await SystemChannels.platform.invokeMethod(
        'SearchWeb.invoke',
        text,
      );
    }
  }

  /// Launch the share interface for the current selection,
  /// as in the "Share" edit menu button on iOS.
  ///
  /// Currently this is only implemented for iOS.
  ///
  /// When 'obscureText' is true or the selection is empty,
  /// this function will not do anything
  Future<void> shareSelection(SelectionChangedCause cause) async {
    final text = textEditingValue.selection.textInside(textEditingValue.text);
    if (text.isNotEmpty) {
      await SystemChannels.platform.invokeMethod(
        'Share.invoke',
        text,
      );
    }
  }

  /// Returns the anchor points for the default context menu.
  ///
  /// Copied from [EditableTextState].
  TextSelectionToolbarAnchors get contextMenuAnchors {
    final glyphHeights = _getGlyphHeights();
    final selection = textEditingValue.selection;
    final points = renderEditor.getEndpointsForSelection(selection);
    return TextSelectionToolbarAnchors.fromSelection(
      renderBox: renderEditor,
      startGlyphHeight: glyphHeights.startGlyphHeight,
      endGlyphHeight: glyphHeights.endGlyphHeight,
      selectionEndpoints: points,
    );
  }

  /// Gets the line heights at the start and end of the selection for the given
  /// [QuillRawEditorState].
  ///
  /// Copied from [EditableTextState].
  QuillEditorGlyphHeights _getGlyphHeights() {
    final selection = textEditingValue.selection;

    // Only calculate handle rects if the text in the previous frame
    // is the same as the text in the current frame. This is done because
    // widget.renderObject contains the renderEditable from the previous frame.
    // If the text changed between the current and previous frames then
    // widget.renderObject.getRectForComposingRange might fail. In cases where
    // the current frame is different from the previous we fall back to
    // renderObject.preferredLineHeight.
    final prevText = renderEditor.document.toPlainText();
    final currText = textEditingValue.text;
    if (prevText != currText || !selection.isValid || selection.isCollapsed) {
      return QuillEditorGlyphHeights(
        renderEditor.preferredLineHeight(selection.base),
        renderEditor.preferredLineHeight(selection.base),
      );
    }

    final startCharacterRect =
        renderEditor.getLocalRectForCaret(selection.base);
    final endCharacterRect =
        renderEditor.getLocalRectForCaret(selection.extent);
    return QuillEditorGlyphHeights(
      startCharacterRect.height,
      endCharacterRect.height,
    );
  }

  void _defaultOnTapOutside(PointerDownEvent event) {
    /// The focus dropping behavior is only present on desktop platforms
    /// and mobile browsers.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        // On mobile platforms, we don't unfocus on touch events unless they're
        // in the web browser, but we do unfocus for all other kinds of events.
        switch (event.kind) {
          case ui.PointerDeviceKind.touch:
            break;
          case ui.PointerDeviceKind.mouse:
          case ui.PointerDeviceKind.stylus:
          case ui.PointerDeviceKind.invertedStylus:
          case ui.PointerDeviceKind.unknown:
            widget.config.focusNode.unfocus();
            break;
          case ui.PointerDeviceKind.trackpad:
            throw UnimplementedError(
              'Unexpected pointer down event for trackpad.',
            );
        }
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        widget.config.focusNode.unfocus();
        break;
      default:
        throw UnsupportedError(
          'The platform ${defaultTargetPlatform.name} is not supported in the'
          ' _defaultOnTapOutside()',
        );
    }
  }

  Widget _scribbleFocusable(Widget child) {
    return ScribbleFocusable(
      editorKey: _editorKey,
      enabled: widget.config.enableScribble && !widget.config.readOnly,
      renderBoxForBounds: () => context
          .findAncestorStateOfType<QuillEditorState>()
          ?.context
          .findRenderObject() as RenderBox?,
      onScribbleFocus: (offset) {
        widget.config.focusNode.requestFocus();
        widget.config.onScribbleActivated?.call();
      },
      scribbleAreaInsets: widget.config.scribbleAreaInsets,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    super.build(context);

    var doc = controller.document;
    if (doc.isEmpty() && widget.config.placeholder != null) {
      final raw = widget.config.placeholder?.replaceAll(r'"', '\\"');
      // get current block attributes applied to the first line even if it
      // is empty
      final blockAttributesWithoutContent =
          doc.root.children.firstOrNull?.toDelta().first.attributes;
      // check if it has code block attribute to add '//' to give to the users
      // the feeling of this is really a block of code
      final isCodeBlock =
          blockAttributesWithoutContent?.containsKey('code-block') ?? false;
      // we add the block attributes at the same time as the placeholder to allow the editor to display them without removing
      // the placeholder (this is really awkward when everything is empty)
      final blockAttrInsertion = blockAttributesWithoutContent == null
          ? ''
          : ',{"insert":"\\n","attributes":${jsonEncode(blockAttributesWithoutContent)}}';
      doc = Document.fromJson(
        jsonDecode(
          '[{"attributes":{"placeholder":true},"insert":"${isCodeBlock ? '// ' : ''}$raw${blockAttrInsertion.isEmpty ? '\\n' : ''}"}$blockAttrInsertion]',
        ),
      );
    }

    if (!widget.config.disableClipboard) {
      // Web - esp Safari Mac/iOS has security measures in place that restrict
      // cliboard status checks w/o direct user interaction. Initializing the
      // ClipboardStatusNotifier with a default value of unknown will cause the
      // clipboard status to be checked w/o user interaction which fails. Default
      // to pasteable for web.
      if (kIsWeb) {
        _clipboardStatus = ClipboardStatusNotifier(
          value: ClipboardStatus.pasteable,
        );
      }
    }

    Widget child;
    if (widget.config.scrollable) {
      /// Since [SingleChildScrollView] does not implement
      /// `computeDistanceToActualBaseline` it prevents the editor from
      /// providing its baseline metrics. To address this issue we wrap
      /// the scroll view with [BaselineProxy] which mimics the editor's
      /// baseline.
      // This implies that the first line has no styles applied to it.
      final baselinePadding =
          EdgeInsets.only(top: _styles!.paragraph!.verticalSpacing.top);
      child = BaselineProxy(
          textStyle: _styles!.paragraph!.style,
          padding: baselinePadding,
          child: _scribbleFocusable(
            SingleChildScrollView(
              controller: _scrollController,
              physics: widget.config.scrollPhysics,
              child: CompositedTransformTarget(
                link: _toolbarLayerLink,
                child: MouseRegion(
                  cursor: widget.config.readOnly
                      ? widget.config.readOnlyMouseCursor
                      : SystemMouseCursors.text,
                  child: QuillRawEditorMultiChildRenderObject(
                    key: _editorKey,
                    offset: _scrollController.hasClients
                        ? _scrollController.position
                        : null,
                    document: doc,
                    selection: controller.selection,
                    hasFocus: _hasFocus,
                    scrollable: widget.config.scrollable,
                    textDirection: _textDirection,
                    startHandleLayerLink: _startHandleLayerLink,
                    endHandleLayerLink: _endHandleLayerLink,
                    onSelectionChanged: _handleSelectionChanged,
                    onSelectionCompleted: _handleSelectionCompleted,
                    scrollBottomInset: widget.config.scrollBottomInset,
                    padding: widget.config.padding,
                    maxContentWidth: widget.config.maxContentWidth,
                    cursorController: _cursorCont,
                    floatingCursorDisabled:
                        widget.config.floatingCursorDisabled,
                    children: _buildChildren(doc, context),
                  ),
                ),
              ),
            ),
          ));
    } else {
      child = _scribbleFocusable(
        CompositedTransformTarget(
          link: _toolbarLayerLink,
          child: Semantics(
            child: MouseRegion(
              cursor: widget.config.readOnly
                  ? widget.config.readOnlyMouseCursor
                  : SystemMouseCursors.text,
              child: QuillRawEditorMultiChildRenderObject(
                key: _editorKey,
                document: doc,
                selection: controller.selection,
                hasFocus: _hasFocus,
                scrollable: widget.config.scrollable,
                cursorController: _cursorCont,
                textDirection: _textDirection,
                startHandleLayerLink: _startHandleLayerLink,
                endHandleLayerLink: _endHandleLayerLink,
                onSelectionChanged: _handleSelectionChanged,
                onSelectionCompleted: _handleSelectionCompleted,
                scrollBottomInset: widget.config.scrollBottomInset,
                padding: widget.config.padding,
                maxContentWidth: widget.config.maxContentWidth,
                floatingCursorDisabled: widget.config.floatingCursorDisabled,
                children: _buildChildren(doc, context),
              ),
            ),
          ),
        ),
      );
    }
    final constraints = widget.config.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.config.minHeight ?? 0.0,
            maxHeight: widget.config.maxHeight ?? double.infinity,
          );

    return TextFieldTapRegion(
      enabled: widget.config.onTapOutsideEnabled,
      onTapOutside: (event) {
        final onTapOutside = widget.config.onTapOutside;
        if (onTapOutside != null) {
          onTapOutside.call(event, widget.config.focusNode);
          return;
        }
        _defaultOnTapOutside(event);
      },
      child: QuillStyles(
        data: _styles!,
        child: EditorKeyboardShortcuts(
          actions: _shortcutActionsManager.actions,
          onKeyPressed: widget.config.onKeyPressed,
          characterEvents: widget.config.characterShortcutEvents,
          spaceEvents: widget.config.spaceShortcutEvents,
          constraints: constraints,
          focusNode: widget.config.focusNode,
          controller: controller,
          readOnly: widget.config.readOnly,
          enableAlwaysIndentOnTab: widget.config.enableAlwaysIndentOnTab,
          customShortcuts: widget.config.customShortcuts,
          customActions: widget.config.customActions,
          child: child,
        ),
      ),
    );
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause cause,
  ) {
    final oldSelection = controller.selection;
    controller.updateSelection(selection, ChangeSource.local);

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();

    if (!_keyboardVisible) {
      // This will show the keyboard for all selection changes on the
      // editor, not just changes triggered by user gestures.
      requestKeyboard();
    }

    if (cause == SelectionChangedCause.drag) {
      // When user updates the selection while dragging make sure to
      // bring the updated position (base or extent) into view.
      if (oldSelection.baseOffset != selection.baseOffset) {
        bringIntoView(selection.base);
      } else if (oldSelection.extentOffset != selection.extentOffset) {
        bringIntoView(selection.extent);
      }
    }
  }

  void _handleSelectionCompleted() {
    controller.onSelectionCompleted?.call();
  }

  /// Updates the checkbox positioned at [offset] in document
  /// by changing its attribute according to [value].
  void _handleCheckboxTap(int offset, bool value) {
    final requestKeyboardFocusOnCheckListChanged =
        widget.config.requestKeyboardFocusOnCheckListChanged;
    if (!(widget.config.checkBoxReadOnly ?? widget.config.readOnly)) {
      _disableScrollControllerAnimateOnce = true;
      final currentSelection = controller.selection.copyWith();
      final attribute = value ? Attribute.checked : Attribute.unchecked;

      _markNeedsBuild();
      controller
        ..ignoreFocusOnTextChange = true
        ..skipRequestKeyboard = !requestKeyboardFocusOnCheckListChanged
        ..formatText(offset, 0, attribute)

        // Checkbox tapping causes controller.selection to go to offset 0
        // Stop toggling those two toolbar buttons
        ..toolbarButtonToggler = {
          Attribute.list.key: attribute,
          Attribute.header.key: Attribute.header
        };

      // Go back from offset 0 to current selection
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller
          ..ignoreFocusOnTextChange = false
          ..skipRequestKeyboard = !requestKeyboardFocusOnCheckListChanged
          ..updateSelection(currentSelection, ChangeSource.local);
      });
    }
  }

  List<Widget> _buildChildren(Document doc, BuildContext context) {
    final result = <Widget>[];
    final indentLevelCounts = <int, int>{};
    // this need for several ordered list in document
    // we need to reset indents Map, if list finished
    // List finished when there is node without Attribute.ol in styles
    // So in this case we set clearIndents=true and send it
    // to the next EditableTextBlock
    var prevNodeOl = false;
    var clearIndents = false;

    for (final node in doc.root.children) {
      final attrs = node.style.attributes;

      if (prevNodeOl && attrs[Attribute.list.key] != Attribute.ol ||
          attrs.isEmpty) {
        clearIndents = true;
      }

      prevNodeOl = attrs[Attribute.list.key] == Attribute.ol;
      final nodeTextDirection = getDirectionOfNode(node, _textDirection);
      if (node is Line) {
        final editableTextLine = _getEditableTextLineFromNode(node, context);
        result.add(Directionality(
            textDirection: nodeTextDirection, child: editableTextLine));
      } else if (node is Block) {
        final editableTextBlock = EditableTextBlock(
          block: node,
          controller: controller,
          customLeadingBlockBuilder: widget.config.customLeadingBuilder,
          textDirection: nodeTextDirection,
          scrollBottomInset: widget.config.scrollBottomInset,
          horizontalSpacing: _getHorizontalSpacingForBlock(node, _styles),
          verticalSpacing: _getVerticalSpacingForBlock(node, _styles),
          textSelection: controller.selection,
          color: widget.config.selectionColor,
          styles: _styles,
          enableInteractiveSelection: widget.config.enableInteractiveSelection,
          hasFocus: _hasFocus,
          contentPadding: attrs.containsKey(Attribute.codeBlock.key)
              ? const EdgeInsets.all(16)
              : null,
          embedBuilder: widget.config.embedBuilder,
          linkActionPicker: _linkActionPicker,
          onLaunchUrl: widget.config.onLaunchUrl,
          cursorCont: _cursorCont,
          indentLevelCounts: indentLevelCounts,
          clearIndents: clearIndents,
          onCheckboxTap: _handleCheckboxTap,
          readOnly: widget.config.readOnly,
          checkBoxReadOnly: widget.config.checkBoxReadOnly,
          customRecognizerBuilder: widget.config.customRecognizerBuilder,
          customStyleBuilder: widget.config.customStyleBuilder,
          customLinkPrefixes: widget.config.customLinkPrefixes,
          composingRange: composingRange.value,
        );
        result.add(
          Directionality(
            textDirection: nodeTextDirection,
            child: editableTextBlock,
          ),
        );

        clearIndents = false;
      } else {
        _dirty = false;
        throw StateError('Unreachable.');
      }
    }
    _dirty = false;
    return result;
  }

  EditableTextLine _getEditableTextLineFromNode(
      Line node, BuildContext context) {
    final textLine = TextLine(
      line: node,
      textDirection: _textDirection,
      embedBuilder: widget.config.embedBuilder,
      customStyleBuilder: widget.config.customStyleBuilder,
      customRecognizerBuilder: widget.config.customRecognizerBuilder,
      styles: _styles!,
      readOnly: widget.config.readOnly,
      controller: controller,
      linkActionPicker: _linkActionPicker,
      onLaunchUrl: widget.config.onLaunchUrl,
      customLinkPrefixes: widget.config.customLinkPrefixes,
      composingRange: composingRange.value,
    );
    final editableTextLine = EditableTextLine(
        node,
        null,
        textLine,
        _getHorizontalSpacingForLine(node, _styles),
        _getVerticalSpacingForLine(node, _styles),
        _textDirection,
        controller.selection,
        widget.config.selectionColor,
        widget.config.enableInteractiveSelection,
        _hasFocus,
        MediaQuery.devicePixelRatioOf(context),
        _cursorCont,
        _styles!.inlineCode!);
    return editableTextLine;
  }

  HorizontalSpacing _getHorizontalSpacingForLine(
    Line line,
    DefaultStyles? defaultStyles,
  ) {
    final attrs = line.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      int level;
      if (attrs[Attribute.header.key]!.value is double) {
        level = attrs[Attribute.header.key]!.value.toInt();
      } else {
        level = attrs[Attribute.header.key]!.value;
      }
      switch (level) {
        case 1:
          return defaultStyles!.h1!.horizontalSpacing;
        case 2:
          return defaultStyles!.h2!.horizontalSpacing;
        case 3:
          return defaultStyles!.h3!.horizontalSpacing;
        case 4:
          return defaultStyles!.h4!.horizontalSpacing;
        case 5:
          return defaultStyles!.h5!.horizontalSpacing;
        case 6:
          return defaultStyles!.h6!.horizontalSpacing;
        default:
          throw ArgumentError('Invalid level $level');
      }
    }

    return defaultStyles!.paragraph!.horizontalSpacing;
  }

  VerticalSpacing _getVerticalSpacingForLine(
    Line line,
    DefaultStyles? defaultStyles,
  ) {
    final attrs = line.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      int level;
      if (attrs[Attribute.header.key]!.value is double) {
        level = attrs[Attribute.header.key]!.value.toInt();
      } else {
        level = attrs[Attribute.header.key]!.value;
      }
      switch (level) {
        case 1:
          return defaultStyles!.h1!.verticalSpacing;
        case 2:
          return defaultStyles!.h2!.verticalSpacing;
        case 3:
          return defaultStyles!.h3!.verticalSpacing;
        case 4:
          return defaultStyles!.h4!.verticalSpacing;
        case 5:
          return defaultStyles!.h5!.verticalSpacing;
        case 6:
          return defaultStyles!.h6!.verticalSpacing;
        default:
          throw ArgumentError('Invalid level $level');
      }
    }

    return defaultStyles!.paragraph!.verticalSpacing;
  }

  HorizontalSpacing _getHorizontalSpacingForBlock(
      Block node, DefaultStyles? defaultStyles) {
    final attrs = node.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles!.quote!.horizontalSpacing;
    } else if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles!.code!.horizontalSpacing;
    } else if (attrs.containsKey(Attribute.indent.key)) {
      return defaultStyles!.indent!.horizontalSpacing;
    } else if (attrs.containsKey(Attribute.list.key)) {
      return defaultStyles!.lists!.horizontalSpacing;
    } else if (attrs.containsKey(Attribute.align.key)) {
      return defaultStyles!.align!.horizontalSpacing;
    }
    return HorizontalSpacing.zero;
  }

  VerticalSpacing _getVerticalSpacingForBlock(
      Block node, DefaultStyles? defaultStyles) {
    final attrs = node.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles!.quote!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles!.code!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.indent.key)) {
      return defaultStyles!.indent!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.list.key)) {
      return defaultStyles!.lists!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.align.key)) {
      return defaultStyles!.align!.verticalSpacing;
    }
    return VerticalSpacing.zero;
  }

  void _didChangeTextEditingValueListener() {
    _didChangeTextEditingValue(controller.ignoreFocusOnTextChange);
  }

  @override
  void initState() {
    super.initState();
    _shortcutActionsManager = EditorKeyboardShortcutsActionsManager(
      rawEditorState: this,
      context: context,
    );

    if (_clipboardStatus != null) {
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
    }

    controller.addListener(_didChangeTextEditingValueListener);

    _scrollController = widget.config.scrollController;
    _scrollController.addListener(_updateSelectionOverlayForScroll);

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(widget.config.showCursor),
      style: widget.config.cursorStyle,
      tickerProvider: this,
    );

    // Floating cursor
    _floatingCursorResetController = AnimationController(vsync: this);
    _floatingCursorResetController.addListener(onFloatingCursorResetTick);

    // listen to composing range changes
    composingRange.addListener(_onComposingRangeChanged);

    if (isKeyboardOS) {
      _keyboardVisible = true;
    } else if (!kIsWeb && isFlutterTest) {
      // treat tests like a keyboard OS
      _keyboardVisible = true;
    } else {
      // treat iOS Simulator like a keyboard OS
      isIOSSimulator().then((isIosSimulator) {
        if (isIosSimulator) {
          _keyboardVisible = true;
        } else {
          _keyboardVisibilityController = KeyboardVisibilityController();
          _keyboardVisible = _keyboardVisibilityController!.isVisible;
          _keyboardVisibilitySubscription =
              _keyboardVisibilityController?.onChange.listen((visible) {
            _keyboardVisible = visible;
            if (visible) {
              _onChangeTextEditingValue(!_hasFocus);
            }
          });

          HardwareKeyboard.instance.addHandler(_hardwareKeyboardEvent);
        }
      });
    }

    // Focus
    widget.config.focusNode.addListener(_handleFocusChanged);
  }

  // KeyboardVisibilityController only checks for keyboards that
  // adjust the screen size. Also watch for hardware keyboards
  // that don't alter the screen (i.e. Chromebook, Android tablet
  // and any hardware keyboards from an OS not listed in isKeyboardOS())
  bool _hardwareKeyboardEvent(KeyEvent _) {
    if (!_keyboardVisible) {
      // hardware keyboard key pressed. Set visibility to true
      _keyboardVisible = true;
      // update the editor
      _onChangeTextEditingValue(!_hasFocus);
    }

    // remove the key handler - it's no longer needed. If
    // KeyboardVisibilityController clears visibility, it wil
    // also enable it when appropriate.
    HardwareKeyboard.instance.removeHandler(_hardwareKeyboardEvent);

    // we didn't handle the event, just needed to know a key was pressed
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentStyles = QuillStyles.getStyles(context, true);
    final defaultStyles = DefaultStyles.getInstance(context);
    _styles = (parentStyles != null)
        ? defaultStyles.merge(parentStyles)
        : defaultStyles;

    if (widget.config.customStyles != null) {
      _styles = _styles!.merge(widget.config.customStyles!);
    }

    _requestAutoFocusIfShould();
  }

  Future<void> _requestAutoFocusIfShould() async {
    final focusManager = FocusScope.of(context);
    if (!_didAutoFocus && widget.config.autoFocus) {
      await Future.delayed(Duration.zero); // To avoid exceptions
      focusManager.autofocus(widget.config.focusNode);
      _didAutoFocus = true;
    }
  }

  @override
  void didUpdateWidget(QuillRawEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    _cursorCont.show.value = widget.config.showCursor;
    _cursorCont.style = widget.config.cursorStyle;

    if (controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_didChangeTextEditingValue);
      controller.addListener(_didChangeTextEditingValue);
      updateRemoteValueIfNeeded();
    }

    if (widget.config.scrollController != _scrollController) {
      _scrollController.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.config.scrollController;
      _scrollController.addListener(_updateSelectionOverlayForScroll);
    }

    if (widget.config.focusNode != oldWidget.config.focusNode) {
      oldWidget.config.focusNode.removeListener(_handleFocusChanged);
      widget.config.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
    }

    if (controller.selection != oldWidget.controller.selection) {
      _selectionOverlay?.update(textEditingValue);
    }

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();
    if (!shouldCreateInputConnection) {
      closeConnectionIfNeeded();
    } else {
      if (oldWidget.config.readOnly && _hasFocus) {
        openConnectionIfNeeded();
      }
    }

    // in case customStyles changed in new widget
    if (widget.config.customStyles != null) {
      _styles = _styles!.merge(widget.config.customStyles!);
    }
  }

  bool _shouldShowSelectionHandles() {
    return widget.config.showSelectionHandles &&
        !controller.selection.isCollapsed;
  }

  @override
  void dispose() {
    closeConnectionIfNeeded();
    _keyboardVisibilitySubscription?.cancel();
    HardwareKeyboard.instance.removeHandler(_hardwareKeyboardEvent);
    assert(!hasConnection);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    controller.removeListener(_didChangeTextEditingValueListener);
    widget.config.focusNode.removeListener(_handleFocusChanged);
    _cursorCont.dispose();
    composingRange.removeListener(_onComposingRangeChanged);
    if (_clipboardStatus != null) {
      _clipboardStatus!
        ..removeListener(_onChangedClipboardStatus)
        ..dispose();
    }
    super.dispose();
  }

  void _updateSelectionOverlayForScroll() {
    _selectionOverlay?.updateForScroll();
  }

  void _onComposingRangeChanged() {
    if (!mounted) {
      return;
    }
    _markNeedsBuild();
  }

  /// Marks the editor as dirty and trigger a rebuild.
  ///
  /// When the editor is dirty methods that depend on the editor
  /// state being in sync with the controller know they may be
  /// operating on stale data.
  void _markNeedsBuild() {
    setState(() {
      _dirty = true;
    });
  }

  void _didChangeTextEditingValue([bool ignoreFocus = false]) {
    if (kIsWeb) {
      _onChangeTextEditingValue(ignoreFocus);
      if (!ignoreFocus) {
        requestKeyboard();
      }
      return;
    }

    if (ignoreFocus || _keyboardVisible) {
      _onChangeTextEditingValue(ignoreFocus);
    } else {
      requestKeyboard();
      if (mounted) {
        // Use controller.value in build()
        // Mark widget as dirty and trigger build and updateChildren
        _markNeedsBuild();
      }
    }

    _shortcutActionsManager.adjacentLineAction
        .stopCurrentVerticalRunIfSelectionChanges();
  }

  void _onChangeTextEditingValue([bool ignoreCaret = false]) {
    updateRemoteValueIfNeeded();
    if (ignoreCaret) {
      return;
    }
    _showCaretOnScreen();
    _cursorCont.startOrStopCursorTimerIfNeeded(_hasFocus, controller.selection);
    if (hasConnection) {
      // To keep the cursor from blinking while typing, we want to restart the
      // cursor timer every time a new character is typed.
      _cursorCont
        ..stopCursorTimer(resetCharTicks: false)
        ..startCursorTimer();
    }

    // Refresh selection overlay after the build step had a chance to
    // update and register all children of RenderEditor. Otherwise this will
    // fail in situations where a new line of text is entered, which adds
    // a new RenderEditableBox child. If we try to update selection overlay
    // immediately it'll not be able to find the new child since it hasn't been
    // built yet.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateOrDisposeSelectionOverlayIfNeeded();
    });
    if (mounted) {
      // Use controller.value in build()
      // Mark widget as dirty and trigger build and updateChildren
      _markNeedsBuild();
    }
  }

  void _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      if (!_hasFocus || textEditingValue.selection.isCollapsed) {
        _selectionOverlay!.dispose();
        _selectionOverlay = null;
      } else {
        _selectionOverlay!.update(textEditingValue);
      }
    } else if (_hasFocus) {
      _selectionOverlay = EditorTextSelectionOverlay(
        value: textEditingValue,
        context: context,
        debugRequiredFor: widget,
        startHandleLayerLink: _startHandleLayerLink,
        endHandleLayerLink: _endHandleLayerLink,
        renderObject: renderEditor,
        selectionCtrls: widget.config.selectionCtrls,
        selectionDelegate: this,
        clipboardStatus: _clipboardStatus,
        contextMenuBuilder: widget.config.contextMenuBuilder == null
            ? null
            : (context) => widget.config.contextMenuBuilder!(context, this),
      );
      _selectionOverlay!.handlesVisible = _shouldShowSelectionHandles();
      _selectionOverlay!.showHandles();
    }
  }

  void _handleFocusChanged() {
    if (dirty) {
      requestKeyboard();
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _handleFocusChanged());
      return;
    }
    openOrCloseConnection();
    _cursorCont.startOrStopCursorTimerIfNeeded(_hasFocus, controller.selection);
    _updateOrDisposeSelectionOverlayIfNeeded();
    if (_hasFocus) {
      WidgetsBinding.instance.addObserver(this);
      _showCaretOnScreen();
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
    updateKeepAlive();
  }

  void _onChangedClipboardStatus() {
    if (!mounted) return;
    // Inform the widget that the value of clipboardStatus has changed.
    // Trigger build and updateChildren
    _markNeedsBuild();
  }

  Future<LinkMenuAction> _linkActionPicker(Node linkNode) async {
    final link = linkNode.style.attributes[Attribute.link.key]!.value!;
    return widget.config.linkActionPickerDelegate(context, link, linkNode);
  }

  bool _showCaretOnScreenScheduled = false;

  // This is a workaround for checkbox tapping issue
  // https://github.com/singerdmx/flutter-quill/issues/619
  // We cannot treat {"list": "checked"} and {"list": "unchecked"} as
  // block of the same style
  // This causes controller.selection to go to offset 0
  bool _disableScrollControllerAnimateOnce = false;

  void _showCaretOnScreen() {
    if (!widget.config.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.config.scrollable || _scrollController.hasClients) {
        _showCaretOnScreenScheduled = false;

        if (!mounted) {
          return;
        }

        final viewport = RenderAbstractViewport.of(renderEditor);
        final editorOffset =
            renderEditor.localToGlobal(const Offset(0, 0), ancestor: viewport);
        final offsetInViewport = _scrollController.offset + editorOffset.dy;

        final offset = renderEditor.getOffsetToRevealCursor(
          _scrollController.position.viewportDimension,
          _scrollController.offset,
          offsetInViewport,
        );

        if (offset != null) {
          if (_disableScrollControllerAnimateOnce) {
            _disableScrollControllerAnimateOnce = false;
            return;
          }
          _scrollController.animateTo(
            math.min(offset, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  /// The renderer for this widget's editor descendant.
  ///
  /// This property is typically used to notify the renderer of input gestures.
  @override
  RenderEditor get renderEditor =>
      _editorKey.currentContext!.findRenderObject() as RenderEditor;

  /// Express interest in interacting with the keyboard.
  ///
  /// If this control is already attached to the keyboard, this function will
  /// request that the keyboard become visible. Otherwise, this function will
  /// ask the focus system that it become focused. If successful in acquiring
  /// focus, the control will then attach to the keyboard and request that the
  /// keyboard become visible.
  @override
  void requestKeyboard() {
    if (controller.skipRequestKeyboard) {
      controller.skipRequestKeyboard = false;
      return;
    }
    if (_hasFocus) {
      final keyboardAlreadyShown = _keyboardVisible;
      openConnectionIfNeeded();
      if (!keyboardAlreadyShown) {
        /// delay 500 milliseconds for waiting keyboard show up
        Future.delayed(
          const Duration(milliseconds: 500),
          _showCaretOnScreen,
        );
      } else {
        _showCaretOnScreen();
      }
    } else {
      widget.config.focusNode.requestFocus();
    }
  }

  /// Shows the selection toolbar at the location of the current cursor.
  ///
  /// Returns `false` if a toolbar couldn't be shown, such as when the toolbar
  /// is already shown, or when no text selection currently exists.
  @override
  bool showToolbar() {
    // Web is using native dom elements to enable clipboard functionality of the
    // toolbar: copy, paste, select, cut. It might also provide additional
    // functionality depending on the browser (such as translate). Due to this
    // we should not show a Flutter toolbar for the editable text elements.
    if (kIsWeb) {
      return false;
    }

    // selectionOverlay is aggressively released when selection is collapsed
    // to remove unnecessary handles. Since a toolbar is requested here,
    // attempt to create the selectionOverlay if it's not already created.
    if (_selectionOverlay == null) {
      _updateOrDisposeSelectionOverlayIfNeeded();
    }

    if (_selectionOverlay == null || _selectionOverlay!.toolbar != null) {
      return false;
    }

    _selectionOverlay!.update(textEditingValue);
    _selectionOverlay!.showToolbar();
    return true;
  }

  @override
  bool get wantKeepAlive => widget.config.focusNode.hasFocus;

  @override
  AnimationController get floatingCursorResetController =>
      _floatingCursorResetController;

  late AnimationController _floatingCursorResetController;

  @override
  void insertTextPlaceholder(Size size) {
    // this is needed for Scribble (Stylus input) in Apple platforms
    // and this package does not implement this feature
  }

  @override
  void removeTextPlaceholder() {
    // this is needed for Scribble (Stylus input) in Apple platforms
    // and this package does not implement this feature
  }

  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {
    // TODO: implement didChangeInputControl
  }

  /// macOS-specific method that should not be called on other platforms.
  /// This method interacts with the `NSStandardKeyBindingResponding` protocol
  /// from Cocoa, which is available only on macOS systems.
  @override
  void performSelector(String selectorName) {
    assert(
      isMacOSApp,
      'Should call performSelector() only on macOS desktop platform.',
    );
    final intent = intentForMacOSSelector(selectorName);
    if (intent == null) {
      return;
    }
    final primaryContext = primaryFocus?.context;
    if (primaryContext == null) {
      return;
    }
    Actions.invoke(primaryContext, intent);
  }

  @override
  bool get liveTextInputEnabled => false;

  @override
  bool get lookUpEnabled => false;

  @override
  bool get searchWebEnabled => false;

  @override
  bool get shareEnabled => false;
}
