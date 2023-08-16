import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui hide TextStyle;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pasteboard/pasteboard.dart';

import '../models/documents/attribute.dart';
import '../models/documents/document.dart';
import '../models/documents/nodes/block.dart';
import '../models/documents/nodes/embeddable.dart';
import '../models/documents/nodes/leaf.dart' as leaf;
import '../models/documents/nodes/line.dart';
import '../models/documents/nodes/node.dart';
import '../models/structs/offset_value.dart';
import '../models/structs/vertical_spacing.dart';
import '../models/themes/quill_dialog_theme.dart';
import '../utils/cast.dart';
import '../utils/delta.dart';
import '../utils/embeds.dart';
import '../utils/platform.dart';
import 'controller.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';
import 'editor.dart';
import 'keyboard_listener.dart';
import 'link.dart';
import 'proxy.dart';
import 'quill_single_child_scroll_view.dart';
import 'raw_editor/raw_editor_state_selection_delegate_mixin.dart';
import 'raw_editor/raw_editor_state_text_input_client_mixin.dart';
import 'text_block.dart';
import 'text_line.dart';
import 'text_selection.dart';
import 'toolbar/link_style_button2.dart';
import 'toolbar/search_dialog.dart';

class RawEditor extends StatefulWidget {
  const RawEditor({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.scrollBottomInset,
    required this.cursorStyle,
    required this.selectionColor,
    required this.selectionCtrls,
    required this.embedBuilder,
    Key? key,
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.readOnly = false,
    this.placeholder,
    this.onLaunchUrl,
    this.contextMenuBuilder = defaultContextMenuBuilder,
    this.showSelectionHandles = false,
    bool? showCursor,
    this.textCapitalization = TextCapitalization.none,
    this.maxHeight,
    this.minHeight,
    this.maxContentWidth,
    this.customStyles,
    this.customShortcuts,
    this.customActions,
    this.expands = false,
    this.autoFocus = false,
    this.enableUnfocusOnTapOutside = true,
    this.keyboardAppearance = Brightness.light,
    this.enableInteractiveSelection = true,
    this.scrollPhysics,
    this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.floatingCursorDisabled = false,
    this.onImagePaste,
    this.customLinkPrefixes = const <String>[],
    this.dialogTheme,
    this.contentInsertionConfiguration,
  })  : assert(maxHeight == null || maxHeight > 0, 'maxHeight cannot be null'),
        assert(minHeight == null || minHeight >= 0, 'minHeight cannot be null'),
        assert(maxHeight == null || minHeight == null || maxHeight >= minHeight,
            'maxHeight cannot be null'),
        showCursor = showCursor ?? true,
        super(key: key);

  /// Controls the document being edited.
  final QuillController controller;

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final double scrollBottomInset;
  final bool enableUnfocusOnTapOutside;

  /// Additional space around the editor contents.
  final EdgeInsetsGeometry padding;

  /// Whether the text can be changed.
  ///
  /// When this is set to true, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to false. Must not be null.
  final bool readOnly;

  final String? placeholder;

  /// Callback which is triggered when the user wants to open a URL from
  /// a link in the document.
  final ValueChanged<String>? onLaunchUrl;

  /// Builds the text selection toolbar when requested by the user.
  ///
  /// See also:
  ///   * [EditableText.contextMenuBuilder], which builds the default
  ///     text selection toolbar for [EditableText].
  ///
  /// If not provided, no context menu will be shown.
  final QuillEditorContextMenuBuilder? contextMenuBuilder;

  static Widget defaultContextMenuBuilder(
    BuildContext context,
    RawEditorState state,
  ) {
    return TextFieldTapRegion(
      child: AdaptiveTextSelectionToolbar.buttonItems(
        buttonItems: state.contextMenuButtonItems,
        anchors: state.contextMenuAnchors,
      ),
    );
  }

  /// Whether to show selection handles.
  ///
  /// When a selection is active, there will be two handles at each side of
  /// boundary, or one handle if the selection is collapsed. The handles can be
  /// dragged to adjust the selection.
  ///
  /// See also:
  ///
  ///  * [showCursor], which controls the visibility of the cursor.
  final bool showSelectionHandles;

  /// Whether to show cursor.
  ///
  /// The cursor refers to the blinking caret when the editor is focused.
  ///
  /// See also:
  ///
  ///  * [cursorStyle], which controls the cursor visual representation.
  ///  * [showSelectionHandles], which controls the visibility of the selection
  ///    handles.
  final bool showCursor;

  /// The style to be used for the editing cursor.
  final CursorStyle cursorStyle;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  ///
  /// Only supports text keyboards, other keyboard types will ignore this
  /// configuration. Capitalization is locale-aware.
  ///
  /// Defaults to [TextCapitalization.none]. Must not be null.
  ///
  /// See also:
  ///
  ///  * [TextCapitalization], for a description of each capitalization behavior
  final TextCapitalization textCapitalization;

  /// The maximum height this editor can have.
  ///
  /// If this is null then there is no limit to the editor's height and it will
  /// expand to fill its parent.
  final double? maxHeight;

  /// The minimum height this editor can have.
  final double? minHeight;

  /// The maximum width to be occupied by the content of this editor.
  ///
  /// If this is not null and and this editor's width is larger than this value
  /// then the contents will be constrained to the provided maximum width and
  /// horizontally centered. This is mostly useful on devices with wide screens.
  final double? maxContentWidth;

  /// Allows to override [DefaultStyles].
  final DefaultStyles? customStyles;

  /// Whether this widget's height will be sized to fill its parent.
  ///
  /// If set to true and wrapped in a parent widget like [Expanded] or
  ///
  /// Defaults to false.
  final bool expands;

  /// Whether this editor should focus itself if nothing else is already
  /// focused.
  ///
  /// If true, the keyboard will open as soon as this text field obtains focus.
  /// Otherwise, the keyboard is only shown after the user taps the text field.
  ///
  /// Defaults to false. Cannot be null.
  final bool autoFocus;

  /// The color to use when painting the selection.
  final Color selectionColor;

  /// Delegate for building the text selection handles and toolbar.
  ///
  /// The [RawEditor] widget used on its own will not trigger the display
  /// of the selection toolbar by itself. The toolbar is shown by calling
  /// [RawEditorState.showToolbar] in response to an appropriate user event.
  final TextSelectionControls selectionCtrls;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

  /// If true, then long-pressing this TextField will select text and show the
  /// cut/copy/paste menu, and tapping will move the text caret.
  ///
  /// True by default.
  ///
  /// If false, most of the accessibility support for selecting text, copy
  /// and paste, and moving the caret will be disabled.
  final bool enableInteractiveSelection;

  bool get selectionEnabled => enableInteractiveSelection;

