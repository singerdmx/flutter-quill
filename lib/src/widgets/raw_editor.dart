import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tuple/tuple.dart';

import '../models/documents/attribute.dart';
import '../models/documents/document.dart';
import '../models/documents/nodes/block.dart';
import '../models/documents/nodes/embeddable.dart';
import '../models/documents/nodes/line.dart';
import '../models/documents/nodes/node.dart';
import '../models/documents/style.dart';
import '../utils/delta.dart';
import '../utils/platform.dart';
import 'controller.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';
import 'editor.dart';
import 'embeds/default_embed_builder.dart';
import 'embeds/image.dart';
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

  bool get selectionEnabled => enableInteractiveSelection;

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
  List<Tuple2<int, Style>> get pasteStyle => _pasteStyle;
  List<Tuple2<int, Style>> _pasteStyle = <Tuple2<int, Style>>[];
  @override
  String get pastePlainText => _pastePlainText;
  String _pastePlainText = '';

  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  TextDirection get _textDirection => Directionality.of(context);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
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
              document: _doc,
              selection: widget.controller.selection,
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
      );
    }

    final constraints = widget.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.minHeight ?? 0.0,
            maxHeight: widget.maxHeight ?? double.infinity);

    return QuillStyles(
      data: _styles!,
      child: Actions(
        actions: _actions,
        child: Focus(
          focusNode: widget.focusNode,
          child: QuillKeyboardListener(
            child: Container(
              constraints: constraints,
              child: child,
            ),
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
      _disableScrollControllerAnimateOnce = true;
      final attribute = value ? Attribute.checked : Attribute.unchecked;

      widget.controller.formatText(offset, 0, attribute);

      // Checkbox tapping causes controller.selection to go to offset 0
      // Stop toggling those two toolbar buttons
      widget.controller.toolbarButtonToggler = {
        Attribute.list.key: attribute,
        Attribute.header.key: Attribute.header
      };

      // Go back from offset 0 to current selection
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        widget.controller.updateSelection(
            TextSelection.collapsed(offset: offset), ChangeSource.LOCAL);
      });
    }
  }

  List<Widget> _buildChildren(Document doc, BuildContext context) {
    final result = <Widget>[];
    final indentLevelCounts = <int, int>{};
    for (final node in doc.root.children) {
      if (node is Line) {
        final editableTextLine = _getEditableTextLineFromNode(node, context);
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextLine));
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
        result.add(Directionality(
            textDirection: getDirectionOfNode(node), child: editableTextBlock));
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

    if (isKeyboardOS()) {
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
        }
      });
    }

    // Focus
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

    // in case customStyles changed in new widget
    if (widget.customStyles != null) {
      _styles = _styles!.merge(widget.customStyles!);
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
      if (!_hasFocus) {
        _selectionOverlay!.dispose();
        _selectionOverlay = null;
      } else if (!textEditingValue.selection.isCollapsed) {
        _selectionOverlay!.update(textEditingValue);
      }
    } else if (_hasFocus) {
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
    if (_hasFocus) {
      openConnectionIfNeeded();
      _showCaretOnScreen();
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
    widget.controller.copiedImageUrl = null;
    _pastePlainText = widget.controller.getPlainText();
    _pasteStyle = widget.controller.getAllIndividualSelectionStyles();

    final selection = textEditingValue.selection;
    final text = textEditingValue.text;
    if (selection.isCollapsed) {
      return;
    }
    Clipboard.setData(ClipboardData(text: selection.textInside(text)));

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar(false);

      if (!Platform.isIOS) {
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
  }

  /// Cut current selection to [Clipboard].
  @override
  void cutSelection(SelectionChangedCause cause) {
    widget.controller.copiedImageUrl = null;
    _pastePlainText = widget.controller.getPlainText();
    _pasteStyle = widget.controller.getAllIndividualSelectionStyles();

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

    if (widget.controller.copiedImageUrl != null) {
      final index = textEditingValue.selection.baseOffset;
      final length = textEditingValue.selection.extentOffset - index;
      final copied = widget.controller.copiedImageUrl!;
      widget.controller
          .replaceText(index, length, BlockEmbed.image(copied.item1), null);
      if (copied.item2.isNotEmpty) {
        widget.controller.formatText(
            getImageNode(widget.controller, index + 1).item1,
            1,
            StyleAttribute(copied.item2));
      }
      widget.controller.copiedImageUrl = null;
      await Clipboard.setData(const ClipboardData(text: ''));
      return;
    }

    final selection = textEditingValue.selection;
    if (!selection.isValid) {
      return;
    }
    // Snapshot the input before using `await`.
    // See https://github.com/flutter/flutter/issues/11427
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) {
      return;
    }

    _replaceText(
        ReplaceTextIntent(textEditingValue, data.text!, selection, cause));

    if (cause == SelectionChangedCause.toolbar) {
      bringIntoView(textEditingValue.selection.extent);
      hideToolbar();
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
  };
}

class _Editor extends MultiChildRenderObjectWidget {
  _Editor({
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
    final currentSelection = state.widget.controller.selection;
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
