import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/text_selection.dart';

import 'controller.dart';
import 'cursor.dart';
import 'delegate.dart';

abstract class RenderAbstractEditor {
  TextSelection selectWordAtPosition(TextPosition position);

  TextSelection selectLineAtPosition(TextPosition position);

  double preferredLineHeight(TextPosition position);

  TextPosition getPositionForOffset(Offset offset);

  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection);

  void handleTapDown(TapDownDetails details);

  void selectWordsInRange(
    Offset from,
    Offset to,
    SelectionChangedCause cause,
  );

  void selectWordEdge(SelectionChangedCause cause);

  void selectPositionAt(Offset from, Offset to, SelectionChangedCause cause);

  void selectWord(SelectionChangedCause cause);

  void selectPosition(SelectionChangedCause cause);
}

class QuillEditor extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool autoFocus;
  final bool showCursor;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final double minHeight;
  final double maxHeight;
  final bool expands;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final ScrollPhysics scrollPhysics;
  final ValueChanged<String> onLaunchUrl;

  QuillEditor(
      this.controller,
      this.focusNode,
      this.scrollController,
      this.scrollable,
      this.padding,
      this.autoFocus,
      this.showCursor,
      this.readOnly,
      this.enableInteractiveSelection,
      this.minHeight,
      this.maxHeight,
      this.expands,
      this.textCapitalization,
      this.keyboardAppearance,
      this.scrollPhysics,
      this.onLaunchUrl)
      : assert(controller != null),
        assert(scrollController != null),
        assert(scrollable != null),
        assert(autoFocus != null),
        assert(readOnly != null);

  @override
  _QuillEditorState createState() => _QuillEditorState();
}

class _QuillEditorState extends State<QuillEditor>
    implements EditorTextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  EditorTextSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _QuillEditorSelectionGestureDetectorBuilder(this);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextSelectionThemeData selectionTheme = TextSelectionTheme.of(context);

    TextSelectionControls textSelectionControls;
    bool paintCursorAboveText;
    bool cursorOpacityAnimates;
    Offset cursorOffset;
    Color cursorColor;
    Color selectionColor;
    Radius cursorRadius;

    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        textSelectionControls = materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withOpacity(0.40);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls = cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??=
            selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;
      default:
        throw UnimplementedError();
    }

    return _selectionGestureDetectorBuilder.build(
      HitTestBehavior.translucent,
      RawEditor(
          _editorKey,
          widget.controller,
          widget.focusNode,
          widget.scrollController,
          widget.scrollable,
          widget.padding,
          widget.readOnly,
          widget.onLaunchUrl,
          ToolbarOptions(
            copy: true,
            cut: true,
            paste: true,
            selectAll: true,
          ),
          theme.platform == TargetPlatform.iOS ||
              theme.platform == TargetPlatform.android,
          widget.showCursor,
          CursorStyle(
            color: cursorColor,
            backgroundColor: Colors.grey,
            width: 2.0,
            radius: cursorRadius,
            offset: cursorOffset,
            paintAboveText: paintCursorAboveText,
            opacityAnimates: cursorOpacityAnimates,
          ),
          widget.textCapitalization,
          widget.maxHeight,
          widget.minHeight,
          widget.expands,
          widget.autoFocus,
          selectionColor,
          textSelectionControls,
          widget.keyboardAppearance,
          widget.enableInteractiveSelection,
          widget.scrollPhysics),
    );
  }

  @override
  GlobalKey<EditorState> getEditableTextKey() {
    return _editorKey;
  }

  @override
  bool getForcePressEnabled() {
    return false;
  }

  @override
  bool getSelectionEnabled() {
    return widget.enableInteractiveSelection;
  }
}

class _QuillEditorSelectionGestureDetectorBuilder
    extends EditorTextSelectionGestureDetectorBuilder {
  final _QuillEditorState _state;

  _QuillEditorSelectionGestureDetectorBuilder(this._state) : super(_state);

  @override
  onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
  }
}

class RawEditor extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool readOnly;
  final ValueChanged<String> onLaunchUrl;
  final ToolbarOptions toolbarOptions;
  final bool showSelectionHandles;
  final bool showCursor;
  final CursorStyle cursorStyle;
  final TextCapitalization textCapitalization;
  final double maxHeight;
  final double minHeight;
  final bool expands;
  final bool autoFocus;
  final Color selectionColor;
  final TextSelectionControls selectionCtrls;
  final Brightness keyboardAppearance;
  final bool enableInteractiveSelection;
  final ScrollPhysics scrollPhysics;

  RawEditor(
      Key key,
      this.controller,
      this.focusNode,
      this.scrollController,
      this.scrollable,
      this.padding,
      this.readOnly,
      this.onLaunchUrl,
      this.toolbarOptions,
      this.showSelectionHandles,
      bool showCursor,
      this.cursorStyle,
      this.textCapitalization,
      this.maxHeight,
      this.minHeight,
      this.expands,
      this.autoFocus,
      this.selectionColor,
      this.selectionCtrls,
      this.keyboardAppearance,
      this.enableInteractiveSelection,
      this.scrollPhysics)
      : assert(controller != null),
        assert(focusNode != null),
        assert(scrollable || scrollController != null),
        assert(selectionColor != null),
        assert(enableInteractiveSelection != null),
        assert(showSelectionHandles != null),
        assert(readOnly != null),
        assert(maxHeight == null || maxHeight > 0),
        assert(minHeight == null || minHeight >= 0),
        assert(
            maxHeight == null || minHeight == null || maxHeight >= minHeight),
        assert(autoFocus != null),
        assert(toolbarOptions != null),
        showCursor = showCursor ?? !readOnly,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RawEditorState();
  }
}