  /// The [ScrollPhysics] to use when vertically scrolling the input.
  ///
  /// If not specified, it will behave according to the current platform.
  ///
  /// See [Scrollable.physics].
  final ScrollPhysics? scrollPhysics;

  final Future<String?> Function(Uint8List imageBytes)? onImagePaste;

  /// Contains user-defined shortcuts map.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#shortcuts]
  final Map<ShortcutActivator, Intent>? customShortcuts;

  /// Contains user-defined actions.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#actions]
  final Map<Type, Action<Intent>>? customActions;

  /// Builder function for embeddable objects.
  final EmbedsBuilder embedBuilder;
  final LinkActionPickerDelegate linkActionPickerDelegate;
  final CustomStyleBuilder? customStyleBuilder;
  final CustomRecognizerBuilder? customRecognizerBuilder;
  final bool floatingCursorDisabled;
  final List<String> customLinkPrefixes;

  /// Configures the dialog theme.
  final QuillDialogTheme? dialogTheme;

  /// Configuration of handler for media content inserted via the system input
  /// method.
  ///
  /// See [https://api.flutter.dev/flutter/widgets/EditableText/contentInsertionConfiguration.html]
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  @override
  State<StatefulWidget> createState() => RawEditorState();
}

class RawEditorState extends EditorState
    with
        AutomaticKeepAliveClientMixin<RawEditor>,
        WidgetsBindingObserver,
        TickerProviderStateMixin<RawEditor>,
        RawEditorStateTextInputClientMixin,
        RawEditorStateSelectionDelegateMixin {
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

  bool get _hasFocus => widget.focusNode.hasFocus;

  // Theme
  DefaultStyles? _styles;

  // for pasting style
  @override
  List<OffsetValue> get pasteStyleAndEmbed => _pasteStyleAndEmbed;
  List<OffsetValue> _pasteStyleAndEmbed = <OffsetValue>[];

  @override
  String get pastePlainText => _pastePlainText;
  String _pastePlainText = '';

  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  TextDirection get _textDirection => Directionality.of(context);

  @override
  bool get dirty => _dirty;
  bool _dirty = false;

  @override
  void insertContent(KeyboardInsertedContent content) {
    assert(widget.contentInsertionConfiguration?.allowedMimeTypes
            .contains(content.mimeType) ??
        false);
    widget.contentInsertionConfiguration?.onContentInserted.call(content);
  }

  /// Returns the [ContextMenuButtonItem]s representing the buttons in this
  /// platform's default selection menu for [RawEditor].
  ///
  /// Copied from [EditableTextState].
  List<ContextMenuButtonItem> get contextMenuButtonItems {
    return EditableText.getEditableButtonItems(
      clipboardStatus: _clipboardStatus.value,
      onLiveTextInput: null,
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
    );
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
  /// [RawEditorState].
  ///
  /// Copied from [EditableTextState].
  _GlyphHeights _getGlyphHeights() {
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
      return _GlyphHeights(
        renderEditor.preferredLineHeight(selection.base),
        renderEditor.preferredLineHeight(selection.base),
      );
    }

    final startCharacterRect =
        renderEditor.getLocalRectForCaret(selection.base);
    final endCharacterRect =
        renderEditor.getLocalRectForCaret(selection.extent);
    return _GlyphHeights(
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
            if (kIsWeb) {
              widget.focusNode.unfocus();
            }
            break;
          case ui.PointerDeviceKind.mouse:
          case ui.PointerDeviceKind.stylus:
          case ui.PointerDeviceKind.invertedStylus:
          case ui.PointerDeviceKind.unknown:
            widget.focusNode.unfocus();
            break;
          case ui.PointerDeviceKind.trackpad:
            throw UnimplementedError(
                'Unexpected pointer down event for trackpad');
        }
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        widget.focusNode.unfocus();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    super.build(context);

    var _doc = controller.document;
    if (_doc.isEmpty() && widget.placeholder != null) {
      final raw = widget.placeholder?.replaceAll(r'"', '\\"');
      _doc = Document.fromJson(jsonDecode(
          '[{"attributes":{"placeholder":true},"insert":"$raw\\n"}]'));
    }

    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: Semantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          child: _Editor(
            key: _editorKey,
            document: _doc,
            selection: controller.selection,
            hasFocus: _hasFocus,
            scrollable: widget.scrollable,
            cursorController: _cursorCont,
            textDirection: _textDirection,
            startHandleLayerLink: _startHandleLayerLink,
            endHandleLayerLink: _endHandleLayerLink,
            onSelectionChanged: _handleSelectionChanged,
            onSelectionCompleted: _handleSelectionCompleted,
            scrollBottomInset: widget.scrollBottomInset,
            padding: widget.padding,
            maxContentWidth: widget.maxContentWidth,
            floatingCursorDisabled: widget.floatingCursorDisabled,
            children: _buildChildren(_doc, context),
          ),
        ),
      ),
    );

    if (widget.scrollable) {
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
        child: QuillSingleChildScrollView(
          controller: _scrollController,
          physics: widget.scrollPhysics,
          viewportBuilder: (_, offset) => CompositedTransformTarget(
            link: _toolbarLayerLink,
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: _Editor(
                key: _editorKey,
                offset: offset,
                document: _doc,
                selection: controller.selection,
                hasFocus: _hasFocus,
                scrollable: widget.scrollable,
                textDirection: _textDirection,
                startHandleLayerLink: _startHandleLayerLink,
                endHandleLayerLink: _endHandleLayerLink,
                onSelectionChanged: _handleSelectionChanged,
                onSelectionCompleted: _handleSelectionCompleted,
                scrollBottomInset: widget.scrollBottomInset,
                padding: widget.padding,
                maxContentWidth: widget.maxContentWidth,
                cursorController: _cursorCont,
                floatingCursorDisabled: widget.floatingCursorDisabled,
                children: _buildChildren(_doc, context),
              ),
            ),
          ),
        ),
      );
    }

    final constraints = widget.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.minHeight ?? 0.0,
            maxHeight: widget.maxHeight ?? double.infinity);

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return TextFieldTapRegion(
      enabled: widget.enableUnfocusOnTapOutside,
      onTapOutside: _defaultOnTapOutside,
      child: QuillStyles(
        data: _styles!,
        child: Shortcuts(
          shortcuts: mergeMaps<ShortcutActivator, Intent>({
            // shortcuts added for Desktop platforms.
            const SingleActivator(
              LogicalKeyboardKey.escape,
            ): const HideSelectionToolbarIntent(),
            SingleActivator(
              LogicalKeyboardKey.keyZ,
              control: !isMacOS,
              meta: isMacOS,
            ): const UndoTextIntent(SelectionChangedCause.keyboard),
            SingleActivator(
              LogicalKeyboardKey.keyY,
              control: !isMacOS,
              meta: isMacOS,
            ): const RedoTextIntent(SelectionChangedCause.keyboard),

            // Selection formatting.
            SingleActivator(
              LogicalKeyboardKey.keyB,
              control: !isMacOS,
              meta: isMacOS,
            ): const ToggleTextStyleIntent(Attribute.bold),
            SingleActivator(
              LogicalKeyboardKey.keyU,
              control: !isMacOS,
              meta: isMacOS,
            ): const ToggleTextStyleIntent(Attribute.underline),
            SingleActivator(
              LogicalKeyboardKey.keyI,
              control: !isMacOS,
              meta: isMacOS,
            ): const ToggleTextStyleIntent(Attribute.italic),
            SingleActivator(
              LogicalKeyboardKey.keyS,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.strikeThrough),
            SingleActivator(
              LogicalKeyboardKey.backquote,
              control: !isMacOS,
              meta: isMacOS,
            ): const ToggleTextStyleIntent(Attribute.inlineCode),
            SingleActivator(
              LogicalKeyboardKey.tilde,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.codeBlock),
            SingleActivator(
              LogicalKeyboardKey.keyB,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.blockQuote),
            SingleActivator(
              LogicalKeyboardKey.keyK,
              control: !isMacOS,
              meta: isMacOS,
            ): const ApplyLinkIntent(),

            // Lists
            SingleActivator(
              LogicalKeyboardKey.keyL,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.ul),
            SingleActivator(
              LogicalKeyboardKey.keyO,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.ol),
            SingleActivator(
              LogicalKeyboardKey.keyC,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const ApplyCheckListIntent(),

            // Indents
            SingleActivator(
              LogicalKeyboardKey.keyM,
              control: !isMacOS,
              meta: isMacOS,
            ): const IndentSelectionIntent(true),
            SingleActivator(
              LogicalKeyboardKey.keyM,
              control: !isMacOS,
              meta: isMacOS,
              shift: true,
            ): const IndentSelectionIntent(false),

            // Headers
            SingleActivator(
              LogicalKeyboardKey.digit1,
              control: !isMacOS,
              meta: isMacOS,
            ): const ApplyHeaderIntent(Attribute.h1),
            SingleActivator(
              LogicalKeyboardKey.digit2,
              control: !isMacOS,
              meta: isMacOS,
            ): const ApplyHeaderIntent(Attribute.h2),
            SingleActivator(
              LogicalKeyboardKey.digit3,
              control: !isMacOS,
              meta: isMacOS,
            ): const ApplyHeaderIntent(Attribute.h3),
            SingleActivator(
              LogicalKeyboardKey.digit0,
              control: !isMacOS,
              meta: isMacOS,
            ): const ApplyHeaderIntent(Attribute.header),

            SingleActivator(
              LogicalKeyboardKey.keyG,
              control: !isMacOS,
              meta: isMacOS,
            ): const InsertEmbedIntent(Attribute.image),

            SingleActivator(
              LogicalKeyboardKey.keyF,
              control: !isMacOS,
              meta: isMacOS,
            ): const OpenSearchIntent(),
          }, {
            ...?widget.customShortcuts
          }),
          child: Actions(
            actions: mergeMaps<Type, Action<Intent>>(_actions, {
              ...?widget.customActions,
            }),
            child: Focus(
              focusNode: widget.focusNode,
              onKey: _onKey,
              child: QuillKeyboardListener(
                child: Container(
                  constraints: constraints,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKey(node, RawKeyEvent event) {
    // Don't handle key if there is a meta key pressed.
    if (event.isAltPressed || event.isControlPressed || event.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }
    // Handle indenting blocks when pressing the tab key.
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      return _handleTabKey(event);
    }

    // Don't handle key if there is an active selection.
    if (controller.selection.baseOffset != controller.selection.extentOffset) {
      return KeyEventResult.ignored;
    }

    // Handle inserting lists when space is pressed following
    // a list initiating phrase.
    if (event.logicalKey == LogicalKeyboardKey.space) {
      return _handleSpaceKey(event);
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSpaceKey(RawKeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);
    if (child.node == null) {
      return KeyEventResult.ignored;
    }

    final line = child.node as Line?;
    if (line == null) {
      return KeyEventResult.ignored;
    }

    final text = castOrNull<leaf.Text>(line.first);
    if (text == null) {
      return KeyEventResult.ignored;
    }

    const olKeyPhrase = '1.';
    const ulKeyPhrase = '-';

    if (text.value == olKeyPhrase) {
      _updateSelectionForKeyPhrase(olKeyPhrase, Attribute.ol);
    } else if (text.value == ulKeyPhrase) {
      _updateSelectionForKeyPhrase(ulKeyPhrase, Attribute.ul);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _handleTabKey(RawKeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);

    KeyEventResult insertTabCharacter() {
      controller.replaceText(controller.selection.baseOffset, 0, '\t', null);
      _moveCursor(1);
      return KeyEventResult.handled;
    }

    if (controller.selection.baseOffset != controller.selection.extentOffset) {
      if (child.node == null || child.node!.parent == null) {
        return KeyEventResult.handled;
      }
      final parentBlock = child.node!.parent!;
      if (parentBlock.style.containsKey(Attribute.ol.key) ||
          parentBlock.style.containsKey(Attribute.ul.key) ||
          parentBlock.style.containsKey(Attribute.checked.key)) {
        controller.indentSelection(!event.isShiftPressed);
      }
      return KeyEventResult.handled;
    }

    if (child.node == null) {
      return insertTabCharacter();
    }

    final node = child.node!;

    final parent = node.parent;
    if (parent == null || parent is! Block) {
      return insertTabCharacter();
    }

    if (node is! Line || (node.isNotEmpty && node.first is! leaf.Text)) {
      return insertTabCharacter();
    }

    final parentBlock = parent;
    if (parentBlock.style.containsKey(Attribute.ol.key) ||
        parentBlock.style.containsKey(Attribute.ul.key) ||
        parentBlock.style.containsKey(Attribute.checked.key)) {
      if (node.isNotEmpty &&
          (node.first as leaf.Text).value.isNotEmpty &&
          controller.selection.base.offset > node.documentOffset) {
        return insertTabCharacter();
      }
      controller.indentSelection(!event.isShiftPressed);
      return KeyEventResult.handled;
    }

    if (node.isNotEmpty && (node.first as leaf.Text).value.isNotEmpty) {
      return insertTabCharacter();
    }

    return insertTabCharacter();
  }

  void _moveCursor(int chars) {
    final selection = controller.selection;
    controller.updateSelection(
        controller.selection.copyWith(
            baseOffset: selection.baseOffset + chars,
            extentOffset: selection.baseOffset + chars),
        ChangeSource.LOCAL);
  }

  void _updateSelectionForKeyPhrase(String phrase, Attribute attribute) {
    controller.replaceText(controller.selection.baseOffset - phrase.length,
        phrase.length, '\n', null);
    _moveCursor(-phrase.length);
    controller
      ..formatSelection(attribute)
      // Remove the added newline.
      ..replaceText(controller.selection.baseOffset + 1, 1, '', null);
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    final oldSelection = controller.selection;
    controller.updateSelection(selection, ChangeSource.LOCAL);

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
    if (!widget.readOnly) {
      _disableScrollControllerAnimateOnce = true;
      final currentSelection = controller.selection.copyWith();
      final attribute = value ? Attribute.checked : Attribute.unchecked;

      _markNeedsBuild();
      controller
        ..ignoreFocusOnTextChange = true
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
          ..updateSelection(currentSelection, ChangeSource.LOCAL);
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

      if (prevNodeOl && attrs[Attribute.list.key] != Attribute.ol) {
        clearIndents = true;
      }

      prevNodeOl = attrs[Attribute.list.key] == Attribute.ol;

      if (node is Line) {
        final editableTextLine = _getEditableTextLineFromNode(node, context);
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextLine));
      } else if (node is Block) {
        final editableTextBlock = EditableTextBlock(
            block: node,
            controller: controller,
            textDirection: getDirectionOfNode(node),
            scrollBottomInset: widget.scrollBottomInset,
            verticalSpacing: _getVerticalSpacingForBlock(node, _styles),
            textSelection: controller.selection,
            color: widget.selectionColor,
            styles: _styles,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            hasFocus: _hasFocus,
            contentPadding: attrs.containsKey(Attribute.codeBlock.key)
                ? const EdgeInsets.all(16)
                : null,
            embedBuilder: widget.embedBuilder,
            linkActionPicker: _linkActionPicker,
            onLaunchUrl: widget.onLaunchUrl,
            cursorCont: _cursorCont,
            indentLevelCounts: indentLevelCounts,
            clearIndents: clearIndents,
            onCheckboxTap: _handleCheckboxTap,
            readOnly: widget.readOnly,
            customStyleBuilder: widget.customStyleBuilder,
            customLinkPrefixes: widget.customLinkPrefixes);
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextBlock));

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
      embedBuilder: widget.embedBuilder,
      customStyleBuilder: widget.customStyleBuilder,
      customRecognizerBuilder: widget.customRecognizerBuilder,
      styles: _styles!,
      readOnly: widget.readOnly,
      controller: controller,
      linkActionPicker: _linkActionPicker,
      onLaunchUrl: widget.onLaunchUrl,
      customLinkPrefixes: widget.customLinkPrefixes,
    );
    final editableTextLine = EditableTextLine(
        node,
        null,
        textLine,
        0,
        _getVerticalSpacingForLine(node, _styles),
        _textDirection,
        controller.selection,
        widget.selectionColor,
        widget.enableInteractiveSelection,
        _hasFocus,
        MediaQuery.of(context).devicePixelRatio,
        _cursorCont);
    return editableTextLine;
  }

  VerticalSpacing _getVerticalSpacingForLine(
      Line line, DefaultStyles? defaultStyles) {
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
        default:
          throw 'Invalid level $level';
      }
    }

    return defaultStyles!.paragraph!.verticalSpacing;
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
    return const VerticalSpacing(0, 0);
  }

  @override
  void initState() {
    super.initState();

    _clipboardStatus.addListener(_onChangedClipboardStatus);

    controller.addListener(() {
      _didChangeTextEditingValue(controller.ignoreFocusOnTextChange);
    });

    _scrollController = widget.scrollController;
    _scrollController.addListener(_updateSelectionOverlayForScroll);

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(widget.showCursor),
      style: widget.cursorStyle,
      tickerProvider: this,
    );

    // Floating cursor
    _floatingCursorResetController = AnimationController(vsync: this);
    _floatingCursorResetController.addListener(onFloatingCursorResetTick);

    if (isKeyboardOS()) {
      _keyboardVisible = true;
    } else if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
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
    widget.focusNode.addListener(_handleFocusChanged);
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

    if (widget.customStyles != null) {
      _styles = _styles!.merge(widget.customStyles!);
    }

    if (!_didAutoFocus && widget.autoFocus) {
      FocusScope.of(context).autofocus(widget.focusNode);
      _didAutoFocus = true;
    }
  }

  @override
  void didUpdateWidget(RawEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    _cursorCont.show.value = widget.showCursor;
    _cursorCont.style = widget.cursorStyle;

    if (controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_didChangeTextEditingValue);
      controller.addListener(_didChangeTextEditingValue);
      updateRemoteValueIfNeeded();
    }

    if (widget.scrollController != _scrollController) {
      _scrollController.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.scrollController;
      _scrollController.addListener(_updateSelectionOverlayForScroll);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
    }

    if (controller.selection != oldWidget.controller.selection) {
      _selectionOverlay?.update(textEditingValue);
    }

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();
    if (!shouldCreateInputConnection) {
      closeConnectionIfNeeded();
    } else {
      if (oldWidget.readOnly && _hasFocus) {
        openConnectionIfNeeded();
      }
    }

    // in case customStyles changed in new widget
    if (widget.customStyles != null) {
      _styles = _styles!.merge(widget.customStyles!);
    }
  }

  bool _shouldShowSelectionHandles() {
    return widget.showSelectionHandles && !controller.selection.isCollapsed;
  }

  @override
  void dispose() {
    closeConnectionIfNeeded();
    _keyboardVisibilitySubscription?.cancel();
    HardwareKeyboard.instance.removeHandler(_hardwareKeyboardEvent);
    assert(!hasConnection);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    controller.removeListener(_didChangeTextEditingValue);
    widget.focusNode.removeListener(_handleFocusChanged);
    _cursorCont.dispose();
    _clipboardStatus
      ..removeListener(_onChangedClipboardStatus)
      ..dispose();
    super.dispose();
  }

  void _updateSelectionOverlayForScroll() {
    _selectionOverlay?.updateForScroll();
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

    _adjacentLineAction.stopCurrentVerticalRunIfSelectionChanges();
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
        selectionCtrls: widget.selectionCtrls,
        selectionDelegate: this,
        clipboardStatus: _clipboardStatus,
        contextMenuBuilder: widget.contextMenuBuilder == null
            ? null
            : (context) => widget.contextMenuBuilder!(context, this),
      );
      _selectionOverlay!.handlesVisible = _shouldShowSelectionHandles();
      _selectionOverlay!.showHandles();
    }
  }

  void _handleFocusChanged() {
    if (dirty) {
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
    return widget.linkActionPickerDelegate(context, link, linkNode);
  }

  bool _showCaretOnScreenScheduled = false;

  // This is a workaround for checkbox tapping issue
  // https://github.com/singerdmx/flutter-quill/issues/619
  // We cannot treat {"list": "checked"} and {"list": "unchecked"} as
  // block of the same style
  // This causes controller.selection to go to offset 0
  bool _disableScrollControllerAnimateOnce = false;

  void _showCaretOnScreen() {
    if (!widget.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollable || _scrollController.hasClients) {
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
        Future.delayed(const Duration(milliseconds: 500), _showCaretOnScreen);
      } else {
        _showCaretOnScreen();
      }
    } else {
      widget.focusNode.requestFocus();
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

  void _replaceText(ReplaceTextIntent intent) {
    userUpdateTextEditingValue(
      intent.currentTextEditingValue
          .replaced(intent.replacementRange, intent.replacementText),
      intent.cause,
    );
  }

  /// Copy current selection to [Clipboard].
  @override
  void copySelection(SelectionChangedCause cause) {
    controller.copiedImageUrl = null;
    _pastePlainText = controller.getPlainText();
    _pasteStyleAndEmbed = controller.getAllIndividualSelectionStylesAndEmbed();

    final selection = textEditingValue.selection;
    final text = textEditingValue.text;
    if (selection.isCollapsed) {
      return;
    }
    Clipboard.setData(ClipboardData(text: selection.textInside(text)));

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);

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
    controller.copiedImageUrl = null;
    _pastePlainText = controller.getPlainText();
    _pasteStyleAndEmbed = controller.getAllIndividualSelectionStylesAndEmbed();

    if (widget.readOnly) {
      return;
    }
    final selection = textEditingValue.selection;
    final text = textEditingValue.text;
    if (selection.isCollapsed) {
      return;
    }
    Clipboard.setData(ClipboardData(text: selection.textInside(text)));
    _replaceText(ReplaceTextIntent(textEditingValue, '', selection, cause));

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  /// Paste text from [Clipboard].
  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    if (widget.readOnly) {
      return;
    }

    if (controller.copiedImageUrl != null) {
      final index = textEditingValue.selection.baseOffset;
      final length = textEditingValue.selection.extentOffset - index;
      final copied = controller.copiedImageUrl!;
      controller.replaceText(index, length, BlockEmbed.image(copied.url), null);
      if (copied.styleString.isNotEmpty) {
        controller.formatText(getEmbedNode(controller, index + 1).offset, 1,
            StyleAttribute(copied.styleString));
      }
      controller.copiedImageUrl = null;
      await Clipboard.setData(const ClipboardData(text: ''));
      return;
    }

    final selection = textEditingValue.selection;
    if (!selection.isValid) {
      return;
    }
    // Snapshot the input before using `await`.
    // See https://github.com/flutter/flutter/issues/11427
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text != null) {
      _replaceText(
          ReplaceTextIntent(textEditingValue, text.text!, selection, cause));

      bringIntoView(textEditingValue.selection.extent);

      // Collapse the selection and hide the toolbar and handles.
      userUpdateTextEditingValue(
        TextEditingValue(
          text: textEditingValue.text,
          selection:
              TextSelection.collapsed(offset: textEditingValue.selection.end),
        ),
        cause,
      );

      return;
    }

    if (widget.onImagePaste != null) {
      final image = await Pasteboard.image;

      if (image == null) {
        return;
      }

      final imageUrl = await widget.onImagePaste!(image);
      if (imageUrl == null) {
        return;
      }

      controller.replaceText(
        textEditingValue.selection.end,
        0,
        BlockEmbed.image(imageUrl),
        null,
      );
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

  @override
  bool get wantKeepAlive => widget.focusNode.hasFocus;

  @override
  AnimationController get floatingCursorResetController =>
      _floatingCursorResetController;

  late AnimationController _floatingCursorResetController;

  // --------------------------- Text Editing Actions --------------------------

  _TextBoundary _characterBoundary(DirectionalTextEditingIntent intent) {
    final _TextBoundary atomicTextBoundary =
        _CharacterBoundary(textEditingValue);
    return _CollapsedSelectionBoundary(atomicTextBoundary, intent.forward);
  }

  _TextBoundary _nextWordBoundary(DirectionalTextEditingIntent intent) {
    final _TextBoundary atomicTextBoundary;
    final _TextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueforTextLayoutMetrics;
    atomicTextBoundary = _CharacterBoundary(textEditingValue);
    // This isn't enough. Newline characters.
    boundary = _ExpandedTextBoundary(_WhitespaceBoundary(textEditingValue),
        _WordBoundary(renderEditor, textEditingValue));

    final mixedBoundary = intent.forward
        ? _MixedBoundary(atomicTextBoundary, boundary)
        : _MixedBoundary(boundary, atomicTextBoundary);
    // Use a _MixedBoundary to make sure we don't leave invalid codepoints in
    // the field after deletion.
    return _CollapsedSelectionBoundary(mixedBoundary, intent.forward);
  }

  _TextBoundary _linebreak(DirectionalTextEditingIntent intent) {
    final _TextBoundary atomicTextBoundary;
    final _TextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueforTextLayoutMetrics;
    atomicTextBoundary = _CharacterBoundary(textEditingValue);
    boundary = _LineBreak(renderEditor, textEditingValue);

    // The _MixedBoundary is to make sure we don't leave invalid code units in
    // the field after deletion.
    // `boundary` doesn't need to be wrapped in a _CollapsedSelectionBoundary,
    // since the document boundary is unique and the linebreak boundary is
    // already caret-location based.
    return intent.forward
        ? _MixedBoundary(
            _CollapsedSelectionBoundary(atomicTextBoundary, true), boundary)
        : _MixedBoundary(
            boundary, _CollapsedSelectionBoundary(atomicTextBoundary, false));
  }

  _TextBoundary _documentBoundary(DirectionalTextEditingIntent intent) =>
      _DocumentBoundary(textEditingValue);

  Action<T> _makeOverridable<T extends Intent>(Action<T> defaultAction) {
    return Action<T>.overridable(
        context: context, defaultAction: defaultAction);
  }

  late final Action<ReplaceTextIntent> _replaceTextAction =
      CallbackAction<ReplaceTextIntent>(onInvoke: _replaceText);

  void _updateSelection(UpdateSelectionIntent intent) {
    userUpdateTextEditingValue(
      intent.currentTextEditingValue.copyWith(selection: intent.newSelection),
      intent.cause,
    );
  }

  late final Action<UpdateSelectionIntent> _updateSelectionAction =
      CallbackAction<UpdateSelectionIntent>(onInvoke: _updateSelection);

  late final _UpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent> _adjacentLineAction =
      _UpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent>(this);

  late final _ToggleTextStyleAction _formatSelectionAction =
      _ToggleTextStyleAction(this);

  late final _IndentSelectionAction _indentSelectionAction =
      _IndentSelectionAction(this);

  late final _OpenSearchAction _openSearchAction = _OpenSearchAction(this);
  late final _ApplyHeaderAction _applyHeaderAction = _ApplyHeaderAction(this);
  late final _ApplyCheckListAction _applyCheckListAction =
      _ApplyCheckListAction(this);

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    DoNothingAndStopPropagationTextIntent: DoNothingAction(consumesKey: false),
    ReplaceTextIntent: _replaceTextAction,
    UpdateSelectionIntent: _updateSelectionAction,
    DirectionalFocusIntent: DirectionalFocusAction.forTextField(),

    // Delete
    DeleteCharacterIntent: _makeOverridable(
        _DeleteTextAction<DeleteCharacterIntent>(this, _characterBoundary)),
    DeleteToNextWordBoundaryIntent: _makeOverridable(
        _DeleteTextAction<DeleteToNextWordBoundaryIntent>(
            this, _nextWordBoundary)),
    DeleteToLineBreakIntent: _makeOverridable(
        _DeleteTextAction<DeleteToLineBreakIntent>(this, _linebreak)),

    // Extend/Move Selection
    ExtendSelectionByCharacterIntent: _makeOverridable(
        _UpdateTextSelectionAction<ExtendSelectionByCharacterIntent>(
      this,
      false,
      _characterBoundary,
    )),
    ExtendSelectionToNextWordBoundaryIntent: _makeOverridable(
        _UpdateTextSelectionAction<ExtendSelectionToNextWordBoundaryIntent>(
            this, true, _nextWordBoundary)),
    ExtendSelectionToLineBreakIntent: _makeOverridable(
        _UpdateTextSelectionAction<ExtendSelectionToLineBreakIntent>(
            this, true, _linebreak)),
    ExtendSelectionVerticallyToAdjacentLineIntent:
        _makeOverridable(_adjacentLineAction),
    ExtendSelectionToDocumentBoundaryIntent: _makeOverridable(
        _UpdateTextSelectionAction<ExtendSelectionToDocumentBoundaryIntent>(
            this, true, _documentBoundary)),
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent: _makeOverridable(
        _ExtendSelectionOrCaretPositionAction(this, _nextWordBoundary)),

    // Copy Paste
    SelectAllTextIntent: _makeOverridable(_SelectAllAction(this)),
    CopySelectionTextIntent: _makeOverridable(_CopySelectionAction(this)),
    PasteTextIntent: _makeOverridable(CallbackAction<PasteTextIntent>(
        onInvoke: (intent) => pasteText(intent.cause))),

    HideSelectionToolbarIntent:
        _makeOverridable(_HideSelectionToolbarAction(this)),
    UndoTextIntent: _makeOverridable(_UndoKeyboardAction(this)),
    RedoTextIntent: _makeOverridable(_RedoKeyboardAction(this)),

    OpenSearchIntent: _openSearchAction,

    // Selection Formatting
    ToggleTextStyleIntent: _formatSelectionAction,
    IndentSelectionIntent: _indentSelectionAction,
    ApplyHeaderIntent: _applyHeaderAction,
    ApplyCheckListIntent: _applyCheckListAction,
    ApplyLinkIntent: ApplyLinkAction(this)
  };

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
      TextInputControl? oldControl, TextInputControl? newControl) {
    // TODO: implement didChangeInputControl
  }

  @override
  void performSelector(String selectorName) {
    final intent = intentForMacOSSelector(selectorName);

    if (intent != null) {
      final primaryContext = primaryFocus?.context;
      if (primaryContext != null) {
        Actions.invoke(primaryContext, intent);
      }
    }
  }

  @override
  // TODO: implement liveTextInputEnabled
  bool get liveTextInputEnabled => false;
}

