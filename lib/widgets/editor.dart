import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/container.dart'
    as containerNode;
import 'package:flutter_quill/models/documents/nodes/leaf.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/proxy.dart';
import 'package:flutter_quill/widgets/text_selection.dart';

import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'delegate.dart';
import 'keyboard_listener.dart';

abstract class EditorState extends State<RawEditor> {
  TextEditingValue getTextEditingValue();

  void setTextEditingValue(TextEditingValue value);

  RenderEditor getRenderEditor();

  EditorTextSelectionOverlay getSelectionOverlay();

  bool showToolbar();

  void hideToolbar();

  void requestKeyboard();
}

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

  _requestKeyboard() {
    _editorKey.currentState.requestKeyboard();
  }
}

class _QuillEditorSelectionGestureDetectorBuilder
    extends EditorTextSelectionGestureDetectorBuilder {
  final _QuillEditorState _state;

  _QuillEditorSelectionGestureDetectorBuilder(this._state) : super(_state);

  @override
  onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.getSelectionEnabled() && shouldShowSelectionToolbar) {
      getEditor().showToolbar();
    }
  }

  @override
  onForcePressEnd(ForcePressDetails details) {}

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!delegate.getSelectionEnabled()) {
      return;
    }
    switch (Theme.of(_state.context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        getRenderEditor().selectPositionAt(
          details.globalPosition,
          null,
          SelectionChangedCause.longPress,
        );
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        getRenderEditor().selectWordsInRange(
          details.globalPosition - details.offsetFromOrigin,
          details.globalPosition,
          SelectionChangedCause.longPress,
        );
        break;
      default:
        throw ('Invalid platform');
    }
  }

  _launchUrlIfNeeded(TapUpDetails details) {
    TextPosition pos =
        getRenderEditor().getPositionForOffset(details.globalPosition);
    containerNode.ChildQuery result =
        getEditor().widget.controller.document.queryChild(pos.offset);
    if (result.node == null) {
      return;
    }
    Line line = result.node as Line;
    containerNode.ChildQuery segmentResult =
        line.queryChild(result.offset, false);
    if (segmentResult.node == null) {
      return;
    }
    Leaf segment = segmentResult.node as Leaf;
    if (segment.style.containsKey(Attribute.link.key) &&
        getEditor().widget.onLaunchUrl != null) {
      if (getEditor().widget.readOnly) {
        getEditor()
            .widget
            .onLaunchUrl(segment.style.attributes[Attribute.link.key].value);
      }
    }
  }

  @override
  onSingleTapUp(TapUpDetails details) {
    getEditor().hideToolbar();

    _launchUrlIfNeeded(details);

    if (delegate.getSelectionEnabled()) {
      switch (Theme.of(_state.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              getRenderEditor().selectPosition(SelectionChangedCause.tap);
              break;
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              getRenderEditor().selectWordEdge(SelectionChangedCause.tap);
              break;
          }
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          getRenderEditor().selectPosition(SelectionChangedCause.tap);
          break;
      }
    }
    _state._requestKeyboard();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.getSelectionEnabled()) {
      switch (Theme.of(_state.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          getRenderEditor().selectPositionAt(
            details.globalPosition,
            null,
            SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          getRenderEditor().selectWord(SelectionChangedCause.longPress);
          Feedback.forLongPress(_state.context);
          break;
        default:
          throw ('Invalid platform');
      }
    }
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
  bool _didAutoFocus = false;
  DefaultStyles _styles;
  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  bool get _hasFocus => widget.focusNode.hasFocus;

  TextDirection get _textDirection {
    TextDirection result = Directionality.of(context);
    assert(result != null);
    return result;
  }

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
  void bringIntoView(TextPosition position) {}

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
    assert(debugCheckHasMediaQuery(context));
    _focusAttachment.reparent();
    super.build(context);

    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: Semantics(
        child: _Editor(
          key: _editorKey,
          children: _buildChildren(context),
          document: widget.controller.document,
          selection: widget.controller.selection,
          hasFocus: _hasFocus,
          textDirection: _textDirection,
          startHandleLayerLink: _startHandleLayerLink,
          endHandleLayerLink: _endHandleLayerLink,
          onSelectionChanged: _handleSelectionChanged,
          padding: widget.padding,
        ),
      ),
    );

    if (widget.scrollable) {
      EdgeInsets baselinePadding =
          EdgeInsets.only(top: _styles.paragraph.verticalSpacing.item1);
      child = BaselineProxy(
        textStyle: _styles.paragraph.style,
        padding: baselinePadding,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: widget.scrollPhysics,
          child: child,
        ),
      );
    }

    BoxConstraints constraints = widget.expands
        ? BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.minHeight ?? 0.0,
            maxHeight: widget.maxHeight ?? double.infinity);

    return QuillStyles(
      data: _styles,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Container(
          constraints: constraints,
          child: child,
        ),
      ),
    );
  }

  _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    widget.controller.updateSelection(selection, ChangeSource.LOCAL);

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();

    requestKeyboard();
  }

  _buildChildren(BuildContext context) {}

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

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    DefaultStyles parentStyles = QuillStyles.getStyles(context, true);
    DefaultStyles defaultStyles = DefaultStyles.getInstance(context);
    _styles = (parentStyles != null)
        ? defaultStyles.merge(parentStyles)
        : defaultStyles;

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

    if (widget.scrollController != null &&
        widget.scrollController != _scrollController) {
      _scrollController.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.scrollController;
      _scrollController.addListener(_updateSelectionOverlayForScroll);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      _focusAttachment?.detach();
      _focusAttachment = widget.focusNode.attach(context,
          onKey: (node, event) => _keyboardListener.handleRawKeyEvent(event));
      widget.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
    }

    if (widget.controller.selection != oldWidget.controller.selection) {
      _selectionOverlay?.update(textEditingValue);
    }

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();
    if (widget.readOnly) {
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

  handleDelete(bool forward) {
    TextSelection selection = widget.controller.selection;
    String plainText = textEditingValue.text;
    assert(selection != null);
    int cursorPosition = selection.start;
    String textBefore = selection.textBefore(plainText);
    String textAfter = selection.textAfter(plainText);
    if (selection.isCollapsed) {
      if (!forward && textBefore.isNotEmpty) {
        final int characterBoundary =
            _previousCharacter(textBefore.length, textBefore, true);
        textBefore = textBefore.substring(0, characterBoundary);
        cursorPosition = characterBoundary;
      }
      if (forward && textAfter.isNotEmpty && textAfter != '\n') {
        final int deleteCount = _nextCharacter(0, textAfter, true);
        textAfter = textAfter.substring(deleteCount);
      }
    }
    TextSelection newSelection =
        TextSelection.collapsed(offset: cursorPosition);
    String newText = textBefore + textAfter;
    int size = plainText.length - newText.length;
    widget.controller.replaceText(
      cursorPosition,
      size,
      '',
      newSelection,
    );
  }

  Future<void> handleShortcut(InputShortcut shortcut) async {
    TextSelection selection = widget.controller.selection;
    assert(selection != null);
    String plainText = textEditingValue.text;
    if (shortcut == InputShortcut.COPY) {
      if (!selection.isCollapsed) {
        Clipboard.setData(ClipboardData(text: selection.textInside(plainText)));
      }
      return;
    }
    if (shortcut == InputShortcut.CUT && !widget.readOnly) {
      if (!selection.isCollapsed) {
        final data = selection.textInside(plainText);
        Clipboard.setData(ClipboardData(text: data));

        widget.controller.replaceText(
          selection.start,
          data.length,
          '',
          TextSelection.collapsed(offset: selection.start),
        );

        textEditingValue = TextEditingValue(
          text:
              selection.textBefore(plainText) + selection.textAfter(plainText),
          selection: TextSelection.collapsed(offset: selection.start),
        );
      }
      return;
    }
    if (shortcut == InputShortcut.PASTE && !widget.readOnly) {
      ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        widget.controller.replaceText(
          selection.start,
          selection.end - selection.start,
          data.text,
          TextSelection.collapsed(offset: selection.start + data.text.length),
        );
      }
      return;
    }
    if (shortcut == InputShortcut.SELECT_ALL &&
        widget.enableInteractiveSelection) {
      widget.controller.updateSelection(
          selection.copyWith(
            baseOffset: 0,
            extentOffset: textEditingValue.text.length,
          ),
          ChangeSource.REMOTE);
      return;
    }
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
    requestKeyboard();

    _showCaretOnScreen();
    updateRemoteValueIfNeeded();
    _cursorCont.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.controller.selection);
    if (hasConnection) {
      _cursorCont.stopCursorTimer(resetCharTicks: false);
      _cursorCont.startCursorTimer();
    }

    SchedulerBinding.instance.addPostFrameCallback(
        (Duration _) => _updateOrDisposeSelectionOverlayIfNeeded());
  }

  _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      if (_hasFocus) {
        _selectionOverlay.update(textEditingValue);
      } else {
        _selectionOverlay.dispose();
        _selectionOverlay = null;
      }
    } else if (_hasFocus) {
      _selectionOverlay?.hide();
      _selectionOverlay = null;

      if (widget.selectionCtrls != null) {
        _selectionOverlay = EditorTextSelectionOverlay(
            textEditingValue,
            false,
            context,
            widget,
            _toolbarLayerLink,
            _startHandleLayerLink,
            _endHandleLayerLink,
            getRenderEditor(),
            widget.selectionCtrls,
            this,
            DragStartBehavior.start,
            null,
            _clipboardStatus);
        _selectionOverlay.handlesVisible = _shouldShowSelectionHandles();
        _selectionOverlay.showHandles();
      }
    }
  }

  _handleFocusChanged() {
    openOrCloseConnection();
    _cursorCont.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.controller.selection);
    _updateOrDisposeSelectionOverlayIfNeeded();
    if (_hasFocus) {
      WidgetsBinding.instance.addObserver(this);
      _showCaretOnScreen();
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
    updateKeepAlive();
  }

  _onChangedClipboardStatus() {}

  bool _showCaretOnScreenScheduled = false;

  _showCaretOnScreen() {
    if (!widget.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _showCaretOnScreenScheduled = false;

      final viewport = RenderAbstractViewport.of(getRenderEditor());
      assert(viewport != null);
      final editorOffset =
          getRenderEditor().localToGlobal(Offset(0.0, 0.0), ancestor: viewport);
      final offsetInViewport = _scrollController.offset + editorOffset.dy;

      final offset = getRenderEditor().getOffsetToRevealCursor(
        _scrollController.position.viewportDimension,
        _scrollController.offset,
        offsetInViewport,
      );

      if (offset != null) {
        _scrollController.animateTo(
          offset,
          duration: Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
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
    widget.controller.updateSelection(value.selection, ChangeSource.LOCAL);
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

  openOrCloseConnection() {
    if (widget.focusNode.hasFocus && widget.focusNode.consumeKeyboardToken()) {
      openConnectionIfNeeded();
    } else if (!widget.focusNode.hasFocus) {
      closeConnectionIfNeeded();
    }
  }
}

typedef TextSelectionChangedHandler = void Function(
    TextSelection selection, SelectionChangedCause cause);

class RenderEditor extends RenderEditableContainerBox
    implements RenderAbstractEditor {
  Document document;
  TextSelection selection;
  bool _hasFocus = false;
  LayerLink _startHandleLayerLink;
  LayerLink _endHandleLayerLink;
  TextSelectionChangedHandler onSelectionChanged;
  final ValueNotifier<bool> _selectionStartInViewport =
      ValueNotifier<bool>(true);

  ValueListenable<bool> get selectionStartInViewport =>
      _selectionStartInViewport;

  ValueListenable<bool> get selectionEndInViewport => _selectionEndInViewport;
  final ValueNotifier<bool> _selectionEndInViewport = ValueNotifier<bool>(true);

  RenderEditor(
      List<RenderEditableBox> children,
      TextDirection textDirection,
      EdgeInsetsGeometry padding,
      this.document,
      this.selection,
      this._hasFocus,
      this.onSelectionChanged,
      this._startHandleLayerLink,
      this._endHandleLayerLink,
      EdgeInsets floatingCursorAddedMargin)
      : assert(document != null),
        assert(textDirection != null),
        assert(_hasFocus != null),
        assert(floatingCursorAddedMargin != null),
        super(
          children,
          document.root,
          textDirection,
          padding,
        );

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

  setStartHandleLayerLink(LayerLink value) {
    if (_startHandleLayerLink == value) {
      return;
    }
    _startHandleLayerLink = value;
    markNeedsPaint();
  }

  setEndHandleLayerLink(LayerLink value) {
    if (_endHandleLayerLink == value) {
      return;
    }
    _endHandleLayerLink = value;
    markNeedsPaint();
  }

  @override
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection) {
    assert(constraints != null);

    if (selection.isCollapsed) {
      RenderEditableBox child = childAtPosition(selection.extent);
      TextPosition localPosition = TextPosition(
          offset: selection.extentOffset - child.getContainer().getOffset());
      Offset localOffset = child.getOffsetForCaret(localPosition);
      BoxParentData parentData = child.parentData;
      return <TextSelectionPoint>[
        TextSelectionPoint(
            Offset(0.0, child.preferredLineHeight(localPosition)) +
                localOffset +
                parentData.offset,
            null)
      ];
    }

    Node baseNode = _container.queryChild(selection.start, false).node;

    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.getContainer() == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    BoxParentData baseParentData = baseChild.parentData;
    TextSelection baseSelection =
        localSelection(baseChild.getContainer(), selection, true);
    TextSelectionPoint basePoint =
        baseChild.getBaseEndpointForSelection(baseSelection);
    basePoint = TextSelectionPoint(
        basePoint.point + baseParentData.offset, basePoint.direction);

    Node extentNode = _container.queryChild(selection.end, false).node;
    var extentChild = baseChild;
    while (extentChild != null) {
      if (extentChild.getContainer() == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    BoxParentData extentParentData = extentChild.parentData;
    TextSelection extentSelection =
        localSelection(extentChild.getContainer(), selection, true);
    TextSelectionPoint extentPoint =
        extentChild.getExtentEndpointForSelection(extentSelection);
    extentPoint = TextSelectionPoint(
        extentPoint.point + extentParentData.offset, extentPoint.direction);

    return <TextSelectionPoint>[basePoint, extentPoint];
  }

  Offset _lastTapDownPosition;

  @override
  handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  @override
  selectWordsInRange(
    Offset from,
    Offset to,
    SelectionChangedCause cause,
  ) {
    assert(cause != null);
    assert(from != null);
    if (onSelectionChanged == null) {
      return;
    }
    TextPosition firstPosition = getPositionForOffset(from);
    TextSelection firstWord = selectWordAtPosition(firstPosition);
    TextSelection lastWord =
        to == null ? firstWord : selectWordAtPosition(getPositionForOffset(to));

    _handleSelectionChange(
      TextSelection(
        baseOffset: firstWord.base.offset,
        extentOffset: lastWord.extent.offset,
        affinity: firstWord.affinity,
      ),
      cause,
    );
  }

  _handleSelectionChange(
    TextSelection nextSelection,
    SelectionChangedCause cause,
  ) {
    bool focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !_hasFocus;
    if (nextSelection == selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    if (onSelectionChanged != null) {
      onSelectionChanged(nextSelection, cause);
    }
  }

  @override
  selectWordEdge(SelectionChangedCause cause) {
    assert(cause != null);
    assert(_lastTapDownPosition != null);
    if (onSelectionChanged == null) {
      return;
    }
    TextPosition position = getPositionForOffset(_lastTapDownPosition);
    RenderEditableBox child = childAtPosition(position);
    int nodeOffset = child.getContainer().getOffset();
    TextPosition localPosition = TextPosition(
      offset: position.offset - nodeOffset,
      affinity: position.affinity,
    );
    TextRange localWord = child.getWordBoundary(localPosition);
    TextRange word = TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
    if (position.offset - word.start <= 1) {
      _handleSelectionChange(
        TextSelection.collapsed(
            offset: word.start, affinity: TextAffinity.downstream),
        cause,
      );
    } else {
      _handleSelectionChange(
        TextSelection.collapsed(
            offset: word.end, affinity: TextAffinity.upstream),
        cause,
      );
    }
  }

  @override
  selectPositionAt(
    Offset from,
    Offset to,
    SelectionChangedCause cause,
  ) {
    assert(cause != null);
    assert(from != null);
    if (onSelectionChanged == null) {
      return;
    }
    TextPosition fromPosition = getPositionForOffset(from);
    TextPosition toPosition = to == null ? null : getPositionForOffset(to);

    int baseOffset = fromPosition.offset;
    int extentOffset = fromPosition.offset;
    if (toPosition != null) {
      baseOffset = math.min(fromPosition.offset, toPosition.offset);
      extentOffset = math.max(fromPosition.offset, toPosition.offset);
    }

    TextSelection newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );
    _handleSelectionChange(newSelection, cause);
  }

  @override
  selectWord(SelectionChangedCause cause) {
    selectWordsInRange(_lastTapDownPosition, null, cause);
  }

  @override
  selectPosition(SelectionChangedCause cause) {
    selectPositionAt(_lastTapDownPosition, null, cause);
  }

  @override
  TextSelection selectWordAtPosition(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    int nodeOffset = child.getContainer().getOffset();
    TextPosition localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    TextRange localWord = child.getWordBoundary(localPosition);
    TextRange word = TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
    if (position.offset >= word.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  @override
  TextSelection selectLineAtPosition(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    int nodeOffset = child.getContainer().getOffset();
    TextPosition localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    TextRange localLineRange = child.getLineBoundary(localPosition);
    TextRange line = TextRange(
      start: localLineRange.start + nodeOffset,
      end: localLineRange.end + nodeOffset,
    );

    if (position.offset >= line.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    _paintHandleLayers(context, getEndpointsForSelection(selection));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  _paintHandleLayers(
      PaintingContext context, List<TextSelectionPoint> endpoints) {
    var startPoint = endpoints[0].point;
    startPoint = Offset(
      startPoint.dx.clamp(0.0, size.width),
      startPoint.dy.clamp(0.0, size.height),
    );
    context.pushLayer(
      LeaderLayer(link: _startHandleLayerLink, offset: startPoint),
      super.paint,
      Offset.zero,
    );
    if (endpoints.length == 2) {
      var endPoint = endpoints[1].point;
      endPoint = Offset(
        endPoint.dx.clamp(0.0, size.width),
        endPoint.dy.clamp(0.0, size.height),
      );
      context.pushLayer(
        LeaderLayer(link: _endHandleLayerLink, offset: endPoint),
        super.paint,
        Offset.zero,
      );
    }
  }

  @override
  double preferredLineHeight(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    return child.preferredLineHeight(TextPosition(
        offset: position.offset - child.getContainer().getOffset()));
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    Offset local = globalToLocal(offset);
    RenderEditableBox child = childAtOffset(local);

    BoxParentData parentData = child.parentData;
    Offset localOffset = local - parentData.offset;
    TextPosition localPosition = child.getPositionForOffset(localOffset);
    return TextPosition(
      offset: localPosition.offset + child.getContainer().getOffset(),
      affinity: localPosition.affinity,
    );
  }

  double getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport) {
    List<TextSelectionPoint> endpoints = getEndpointsForSelection(selection);
    if (endpoints.length != 1) {
      return null;
    }
    RenderEditableBox child = childAtPosition(selection.extent);
    const kMargin = 8.0;

    double caretTop = endpoints.single.point.dy -
        child.preferredLineHeight(TextPosition(
            offset:
                selection.extentOffset - child.getContainer().getOffset())) -
        kMargin +
        offsetInViewport;
    final caretBottom = endpoints.single.point.dy + kMargin + offsetInViewport;
    double dy;
    if (caretTop < scrollOffset) {
      dy = caretTop;
    } else if (caretBottom > scrollOffset + viewportHeight) {
      dy = caretBottom - viewportHeight;
    }
    if (dy == null) {
      return null;
    }
    return math.max(dy, 0.0);
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
  containerNode.Container _container;
  TextDirection textDirection;
  EdgeInsetsGeometry _padding;
  EdgeInsets _resolvedPadding;

  RenderEditableContainerBox(List<RenderEditableBox> children, this._container,
      this.textDirection, this._padding)
      : assert(_container != null),
        assert(textDirection != null),
        assert(_padding != null),
        assert(_padding.isNonNegative) {
    addAll(children);
  }

  containerNode.Container getContainer() {
    return _container;
  }

  setContainer(containerNode.Container c) {
    assert(c != null);
    if (_container == c) {
      return;
    }
    _container = c;
    markNeedsLayout();
  }

  EdgeInsetsGeometry getPadding() => _padding;

  setPadding(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    _markNeedsPaddingResolution();
  }

  EdgeInsets get resolvedPadding => _resolvedPadding;

  _resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = _padding.resolve(textDirection);
    _resolvedPadding = _resolvedPadding.copyWith(left: _resolvedPadding.left);

    assert(_resolvedPadding.isNonNegative);
  }

  RenderEditableBox childAtPosition(TextPosition position) {
    assert(firstChild != null);

    Node targetNode = _container.queryChild(position.offset, false).node;

    var targetChild = firstChild;
    while (targetChild != null) {
      if (targetChild.getContainer() == targetNode) {
        break;
      }
      targetChild = childAfter(targetChild);
    }
    assert(targetChild != null);
    return targetChild;
  }

  _markNeedsPaddingResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  RenderEditableBox childAtOffset(Offset offset) {
    assert(firstChild != null);
    _resolvePadding();

    if (offset.dy <= _resolvedPadding.top) {
      return firstChild;
    }
    if (offset.dy >= size.height - _resolvedPadding.bottom) {
      return lastChild;
    }

    var child = firstChild;
    double dx = -offset.dx, dy = _resolvedPadding.top;
    while (child != null) {
      if (child.size.contains(offset.translate(dx, -dy))) {
        return child;
      }
      dy += child.size.height;
      child = childAfter(child);
    }
    throw ('No child');
  }

  @override
  setupParentData(RenderBox child) {
    if (child.parentData is EditableContainerParentData) {
      return;
    }

    child.parentData = EditableContainerParentData();
  }

  @override
  void performLayout() {
    assert(!constraints.hasBoundedHeight);
    assert(constraints.hasBoundedWidth);
    _resolvePadding();
    assert(_resolvedPadding != null);

    double mainAxisExtent = _resolvedPadding.top;
    var child = firstChild;
    BoxConstraints innerConstraints =
        BoxConstraints.tightFor(width: constraints.maxWidth)
            .deflate(_resolvedPadding);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final EditableContainerParentData childParentData = child.parentData;
      childParentData.offset = Offset(_resolvedPadding.left, mainAxisExtent);
      mainAxisExtent += child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += _resolvedPadding.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));

    assert(size.isFinite);
  }

  double _getIntrinsicCrossAxis(double Function(RenderBox child) childSize) {
    double extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      EditableContainerParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  double _getIntrinsicMainAxis(double Function(RenderBox child) childSize) {
    double extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent += childSize(child);
      EditableContainerParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolvePadding();
    return _getIntrinsicCrossAxis((RenderBox child) {
      double childHeight = math.max(
          0.0, height - _resolvedPadding.top + _resolvedPadding.bottom);
      return child.getMinIntrinsicWidth(childHeight) +
          _resolvedPadding.left +
          _resolvedPadding.right;
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    return _getIntrinsicCrossAxis((RenderBox child) {
      double childHeight = math.max(
          0.0, height - _resolvedPadding.top + _resolvedPadding.bottom);
      return child.getMaxIntrinsicWidth(childHeight) +
          _resolvedPadding.left +
          _resolvedPadding.right;
    });
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    return _getIntrinsicMainAxis((RenderBox child) {
      double childWidth =
          math.max(0.0, width - _resolvedPadding.left + _resolvedPadding.right);
      return child.getMinIntrinsicHeight(childWidth) +
          _resolvedPadding.top +
          _resolvedPadding.bottom;
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolvePadding();
    return _getIntrinsicMainAxis((RenderBox child) {
      final childWidth =
          math.max(0.0, width - _resolvedPadding.left + _resolvedPadding.right);
      return child.getMaxIntrinsicHeight(childWidth) +
          _resolvedPadding.top +
          _resolvedPadding.bottom;
    });
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return defaultComputeDistanceToFirstActualBaseline(baseline) +
        _resolvedPadding.top;
  }
}

class _Editor extends MultiChildRenderObjectWidget {
  _Editor({
    @required Key key,
    @required List<Widget> children,
    @required this.document,
    @required this.textDirection,
    @required this.hasFocus,
    @required this.selection,
    @required this.startHandleLayerLink,
    @required this.endHandleLayerLink,
    @required this.onSelectionChanged,
    this.padding = EdgeInsets.zero,
  }) : super(key: key, children: children);

  final Document document;
  final TextDirection textDirection;
  final bool hasFocus;
  final TextSelection selection;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final TextSelectionChangedHandler onSelectionChanged;
  final EdgeInsetsGeometry padding;

  @override
  RenderEditor createRenderObject(BuildContext context) {
    return RenderEditor(
        null,
        textDirection,
        padding,
        document,
        selection,
        hasFocus,
        onSelectionChanged,
        startHandleLayerLink,
        endHandleLayerLink,
        EdgeInsets.fromLTRB(4, 4, 4, 5));
  }

  @override
  updateRenderObject(
      BuildContext context, covariant RenderEditor renderObject) {
    renderObject.document = document;
    renderObject.setContainer(document.root);
    renderObject.textDirection = textDirection;
    renderObject.setHasFocus(hasFocus);
    renderObject.setSelection(selection);
    renderObject.setStartHandleLayerLink(startHandleLayerLink);
    renderObject.setEndHandleLayerLink(endHandleLayerLink);
    renderObject.onSelectionChanged = onSelectionChanged;
    renderObject.setPadding(padding);
  }
}
