import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tuple/tuple.dart';

import '../../models/documents/nodes/node.dart';
import '../models/documents/attribute.dart';
import '../models/documents/document.dart';
import '../models/documents/nodes/block.dart';
import '../models/documents/nodes/line.dart';
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

class RawEditor extends StatefulWidget {
  const RawEditor(
      {required this.controller,
      required this.focusNode,
      required this.scrollController,
      required this.scrollBottomInset,
      required this.cursorStyle,
      required this.selectionColor,
      required this.selectionCtrls,
      Key? key,
      this.scrollable = true,
      this.padding = EdgeInsets.zero,
      this.readOnly = false,
      this.placeholder,
      this.onLaunchUrl,
      this.toolbarOptions = const ToolbarOptions(
        copy: true,
        cut: true,
        paste: true,
        selectAll: true,
      ),
      this.showSelectionHandles = false,
      bool? showCursor,
      this.textCapitalization = TextCapitalization.none,
      this.maxHeight,
      this.minHeight,
      this.maxContentWidth,
      this.customStyles,
      this.expands = false,
      this.autoFocus = false,
      this.keyboardAppearance = Brightness.light,
      this.enableInteractiveSelection = true,
      this.scrollPhysics,
      this.embedBuilder = defaultEmbedBuilder,
      this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
      this.customStyleBuilder,
      this.floatingCursorDisabled = false})
      : assert(maxHeight == null || maxHeight > 0, 'maxHeight cannot be null'),
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

  /// Configuration of toolbar options.
  ///
  /// By default, all options are enabled. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions toolbarOptions;

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

  /// The [ScrollPhysics] to use when vertically scrolling the input.
  ///
  /// If not specified, it will behave according to the current platform.
  ///
  /// See [Scrollable.physics].
  final ScrollPhysics? scrollPhysics;

  /// Builder function for embeddable objects.
  final EmbedBuilder embedBuilder;
  final LinkActionPickerDelegate linkActionPickerDelegate;
  final CustomStyleBuilder? customStyleBuilder;
  final bool floatingCursorDisabled;

  @override
  State<StatefulWidget> createState() => RawEditorState();
}