class _Editor extends MultiChildRenderObjectWidget {
  const _Editor({
    required Key key,
    required List<Widget> children,
    required this.document,
    required this.textDirection,
    required this.hasFocus,
    required this.scrollable,
    required this.selection,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.onSelectionChanged,
    required this.onSelectionCompleted,
    required this.scrollBottomInset,
    required this.cursorController,
    required this.floatingCursorDisabled,
    this.padding = EdgeInsets.zero,
    this.maxContentWidth,
    this.offset,
  }) : super(key: key, children: children);

  final ViewportOffset? offset;
  final Document document;
  final TextDirection textDirection;
  final bool hasFocus;
  final bool scrollable;
  final TextSelection selection;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final TextSelectionChangedHandler onSelectionChanged;
  final TextSelectionCompletedHandler onSelectionCompleted;
  final double scrollBottomInset;
  final EdgeInsetsGeometry padding;
  final double? maxContentWidth;
  final CursorCont cursorController;
  final bool floatingCursorDisabled;

  @override
  RenderEditor createRenderObject(BuildContext context) {
    return RenderEditor(
        offset: offset,
        document: document,
        textDirection: textDirection,
        hasFocus: hasFocus,
        scrollable: scrollable,
        selection: selection,
        startHandleLayerLink: startHandleLayerLink,
        endHandleLayerLink: endHandleLayerLink,
        onSelectionChanged: onSelectionChanged,
        onSelectionCompleted: onSelectionCompleted,
        cursorController: cursorController,
        padding: padding,
        maxContentWidth: maxContentWidth,
        scrollBottomInset: scrollBottomInset,
        floatingCursorDisabled: floatingCursorDisabled);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditor renderObject) {
    renderObject
      ..offset = offset
      ..document = document
      ..setContainer(document.root)
      ..textDirection = textDirection
      ..setHasFocus(hasFocus)
      ..setSelection(selection)
      ..setStartHandleLayerLink(startHandleLayerLink)
      ..setEndHandleLayerLink(endHandleLayerLink)
      ..onSelectionChanged = onSelectionChanged
      ..setScrollBottomInset(scrollBottomInset)
      ..setPadding(padding)
      ..maxContentWidth = maxContentWidth;
  }
}