class RawEditorState extends EditorState implements TextSelectionDelegate {
  final GlobalKey _editorKey = GlobalKey();

  @override
  TextEditingValue textEditingValue;

  @override
  void bringIntoView(TextPosition position) {
    // TODO: implement bringIntoView
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  // TODO: implement copyEnabled
  bool get copyEnabled => throw UnimplementedError();

  @override
  // TODO: implement cutEnabled
  bool get cutEnabled => throw UnimplementedError();

  @override
  RenderEditor getRenderEditor() {
    // TODO: implement getRenderEditor
    throw UnimplementedError();
  }

  @override
  EditorTextSelectionOverlay getSelectionOverlay() {
    // TODO: implement getSelectionOverlay
    throw UnimplementedError();
  }

  @override
  TextEditingValue getTextEditingValue() {
    // TODO: implement getTextEditingValue
    throw UnimplementedError();
  }

  @override
  void hideToolbar() {
    // TODO: implement hideToolbar
  }

  @override
  // TODO: implement pasteEnabled
  bool get pasteEnabled => throw UnimplementedError();

  @override
  void requestKeyboard() {
    // TODO: implement requestKeyboard
  }

  @override
  // TODO: implement selectAllEnabled
  bool get selectAllEnabled => throw UnimplementedError();

  @override
  void setTextEditingValue(TextEditingValue value) {
    // TODO: implement setTextEditingValue
  }

  @override
  bool showToolbar() {
    // TODO: implement showToolbar
    throw UnimplementedError();
  }
}

class RenderEditor extends RenderEditableContainerBox
    implements RenderAbstractEditor {
  Document document;
  TextSelection selection;
  bool _hasFocus = false;

  setDocument(Document doc) {
    assert(doc != null);
    if (document == doc) {
      return;
    }
    document = doc;
    markNeedsLayout();
  }

  setHasFocus(bool h) {
    assert(h != null);
    if (_hasFocus == h) {
      return;
    }
    _hasFocus = h;
    markNeedsSemanticsUpdate();
  }

  setSelection(TextSelection t) {
    if (selection == t) {
      return;
    }
    selection = t;
    markNeedsPaint();
  }

  @override
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection) {
    // TODO: implement getEndpointsForSelection
    throw UnimplementedError();
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    // TODO: implement getPositionForOffset
    throw UnimplementedError();
  }

  @override
  void handleTapDown(TapDownDetails details) {
    // TODO: implement handleTapDown
  }

  @override
  double preferredLineHeight(TextPosition position) {
    // TODO: implement preferredLineHeight
    throw UnimplementedError();
  }

  @override
  TextSelection selectLineAtPosition(TextPosition position) {
    // TODO: implement selectLineAtPosition
    throw UnimplementedError();
  }

  @override
  void selectPosition(SelectionChangedCause cause) {
    // TODO: implement selectPosition
  }

  @override
  void selectPositionAt(Offset from, Offset to, SelectionChangedCause cause) {
    // TODO: implement selectPositionAt
  }

  @override
  void selectWord(SelectionChangedCause cause) {
    // TODO: implement selectWord
  }

  @override
  TextSelection selectWordAtPosition(TextPosition position) {
    // TODO: implement selectWordAtPosition
    throw UnimplementedError();
  }

  @override
  void selectWordEdge(SelectionChangedCause cause) {
    // TODO: implement selectWordEdge
  }

  @override
  void selectWordsInRange(Offset from, Offset to, SelectionChangedCause cause) {
    assert(cause != null && from != null);
    // TODO: implement selectWordsInRange
  }
}

class RenderEditableContainerBox extends RenderBox {
  Container _container;
  TextDirection _textDirection;

  setContainer(Container c) {
    assert(c != null);
    if (_container == c) {
      return;
    }
    _container = c;
    markNeedsLayout();
  }

  setTextDirection(TextDirection t) {
    if (_textDirection == t) {
      return;
    }
    _textDirection = t;
  }
}

abstract class EditorState extends State<RawEditor> {
  TextEditingValue getTextEditingValue();

  void setTextEditingValue(TextEditingValue value);

  RenderEditor getRenderEditor();

  EditorTextSelectionOverlay getSelectionOverlay();

  bool showToolbar();

  void hideToolbar();

  void requestKeyboard();
}
