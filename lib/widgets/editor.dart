import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:flutter_quill/widgets/text_selection.dart';

import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'delegate.dart';
import 'keyboard_listener.dart';

const Set<int> WHITE_SPACE = {
  0x9,
  0xA,
  0xB,
  0xC,
  0xD,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
  0x20,
  0xA0,
  0x1680,
  0x2000,
  0x2001,
  0x2002,
  0x2003,
  0x2004,
  0x2005,
  0x2006,
  0x2007,
  0x2008,
  0x2009,
  0x200A,
  0x202F,
  0x205F,
  0x3000
};

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
  final EmbedBuilder embedBuilder;

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
      this.onLaunchUrl,
      this.embedBuilder)
      : assert(controller != null),
        assert(scrollController != null),
        assert(scrollable != null),
        assert(autoFocus != null),
        assert(readOnly != null),
        assert(embedBuilder != null);

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
          widget.scrollPhysics,
          widget.embedBuilder),
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
  final EmbedBuilder embedBuilder;

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
      this.scrollPhysics,
      this.embedBuilder)
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
        assert(embedBuilder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RawEditorState();
  }
}

class RawEditorState extends EditorState
    with
        AutomaticKeepAliveClientMixin<RawEditor>,
        WidgetsBindingObserver,
        TickerProviderStateMixin<RawEditor>
    implements TextSelectionDelegate, TextInputClient {
  final GlobalKey _editorKey = GlobalKey();
  final List<TextEditingValue> _sentRemoteValues = [];
  TextInputConnection _textInputConnection;
  TextEditingValue _lastKnownRemoteTextEditingValue;
  int _cursorResetLocation = -1;
  bool _wasSelectingVerticallyWithKeyboard = false;
  EditorTextSelectionOverlay _selectionOverlay;
  FocusAttachment _focusAttachment;
  CursorCont _cursorCont;
  ScrollController _scrollController;
  KeyboardListener _keyboardListener;
  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();

  bool get _hasFocus => widget.focusNode.hasFocus;

  handleCursorMovement(
    LogicalKeyboardKey key,
    bool wordModifier,
    bool lineModifier,
    bool shift,
  ) {
    if (wordModifier && lineModifier) {
      return;
    }
    TextSelection selection = widget.controller.selection;
    assert(selection != null);

    TextSelection newSelection = widget.controller.selection;

    String plainText = textEditingValue.text;

    bool rightKey = key == LogicalKeyboardKey.arrowRight,
        leftKey = key == LogicalKeyboardKey.arrowLeft,
        upKey = key == LogicalKeyboardKey.arrowUp,
        downKey = key == LogicalKeyboardKey.arrowDown;

    if ((rightKey || leftKey) && !(rightKey && leftKey)) {
      newSelection = _jumpToBeginOrEndOfWord(newSelection, wordModifier,
          leftKey, rightKey, plainText, lineModifier, shift);
    }

    if (downKey || upKey) {
      newSelection = _handleMovingCursorVertically(
          upKey, downKey, shift, selection, newSelection, plainText);
    }

    if (!shift) {
      newSelection =
          _placeCollapsedSelection(selection, newSelection, leftKey, rightKey);
    }

    widget.controller.updateSelection(newSelection, ChangeSource.LOCAL);
  }

  TextSelection _placeCollapsedSelection(TextSelection selection,
      TextSelection newSelection, bool leftKey, bool rightKey) {
    int newOffset = newSelection.extentOffset;
    if (!selection.isCollapsed) {
      if (leftKey) {
        newOffset = newSelection.baseOffset < newSelection.extentOffset
            ? newSelection.baseOffset
            : newSelection.extentOffset;
      } else if (rightKey) {
        newOffset = newSelection.baseOffset > newSelection.extentOffset
            ? newSelection.baseOffset
            : newSelection.extentOffset;
      }
    }
    return TextSelection.fromPosition(TextPosition(offset: newOffset));
  }

  TextSelection _handleMovingCursorVertically(
      bool upKey,
      bool downKey,
      bool shift,
      TextSelection selection,
      TextSelection newSelection,
      String plainText) {
    TextPosition originPosition = TextPosition(
        offset: upKey ? selection.baseOffset : selection.extentOffset);

    RenderEditableBox child = getRenderEditor().childAtPosition(originPosition);
    TextPosition localPosition = TextPosition(
        offset:
            originPosition.offset - child.getContainer().getDocumentOffset());

    TextPosition position = upKey
        ? child.getPositionAbove(localPosition)
        : child.getPositionBelow(localPosition);

    if (position == null) {
      var sibling = upKey
          ? getRenderEditor().childBefore(child)
          : getRenderEditor().childAfter(child);
      if (sibling == null) {
        position = TextPosition(offset: upKey ? 0 : plainText.length - 1);
      } else {
        Offset finalOffset = Offset(
            child.getOffsetForCaret(localPosition).dx,
            sibling
                .getOffsetForCaret(TextPosition(
                    offset: upKey ? sibling.getContainer().length - 1 : 0))
                .dy);
        TextPosition siblingPosition =
            sibling.getPositionForOffset(finalOffset);
        position = TextPosition(
            offset: sibling.getContainer().getDocumentOffset() +
                siblingPosition.offset);
      }
    } else {
      position = TextPosition(
          offset: child.getContainer().getDocumentOffset() + position.offset);
    }

    if (position.offset == newSelection.extentOffset) {
      if (downKey) {
        newSelection = newSelection.copyWith(extentOffset: plainText.length);
      } else if (upKey) {
        newSelection = newSelection.copyWith(extentOffset: 0);
      }
      _wasSelectingVerticallyWithKeyboard = shift;
      return newSelection;
    }

    if (_wasSelectingVerticallyWithKeyboard && shift) {
      newSelection = newSelection.copyWith(extentOffset: _cursorResetLocation);
      _wasSelectingVerticallyWithKeyboard = false;
      return newSelection;
    }
    newSelection = newSelection.copyWith(extentOffset: position.offset);
    _cursorResetLocation = newSelection.extentOffset;
    return newSelection;
  }

  TextSelection _jumpToBeginOrEndOfWord(
      TextSelection newSelection,
      bool wordModifier,
      bool leftKey,
      bool rightKey,
      String plainText,
      bool lineModifier,
      bool shift) {
    if (wordModifier) {
      if (leftKey) {
        TextSelection textSelection = getRenderEditor().selectWordAtPosition(
            TextPosition(
                offset: _previousCharacter(
                    newSelection.extentOffset, plainText, false)));
        return newSelection.copyWith(extentOffset: textSelection.baseOffset);
      }
      TextSelection textSelection = getRenderEditor().selectWordAtPosition(
          TextPosition(
              offset:
                  _nextCharacter(newSelection.extentOffset, plainText, false)));
      return newSelection.copyWith(extentOffset: textSelection.extentOffset);
    } else if (lineModifier) {
      if (leftKey) {
        TextSelection textSelection = getRenderEditor().selectLineAtPosition(
            TextPosition(
                offset: _previousCharacter(
                    newSelection.extentOffset, plainText, false)));
        return newSelection.copyWith(extentOffset: textSelection.baseOffset);
      }
      int startPoint = newSelection.extentOffset;
      if (startPoint < plainText.length) {
        TextSelection textSelection = getRenderEditor()
            .selectLineAtPosition(TextPosition(offset: startPoint));
        return newSelection.copyWith(extentOffset: textSelection.extentOffset);
      }
      return newSelection;
    }

    if (rightKey && newSelection.extentOffset < plainText.length) {
      int nextExtent =
          _nextCharacter(newSelection.extentOffset, plainText, true);
      int distance = nextExtent - newSelection.extentOffset;
      newSelection = newSelection.copyWith(extentOffset: nextExtent);
      if (shift) {
        _cursorResetLocation += distance;
      }
      return newSelection;
    }

    if (leftKey && newSelection.extentOffset > 0) {
      int previousExtent =
          _previousCharacter(newSelection.extentOffset, plainText, true);
      int distance = newSelection.extentOffset - previousExtent;
      newSelection = newSelection.copyWith(extentOffset: previousExtent);
      if (shift) {
        _cursorResetLocation -= distance;
      }
      return newSelection;
    }
    return newSelection;
  }

  int _nextCharacter(int index, String string, bool includeWhitespace) {
    assert(index >= 0 && index <= string.length);
    if (index == string.length) {
      return string.length;
    }

    int count = 0;
    Characters remain = string.characters.skipWhile((String currentString) {
      if (count <= index) {
        count += currentString.length;
        return true;
      }
      if (includeWhitespace) {
        return false;
      }
      return WHITE_SPACE.contains(currentString.codeUnitAt(0));
    });
    return string.length - remain.toString().length;
  }

  int _previousCharacter(int index, String string, includeWhitespace) {
    assert(index >= 0 && index <= string.length);
    if (index == 0) {
      return 0;
    }

    int count = 0;
    int lastNonWhitespace;
    for (String currentString in string.characters) {
      if (!includeWhitespace &&
          !WHITE_SPACE.contains(
              currentString.characters.first.toString().codeUnitAt(0))) {
        lastNonWhitespace = count;
      }
      if (count + currentString.length >= index) {
        return includeWhitespace ? count : lastNonWhitespace ?? 0;
      }
      count += currentString.length;
    }
    return 0;
  }

  bool get hasConnection =>
      _textInputConnection != null && _textInputConnection.attached;

  openConnectionIfNeeded() {
    if (widget.readOnly) {
      return;
    }

    if (!hasConnection) {
      _lastKnownRemoteTextEditingValue = textEditingValue;
      _textInputConnection = TextInput.attach(
        this,
        TextInputConfiguration(
          inputType: TextInputType.multiline,
          readOnly: widget.readOnly,
          obscureText: false,
          autocorrect: false,
          inputAction: TextInputAction.newline,
          keyboardAppearance: widget.keyboardAppearance,
          textCapitalization: widget.textCapitalization,
        ),
      );

      _textInputConnection.setEditingState(_lastKnownRemoteTextEditingValue);
      _sentRemoteValues.add(_lastKnownRemoteTextEditingValue);
    }
    _textInputConnection.show();
  }

  closeConnectionIfNeeded() {
    if (!hasConnection) {
      return;
    }
    _textInputConnection.close();
    _textInputConnection = null;
    _lastKnownRemoteTextEditingValue = null;
    _sentRemoteValues.clear();
  }

  updateRemoteValueIfNeeded() {
    if (!hasConnection) {
      return;
    }

    TextEditingValue actualValue = textEditingValue.copyWith(
      composing: _lastKnownRemoteTextEditingValue.composing,
    );

    if (actualValue == _lastKnownRemoteTextEditingValue) {
      return;
    }

    bool shouldRemember =
        textEditingValue.text != _lastKnownRemoteTextEditingValue.text;
    _lastKnownRemoteTextEditingValue = actualValue;
    _textInputConnection.setEditingState(actualValue);
    if (shouldRemember) {
      _sentRemoteValues.add(actualValue);
    }
  }

  @override
  TextEditingValue get currentTextEditingValue =>
      _lastKnownRemoteTextEditingValue;

  @override
  AutofillScope get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    if (widget.readOnly) {
      return;
    }

    if (_sentRemoteValues.contains(value)) {
      _sentRemoteValues.remove(value);
      return;
    }

    if (_lastKnownRemoteTextEditingValue == value) {
      return;
    }

    if (_lastKnownRemoteTextEditingValue.text == value.text &&
        _lastKnownRemoteTextEditingValue.selection == value.selection) {
      _lastKnownRemoteTextEditingValue = value;
      return;
    }

    TextEditingValue effectiveLastKnownValue = _lastKnownRemoteTextEditingValue;
    _lastKnownRemoteTextEditingValue = value;
    String oldText = effectiveLastKnownValue.text;
    String text = value.text;
    int cursorPosition = value.selection.extentOffset;
    Diff diff = getDiff(oldText, text, cursorPosition);
    widget.controller.replaceText(
        diff.start, diff.deleted.length, diff.inserted, value.selection);
  }

  @override
  TextEditingValue get textEditingValue {
    return widget.controller.plainTextEditingValue;
  }

  @override
  set textEditingValue(TextEditingValue value) {
    widget.controller.updateSelection(value.selection, ChangeSource.LOCAL);
  }

  @override
  void performAction(TextInputAction action) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    throw UnimplementedError();
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    throw UnimplementedError();
  }

  @override
  void bringIntoView(TextPosition position) {
    // TODO: implement bringIntoView
  }

  @override
  void connectionClosed() {
    if (!hasConnection) {
      return;
    }
    _textInputConnection.connectionClosedReceived();
    _textInputConnection = null;
    _lastKnownRemoteTextEditingValue = null;
    _sentRemoteValues.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void initState() {
    super.initState();

    _clipboardStatus?.addListener(_onChangedClipboardStatus);

    widget.controller.addListener(_didChangeTextEditingValue);

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_updateSelectionOverlayForScroll);

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(widget.showCursor ?? false),
      style: widget.cursorStyle ??
          CursorStyle(
            color: Colors.blueAccent,
            backgroundColor: Colors.grey,
            width: 2.0,
          ),
      tickerProvider: this,
    );

    _keyboardListener = KeyboardListener(
      handleCursorMovement,
      handleShortcut,
      handleDelete,
    );

    _focusAttachment = widget.focusNode.attach(context,
        onKey: (node, event) => _keyboardListener.handleRawKeyEvent(event));
    widget.focusNode.addListener(_handleFocusChanged);
  }

  handleDelete(bool forward) {
    // TODO
  }

  Future<void> handleShortcut(InputShortcut shortcut) async {
    // TODO
  }

  @override
  void dispose() {
    closeConnectionIfNeeded();
    assert(!hasConnection);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    widget.controller.removeListener(_didChangeTextEditingValue);
    widget.focusNode.removeListener(_handleFocusChanged);
    _focusAttachment.detach();
    _cursorCont.dispose();
    _clipboardStatus?.removeListener(_onChangedClipboardStatus);
    _clipboardStatus?.dispose();
    super.dispose();
  }

  _updateSelectionOverlayForScroll() {
    _selectionOverlay?.markNeedsBuild();
  }

  _didChangeTextEditingValue() {
    // TODO
  }

  _handleFocusChanged() {
    // TODO
  }

  _onChangedClipboardStatus() {
    // TODO
  }

  _showCaretOnScreen() {

  }

  @override
  RenderEditor getRenderEditor() {
    return _editorKey.currentContext.findRenderObject();
  }

  @override
  EditorTextSelectionOverlay getSelectionOverlay() {
    return _selectionOverlay;
  }

  @override
  TextEditingValue getTextEditingValue() {
    return widget.controller.plainTextEditingValue;
  }

  @override
  void hideToolbar() {
    if (getSelectionOverlay()?.toolbar != null) {
      getSelectionOverlay()?.hideToolbar();
    }
  }

  @override
  bool get cutEnabled => widget.toolbarOptions.cut && !widget.readOnly;

  @override
  bool get copyEnabled => widget.toolbarOptions.copy;

  @override
  bool get pasteEnabled => widget.toolbarOptions.paste && !widget.readOnly;

  @override
  bool get selectAllEnabled => widget.toolbarOptions.selectAll;

  @override
  requestKeyboard() {
    if (_hasFocus) {
      openConnectionIfNeeded();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  @override
  setTextEditingValue(TextEditingValue value) {
    widget.controller
        .updateSelection(value.selection, ChangeSource.LOCAL);
  }

  @override
  bool showToolbar() {
    if (_selectionOverlay == null || _selectionOverlay.toolbar != null) {
      return false;
    }

    _selectionOverlay.showToolbar();
    return true;
  }

  @override
  bool get wantKeepAlive => widget.focusNode.hasFocus;
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

class EditableContainerParentData
    extends ContainerBoxParentData<RenderEditableBox> {}

class RenderEditableContainerBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderEditableBox,
            EditableContainerParentData>,
        RenderBoxContainerDefaultsMixin<RenderEditableBox,
            EditableContainerParentData> {
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

  RenderEditableBox childAtPosition(TextPosition originPosition) {
    // TODO
    return null;
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