/// An interface for retrieving the logical text boundary
/// (left-closed-right-open)
/// at a given location in a document.
///
/// Depending on the implementation of the [_TextBoundary], the input
/// [TextPosition] can either point to a code unit, or a position between 2 code
/// units (which can be visually represented by the caret if the selection were
/// to collapse to that position).
///
/// For example, [_LineBreak] interprets the input [TextPosition] as a caret
/// location, since in Flutter the caret is generally painted between the
/// character the [TextPosition] points to and its previous character, and
/// [_LineBreak] cares about the affinity of the input [TextPosition]. Most
/// other text boundaries however, interpret the input [TextPosition] as the
/// location of a code unit in the document, since it's easier to reason about
/// the text boundary given a code unit in the text.
///
/// To convert a "code-unit-based" [_TextBoundary] to "caret-location-based",
/// use the [_CollapsedSelectionBoundary] combinator.
abstract class _TextBoundary {
  const _TextBoundary();

  TextEditingValue get textEditingValue;

  /// Returns the leading text boundary at the given location, inclusive.
  TextPosition getLeadingTextBoundaryAt(TextPosition position);

  /// Returns the trailing text boundary at the given location, exclusive.
  TextPosition getTrailingTextBoundaryAt(TextPosition position);

  TextRange getTextBoundaryAt(TextPosition position) {
    return TextRange(
      start: getLeadingTextBoundaryAt(position).offset,
      end: getTrailingTextBoundaryAt(position).offset,
    );
  }
}