class RawEditorState extends EditorState
    with
        AutomaticKeepAliveClientMixin<RawEditor>,
        WidgetsBindingObserver,
        TickerProviderStateMixin<RawEditor>,
        TextEditingActionTarget,
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

  // Focus
  bool _didAutoFocus = false;
  FocusAttachment? _focusAttachment;
  bool get _hasFocus => widget.focusNode.hasFocus;

  // Theme
  DefaultStyles? _styles;

  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  TextDirection get _textDirection => Directionality.of(context);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    _focusAttachment!.reparent();
    super.build(context);

    var _doc = widget.controller.document;
    if (_doc.isEmpty() && widget.placeholder != null) {
      _doc = Document.fromJson(jsonDecode(
          '[{"attributes":{"placeholder":true},"insert":"${widget.placeholder}\\n"}]'));
    }

    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: Semantics(
        child: _Editor(
          key: _editorKey,
          document: _doc,
          selection: widget.controller.selection,
          hasFocus: _hasFocus,
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
    );

    if (widget.scrollable) {
      /// Since [SingleChildScrollView] does not implement
      /// `computeDistanceToActualBaseline` it prevents the editor from
      /// providing its baseline metrics. To address this issue we wrap
      /// the scroll view with [BaselineProxy] which mimics the editor's
      /// baseline.
      // This implies that the first line has no styles applied to it.
      final baselinePadding =
          EdgeInsets.only(top: _styles!.paragraph!.verticalSpacing.item1);
      child = BaselineProxy(
        textStyle: _styles!.paragraph!.style,
        padding: baselinePadding,
        child: QuillSingleChildScrollView(
          controller: _scrollController,
          physics: widget.scrollPhysics,
          viewportBuilder: (_, offset) => CompositedTransformTarget(
            link: _toolbarLayerLink,
            child: _Editor(
              key: _editorKey,
              offset: offset,
              document: widget.controller.document,
              selection: widget.controller.selection,
              hasFocus: _hasFocus,
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
      );
    }

    final constraints = widget.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.minHeight ?? 0.0,
            maxHeight: widget.maxHeight ?? double.infinity);

    return QuillStyles(
      data: _styles!,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: QuillKeyboardListener(
          child: Container(
            constraints: constraints,
            child: child,
          ),
        ),
      ),
    );
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    final oldSelection = widget.controller.selection;
    widget.controller.updateSelection(selection, ChangeSource.LOCAL);

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
    widget.controller.onSelectionCompleted?.call();
  }

  /// Updates the checkbox positioned at [offset] in document
  /// by changing its attribute according to [value].
  void _handleCheckboxTap(int offset, bool value) {
    if (!widget.readOnly) {
      widget.controller.formatText(
          offset, 0, value ? Attribute.checked : Attribute.unchecked);
    }
  }

  List<Widget> _buildChildren(Document doc, BuildContext context) {
    final result = <Widget>[];
    final indentLevelCounts = <int, int>{};
    for (final node in doc.root.children) {
      if (node is Line) {
        final editableTextLine = _getEditableTextLineFromNode(node, context);
        result.add(editableTextLine);
      } else if (node is Block) {
        final attrs = node.style.attributes;
        final editableTextBlock = EditableTextBlock(
            block: node,
            controller: widget.controller,
            textDirection: _textDirection,
            scrollBottomInset: widget.scrollBottomInset,
            verticalSpacing: _getVerticalSpacingForBlock(node, _styles),
            textSelection: widget.controller.selection,
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
            onCheckboxTap: _handleCheckboxTap,
            readOnly: widget.readOnly,
            customStyleBuilder: widget.customStyleBuilder);
        result.add(editableTextBlock);
      } else {
        throw StateError('Unreachable.');
      }
    }
    return result;
  }

  EditableTextLine _getEditableTextLineFromNode(
      Line node, BuildContext context) {
    final textLine = TextLine(
      line: node,
      textDirection: _textDirection,
      embedBuilder: widget.embedBuilder,
      customStyleBuilder: widget.customStyleBuilder,
      styles: _styles!,
      readOnly: widget.readOnly,
      controller: widget.controller,
      linkActionPicker: _linkActionPicker,
      onLaunchUrl: widget.onLaunchUrl,
    );
    final editableTextLine = EditableTextLine(
        node,
        null,
        textLine,
        0,
        _getVerticalSpacingForLine(node, _styles),
        _textDirection,
        widget.controller.selection,
        widget.selectionColor,
        widget.enableInteractiveSelection,
        _hasFocus,
        MediaQuery.of(context).devicePixelRatio,
        _cursorCont);
    return editableTextLine;
  }

  Tuple2<double, double> _getVerticalSpacingForLine(
      Line line, DefaultStyles? defaultStyles) {
    final attrs = line.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      final int? level = attrs[Attribute.header.key]!.value;
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

  Tuple2<double, double> _getVerticalSpacingForBlock(
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
    return const Tuple2(0, 0);
  }

  @override
  void initState() {
    super.initState();

    _clipboardStatus.addListener(_onChangedClipboardStatus);

    widget.controller.addListener(() {
      _didChangeTextEditingValue(widget.controller.ignoreFocusOnTextChange);
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

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia) {
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
    }

    _focusAttachment = widget.focusNode.attach(context);
    widget.focusNode.addListener(_handleFocusChanged);
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

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_didChangeTextEditingValue);
      widget.controller.addListener(_didChangeTextEditingValue);
      updateRemoteValueIfNeeded();
    }

    if (widget.scrollController != _scrollController) {
      _scrollController.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.scrollController;
      _scrollController.addListener(_updateSelectionOverlayForScroll);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      _focusAttachment?.detach();
      _focusAttachment = widget.focusNode.attach(context);
      widget.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
    }

    if (widget.controller.selection != oldWidget.controller.selection) {
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
  }

  bool _shouldShowSelectionHandles() {
    return widget.showSelectionHandles &&
        !widget.controller.selection.isCollapsed;
  }

  @override
  void dispose() {
    closeConnectionIfNeeded();
    _keyboardVisibilitySubscription?.cancel();
    assert(!hasConnection);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    widget.controller.removeListener(_didChangeTextEditingValue);
    widget.focusNode.removeListener(_handleFocusChanged);
    _focusAttachment!.detach();
    _cursorCont.dispose();
    _clipboardStatus
      ..removeListener(_onChangedClipboardStatus)
      ..dispose();
    super.dispose();
  }

  void _updateSelectionOverlayForScroll() {
    _selectionOverlay?.updateForScroll();
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
        setState(() {
          // Use widget.controller.value in build()
          // Trigger build and updateChildren
        });
      }
    }
  }

  void _onChangeTextEditingValue([bool ignoreCaret = false]) {
    updateRemoteValueIfNeeded();
    if (ignoreCaret) {
      return;
    }
    _showCaretOnScreen();
    _cursorCont.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.controller.selection);
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
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateOrDisposeSelectionOverlayIfNeeded();
    });
    if (mounted) {
      setState(() {
        // Use widget.controller.value in build()
        // Trigger build and updateChildren
      });
    }
  }

  void _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      if (_hasFocus && !textEditingValue.selection.isCollapsed) {
        _selectionOverlay!.update(textEditingValue);
      } else {
        _selectionOverlay!.dispose();
        _selectionOverlay = null;
      }
    } else if (_hasFocus) {
      _selectionOverlay?.hide();

      _selectionOverlay = EditorTextSelectionOverlay(
        value: textEditingValue,
        context: context,
        debugRequiredFor: widget,
        toolbarLayerLink: _toolbarLayerLink,
        startHandleLayerLink: _startHandleLayerLink,
        endHandleLayerLink: _endHandleLayerLink,
        renderObject: renderEditor,
        selectionCtrls: widget.selectionCtrls,
        selectionDelegate: this,
        clipboardStatus: _clipboardStatus,
      );
      _selectionOverlay!.handlesVisible = _shouldShowSelectionHandles();
      _selectionOverlay!.showHandles();
    }
  }

  void _handleFocusChanged() {
    openOrCloseConnection();
    _cursorCont.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.controller.selection);
    _updateOrDisposeSelectionOverlayIfNeeded();
    if (_hasFocus) {
      WidgetsBinding.instance!.addObserver(this);
      _showCaretOnScreen();
    } else {
      WidgetsBinding.instance!.removeObserver(this);
    }
    updateKeepAlive();
  }

  void _onChangedClipboardStatus() {
    if (!mounted) return;
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
      // Trigger build and updateChildren
    });
  }

  Future<LinkMenuAction> _linkActionPicker(Node linkNode) async {
    final link = linkNode.style.attributes[Attribute.link.key]!.value!;
    return widget.linkActionPickerDelegate(context, link);
  }

  bool _showCaretOnScreenScheduled = false;

  void _showCaretOnScreen() {
    if (!widget.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
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
      _editorKey.currentContext?.findRenderObject() as RenderEditor;

  @override
  void requestKeyboard() {
    if (_hasFocus) {
      openConnectionIfNeeded();
      _showCaretOnScreen();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  @override
  void setTextEditingValue(
      TextEditingValue value, SelectionChangedCause cause) {
    if (value == textEditingValue) {
      return;
    }
    textEditingValue = value;
    userUpdateTextEditingValue(value, cause);

    // keyboard and text input force a selection completion
    _handleSelectionCompleted();
  }

  @override
  void debugAssertLayoutUpToDate() {
    renderEditor.debugAssertLayoutUpToDate();
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
    if (_selectionOverlay == null || _selectionOverlay!.toolbar != null) {
      return false;
    }

    _selectionOverlay!.update(textEditingValue);
    _selectionOverlay!.showToolbar();
    return true;
  }

  @override
  void copySelection(SelectionChangedCause cause) {
    // Copied straight from EditableTextState
    super.copySelection(cause);
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
    // Copied straight from EditableTextState
    super.cutSelection(cause);
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  Future<void> pasteText(SelectionChangedCause cause) async {
    // Copied straight from EditableTextState
    super.pasteText(cause); // ignore: unawaited_futures
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
    }
  }

  @override
  void selectAll(SelectionChangedCause cause) {
    // Copied straight from EditableTextState
    super.selectAll(cause);
    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
    }
  }

  @override
  bool get wantKeepAlive => widget.focusNode.hasFocus;

  @override
  bool get obscureText => false;

  @override
  bool get selectionEnabled => widget.enableInteractiveSelection;

  @override
  bool get readOnly => widget.readOnly;

  @override
  TextLayoutMetrics get textLayoutMetrics => renderEditor;

  @override
  AnimationController get floatingCursorResetController =>
      _floatingCursorResetController;

  late AnimationController _floatingCursorResetController;
}

class _Editor extends MultiChildRenderObjectWidget {
  _Editor({
    required Key key,
    required List<Widget> children,
    required this.document,
    required this.textDirection,
    required this.hasFocus,
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