// -----------------------------  Text Boundaries -----------------------------

// The word modifier generally removes the word boundaries around white spaces
// (and newlines), IOW white spaces and some other punctuations are considered
// a part of the next word in the search direction.
class _WhitespaceBoundary extends _TextBoundary {
  const _WhitespaceBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    for (var index = position.offset; index >= 0; index -= 1) {
      if (!TextLayoutMetrics.isWhitespace(
          textEditingValue.text.codeUnitAt(index))) {
        return TextPosition(offset: index);
      }
    }
    return const TextPosition(offset: 0);
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    for (var index = position.offset;
        index < textEditingValue.text.length;
        index += 1) {
      if (!TextLayoutMetrics.isWhitespace(
          textEditingValue.text.codeUnitAt(index))) {
        return TextPosition(offset: index + 1);
      }
    }
    return TextPosition(offset: textEditingValue.text.length);
  }
}

// Most apps delete the entire grapheme when the backspace key is pressed.
// Also always put the new caret location to character boundaries to avoid
// sending malformed UTF-16 code units to the paragraph builder.
class _CharacterBoundary extends _TextBoundary {
  const _CharacterBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    return TextPosition(
      offset:
          CharacterRange.at(textEditingValue.text, position.offset, endOffset)
              .stringBeforeLength,
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    final range =
        CharacterRange.at(textEditingValue.text, position.offset, endOffset);
    return TextPosition(
      offset: textEditingValue.text.length - range.stringAfterLength,
    );
  }

  @override
  TextRange getTextBoundaryAt(TextPosition position) {
    final int endOffset =
        math.min(position.offset + 1, textEditingValue.text.length);
    final range =
        CharacterRange.at(textEditingValue.text, position.offset, endOffset);
    return TextRange(
      start: range.stringBeforeLength,
      end: textEditingValue.text.length - range.stringAfterLength,
    );
  }
}

// [UAX #29](https://unicode.org/reports/tr29/) defined word boundaries.
class _WordBoundary extends _TextBoundary {
  const _WordBoundary(this.textLayout, this.textEditingValue);

  final TextLayoutMetrics textLayout;

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).start,
      // Word boundary seems to always report downstream on many platforms.
      affinity:
          TextAffinity.downstream, // ignore: avoid_redundant_argument_values
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getWordBoundary(position).end,
      // Word boundary seems to always report downstream on many platforms.
      affinity:
          TextAffinity.downstream, // ignore: avoid_redundant_argument_values
    );
  }
}

// The linebreaks of the current text layout. The input [TextPosition]s are
// interpreted as caret locations because [TextPainter.getLineAtOffset] is
// text-affinity-aware.
class _LineBreak extends _TextBoundary {
  const _LineBreak(this.textLayout, this.textEditingValue);

  final TextLayoutMetrics textLayout;

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getLineAtOffset(position).start,
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textLayout.getLineAtOffset(position).end,
      affinity: TextAffinity.upstream,
    );
  }
}

// The document boundary is unique and is a constant function of the input
// position.
class _DocumentBoundary extends _TextBoundary {
  const _DocumentBoundary(this.textEditingValue);

  @override
  final TextEditingValue textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      const TextPosition(offset: 0);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return TextPosition(
      offset: textEditingValue.text.length,
      affinity: TextAffinity.upstream,
    );
  }
}

// ------------------------  Text Boundary Combinators ------------------------

// Expands the innerTextBoundary with outerTextBoundary.
class _ExpandedTextBoundary extends _TextBoundary {
  _ExpandedTextBoundary(this.innerTextBoundary, this.outerTextBoundary);

  final _TextBoundary innerTextBoundary;
  final _TextBoundary outerTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(innerTextBoundary.textEditingValue ==
        outerTextBoundary.textEditingValue);
    return innerTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getLeadingTextBoundaryAt(
      innerTextBoundary.getLeadingTextBoundaryAt(position),
    );
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return outerTextBoundary.getTrailingTextBoundaryAt(
      innerTextBoundary.getTrailingTextBoundaryAt(position),
    );
  }
}

// Force the innerTextBoundary to interpret the input [TextPosition]s as caret
// locations instead of code unit positions.
//
// The innerTextBoundary must be a [_TextBoundary] that interprets the input
// [TextPosition]s as code unit positions.
class _CollapsedSelectionBoundary extends _TextBoundary {
  _CollapsedSelectionBoundary(this.innerTextBoundary, this.isForward);

  final _TextBoundary innerTextBoundary;
  final bool isForward;

  @override
  TextEditingValue get textEditingValue => innerTextBoundary.textEditingValue;

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) {
    return isForward
        ? innerTextBoundary.getLeadingTextBoundaryAt(position)
        : position.offset <= 0
            ? const TextPosition(offset: 0)
            : innerTextBoundary.getLeadingTextBoundaryAt(
                TextPosition(offset: position.offset - 1));
  }

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) {
    return isForward
        ? innerTextBoundary.getTrailingTextBoundaryAt(position)
        : position.offset <= 0
            ? const TextPosition(offset: 0)
            : innerTextBoundary.getTrailingTextBoundaryAt(
                TextPosition(offset: position.offset - 1));
  }
}

// A _TextBoundary that creates a [TextRange] where its start is from the
// specified leading text boundary and its end is from the specified trailing
// text boundary.
class _MixedBoundary extends _TextBoundary {
  _MixedBoundary(this.leadingTextBoundary, this.trailingTextBoundary);

  final _TextBoundary leadingTextBoundary;
  final _TextBoundary trailingTextBoundary;

  @override
  TextEditingValue get textEditingValue {
    assert(leadingTextBoundary.textEditingValue ==
        trailingTextBoundary.textEditingValue);
    return leadingTextBoundary.textEditingValue;
  }

  @override
  TextPosition getLeadingTextBoundaryAt(TextPosition position) =>
      leadingTextBoundary.getLeadingTextBoundaryAt(position);

  @override
  TextPosition getTrailingTextBoundaryAt(TextPosition position) =>
      trailingTextBoundary.getTrailingTextBoundaryAt(position);
}

// -------------------------------  Text Actions -------------------------------
class _DeleteTextAction<T extends DirectionalTextEditingIntent>
    extends ContextAction<T> {
  _DeleteTextAction(this.state, this.getTextBoundariesForIntent);

  final RawEditorState state;
  final _TextBoundary Function(T intent) getTextBoundariesForIntent;

  TextRange _expandNonCollapsedRange(TextEditingValue value) {
    final TextRange selection = value.selection;
    assert(selection.isValid);
    assert(!selection.isCollapsed);
    final _TextBoundary atomicBoundary = _CharacterBoundary(value);

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
      !state.widget.readOnly && state.textEditingValue.selection.isValid;
}

class _UpdateTextSelectionAction<T extends DirectionalCaretMovementIntent>
    extends ContextAction<T> {
  _UpdateTextSelectionAction(this.state, this.ignoreNonCollapsedSelection,
      this.getTextBoundariesForIntent);

  final RawEditorState state;
  final bool ignoreNonCollapsedSelection;
  final _TextBoundary Function(T intent) getTextBoundariesForIntent;

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final selection = state.textEditingValue.selection;
    assert(selection.isValid);

    final collapseSelection =
        intent.collapseSelection || !state.widget.selectionEnabled;
    // Collapse to the logical start/end.
    TextSelection _collapse(TextSelection selection) {
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
        UpdateSelectionIntent(state.textEditingValue, _collapse(selection),
            SelectionChangedCause.keyboard),
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
            _collapse(textBoundarySelection), SelectionChangedCause.keyboard),
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

class _ExtendSelectionOrCaretPositionAction extends ContextAction<
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent> {
  _ExtendSelectionOrCaretPositionAction(
      this.state, this.getTextBoundariesForIntent);

  final RawEditorState state;
  final _TextBoundary Function(
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
      state.widget.selectionEnabled && state.textEditingValue.selection.isValid;
}

class _UpdateTextSelectionToAdjacentLineAction<
    T extends DirectionalCaretMovementIntent> extends ContextAction<T> {
  _UpdateTextSelectionToAdjacentLineAction(this.state);

  final RawEditorState state;

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

    final collapseSelection =
        intent.collapseSelection || !state.widget.selectionEnabled;
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

class _SelectAllAction extends ContextAction<SelectAllTextIntent> {
  _SelectAllAction(this.state);

  final RawEditorState state;

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
  bool get isActionEnabled => state.widget.selectionEnabled;
}

class _CopySelectionAction extends ContextAction<CopySelectionTextIntent> {
  _CopySelectionAction(this.state);

  final RawEditorState state;

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

class _HideSelectionToolbarAction
    extends ContextAction<HideSelectionToolbarIntent> {
  _HideSelectionToolbarAction(this.state);

  final RawEditorState state;

  @override
  void invoke(HideSelectionToolbarIntent intent, [BuildContext? context]) {
    state.hideToolbar();
  }

  @override
  bool get isActionEnabled => state.textEditingValue.selection.isValid;
}

class _UndoKeyboardAction extends ContextAction<UndoTextIntent> {
  _UndoKeyboardAction(this.state);

  final RawEditorState state;

  @override
  void invoke(UndoTextIntent intent, [BuildContext? context]) {
    if (state.controller.hasUndo) {
      state.controller.undo();
    }
  }

  @override
  bool get isActionEnabled => true;
}

class _RedoKeyboardAction extends ContextAction<RedoTextIntent> {
  _RedoKeyboardAction(this.state);

  final RawEditorState state;

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
class _ToggleTextStyleAction extends Action<ToggleTextStyleIntent> {
  _ToggleTextStyleAction(this.state);

  final RawEditorState state;

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
class _IndentSelectionAction extends Action<IndentSelectionIntent> {
  _IndentSelectionAction(this.state);

  final RawEditorState state;

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
class _OpenSearchAction extends ContextAction<OpenSearchIntent> {
  _OpenSearchAction(this.state);

  final RawEditorState state;

  @override
  Future invoke(OpenSearchIntent intent, [BuildContext? context]) async {
    await showDialog<String>(
      context: context!,
      builder: (_) => SearchDialog(controller: state.controller, text: ''),
    );
  }

  @override
  bool get isActionEnabled => true;
}

class ApplyHeaderIntent extends Intent {
  const ApplyHeaderIntent(this.header);

  final Attribute header;
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class _ApplyHeaderAction extends Action<ApplyHeaderIntent> {
  _ApplyHeaderAction(this.state);

  final RawEditorState state;

  Attribute<dynamic> _getHeaderValue() {
    return state.controller
            .getSelectionStyle()
            .attributes[Attribute.header.key] ??
        Attribute.header;
  }

  @override
  void invoke(ApplyHeaderIntent intent, [BuildContext? context]) {
    final _attribute =
        _getHeaderValue() == intent.header ? Attribute.header : intent.header;
    state.controller.formatSelection(_attribute);
  }

  @override
  bool get isActionEnabled => true;
}

class ApplyCheckListIntent extends Intent {
  const ApplyCheckListIntent();
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class _ApplyCheckListAction extends Action<ApplyCheckListIntent> {
  _ApplyCheckListAction(this.state);

  final RawEditorState state;

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
  void invoke(ApplyCheckListIntent intent, [BuildContext? context]) {
    state.controller.formatSelection(_getIsToggled()
        ? Attribute.clone(Attribute.unchecked, null)
        : Attribute.unchecked);
  }

  @override
  bool get isActionEnabled => true;
}

class ApplyLinkIntent extends Intent {
  const ApplyLinkIntent();
}

class ApplyLinkAction extends Action<ApplyLinkIntent> {
  ApplyLinkAction(this.state);

  final RawEditorState state;

  @override
  Object? invoke(ApplyLinkIntent intent) async {
    final initialTextLink = QuillTextLink.prepare(state.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: state.context,
      builder: (context) {
        return LinkStyleDialog(
          text: initialTextLink.text,
          link: initialTextLink.link,
          dialogTheme: state.widget.dialogTheme,
        );
      },
    );

    if (textLink != null) {
      textLink.submit(state.controller);
    }
    return null;
  }
}

class InsertEmbedIntent extends Intent {
  const InsertEmbedIntent(this.type);

  final Attribute type;
}

/// Signature for a widget builder that builds a context menu for the given
/// [RawEditorState].
///
/// See also:
///
///  * [EditableTextContextMenuBuilder], which performs the same role for
///    [EditableText]
typedef QuillEditorContextMenuBuilder = Widget Function(
  BuildContext context,
  RawEditorState rawEditorState,
);

class _GlyphHeights {
  _GlyphHeights(
    this.startGlyphHeight,
    this.endGlyphHeight,
  );

  final double startGlyphHeight;
  final double endGlyphHeight;
}
