import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/proxy.dart';
import 'package:flutter_quill/widgets/text_block.dart';
import 'package:flutter_quill/widgets/text_line.dart';
import 'package:flutter_quill/widgets/text_selection.dart';
import 'package:tuple/tuple.dart';

import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'delegate.dart';
import 'editor.dart';
import 'keyboard_listener.dart';

class RawEditor extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool readOnly;
  final String? placeholder;
  final ValueChanged<String>? onLaunchUrl;
  final ToolbarOptions toolbarOptions;
  final bool showSelectionHandles;
  final bool showCursor;
  final CursorStyle cursorStyle;
  final TextCapitalization textCapitalization;
  final double? maxHeight;
  final double? minHeight;
  final DefaultStyles? customStyles;
  final bool expands;
  final bool autoFocus;
  final Color selectionColor;
  final TextSelectionControls selectionCtrls;
  final Brightness keyboardAppearance;
  final bool enableInteractiveSelection;
  final ScrollPhysics? scrollPhysics;
  final EmbedBuilder embedBuilder;

  const RawEditor(
      Key key,
      this.controller,
      this.focusNode,
      this.scrollController,
      this.scrollable,
      this.padding,
      this.readOnly,
      this.placeholder,
      this.onLaunchUrl,
      this.toolbarOptions,
      this.showSelectionHandles,
      bool? showCursor,
      this.cursorStyle,
      this.textCapitalization,
      this.maxHeight,
      this.minHeight,
      this.customStyles,
      this.expands,
      this.autoFocus,
      this.selectionColor,
      this.selectionCtrls,
      this.keyboardAppearance,
      this.enableInteractiveSelection,
      this.scrollPhysics,
      this.embedBuilder)
      : assert(maxHeight == null || maxHeight > 0, 'maxHeight cannot be null'),
        assert(minHeight == null || minHeight >= 0, 'minHeight cannot be null'),
        assert(maxHeight == null || minHeight == null || maxHeight >= minHeight,
            'maxHeight cannot be null'),
        showCursor = showCursor ?? true,
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
  TextInputConnection? _textInputConnection;
  TextEditingValue? _lastKnownRemoteTextEditingValue;
  int _cursorResetLocation = -1;
  bool _wasSelectingVerticallyWithKeyboard = false;
  EditorTextSelectionOverlay? _selectionOverlay;
  FocusAttachment? _focusAttachment;
  late CursorCont _cursorCont;
  ScrollController? _scrollController;
  KeyboardVisibilityController? _keyboardVisibilityController;
  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  late KeyboardListener _keyboardListener;
  bool _didAutoFocus = false;
  bool _keyboardVisible = false;
  DefaultStyles? _styles;
  final ClipboardStatusNotifier? _clipboardStatus =
      kIsWeb ? null : ClipboardStatusNotifier();
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  /// Whether to create an input connection with the platform for text editing
  /// or not.
  ///
  /// Read-only input fields do not need a connection with the platform since
  /// there's no need for text editing capabilities (e.g. virtual keyboard).
  ///
  /// On the web, we always need a connection because we want some browser
  /// functionalities to continue to work on read-only input fields like:
  ///
  /// - Relevant context menu.
  /// - cmd/ctrl+c shortcut to copy.
  /// - cmd/ctrl+a to select all.
  /// - Changing the selection using a physical keyboard.
  bool get shouldCreateInputConnection => kIsWeb || !widget.readOnly;

  bool get _hasFocus => widget.focusNode.hasFocus;

  TextDirection get _textDirection {
    TextDirection result = Directionality.of(context);
    return result;
  }

  void handleCursorMovement(
    LogicalKeyboardKey key,
    bool wordModifier,
    bool lineModifier,
    bool shift,
  ) {
    if (wordModifier && lineModifier) {
      return;
    }
    TextSelection selection = widget.controller.selection;

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

    RenderEditableBox child =
        getRenderEditor()!.childAtPosition(originPosition);
    TextPosition localPosition = TextPosition(
        offset:
            originPosition.offset - child.getContainer().getDocumentOffset());

    TextPosition? position = upKey
        ? child.getPositionAbove(localPosition)
        : child.getPositionBelow(localPosition);

    if (position == null) {
      var sibling = upKey
          ? getRenderEditor()!.childBefore(child)
          : getRenderEditor()!.childAfter(child);
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
        TextSelection textSelection = getRenderEditor()!.selectWordAtPosition(
            TextPosition(
                offset: _previousCharacter(
                    newSelection.extentOffset, plainText, false)));
        return newSelection.copyWith(extentOffset: textSelection.baseOffset);
      }
      TextSelection textSelection = getRenderEditor()!.selectWordAtPosition(
          TextPosition(
              offset:
                  _nextCharacter(newSelection.extentOffset, plainText, false)));
      return newSelection.copyWith(extentOffset: textSelection.extentOffset);
    } else if (lineModifier) {
      if (leftKey) {
        TextSelection textSelection = getRenderEditor()!.selectLineAtPosition(
            TextPosition(
                offset: _previousCharacter(
                    newSelection.extentOffset, plainText, false)));
        return newSelection.copyWith(extentOffset: textSelection.baseOffset);
      }
      int startPoint = newSelection.extentOffset;
      if (startPoint < plainText.length) {
        TextSelection textSelection = getRenderEditor()!
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
    int? lastNonWhitespace;
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
      _textInputConnection != null && _textInputConnection!.attached;

  void openConnectionIfNeeded() {
    if (!shouldCreateInputConnection) {
      return;
    }

    if (!hasConnection) {
      _lastKnownRemoteTextEditingValue = textEditingValue;
      _textInputConnection = TextInput.attach(
        this,
        TextInputConfiguration(
          inputType: TextInputType.multiline,
          readOnly: widget.readOnly,
          inputAction: TextInputAction.newline,
          enableSuggestions: !widget.readOnly,
          keyboardAppearance: widget.keyboardAppearance,
          textCapitalization: widget.textCapitalization,
        ),
      );

      _textInputConnection!.setEditingState(_lastKnownRemoteTextEditingValue!);
      // _sentRemoteValues.add(_lastKnownRemoteTextEditingValue);
    }

    _textInputConnection!.show();
  }

  void closeConnectionIfNeeded() {
    if (!hasConnection) {
      return;
    }
    _textInputConnection!.close();
    _textInputConnection = null;
    _lastKnownRemoteTextEditingValue = null;
    _sentRemoteValues.clear();
  }

  void updateRemoteValueIfNeeded() {
    if (!hasConnection) {
      return;
    }

    TextEditingValue actualValue = textEditingValue.copyWith(
      composing: _lastKnownRemoteTextEditingValue!.composing,
    );

    if (actualValue == _lastKnownRemoteTextEditingValue) {
      return;
    }

    bool shouldRemember =
        textEditingValue.text != _lastKnownRemoteTextEditingValue!.text;
    _lastKnownRemoteTextEditingValue = actualValue;
    _textInputConnection!.setEditingState(actualValue);
    if (shouldRemember) {
      _sentRemoteValues.add(actualValue);
    }
  }

  @override
  TextEditingValue? get currentTextEditingValue =>
      _lastKnownRemoteTextEditingValue;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    if (!shouldCreateInputConnection) {
      return;
    }

    if (_sentRemoteValues.contains(value)) {
      _sentRemoteValues.remove(value);
      return;
    }

    if (_lastKnownRemoteTextEditingValue == value) {
      return;
    }

    if (_lastKnownRemoteTextEditingValue!.text == value.text &&
        _lastKnownRemoteTextEditingValue!.selection == value.selection) {
      _lastKnownRemoteTextEditingValue = value;
      return;
    }

    TextEditingValue effectiveLastKnownValue =
        _lastKnownRemoteTextEditingValue!;
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
    return getTextEditingValue();
  }

  @override
  set textEditingValue(TextEditingValue value) {
    setTextEditingValue(value);
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
    _textInputConnection!.connectionClosedReceived();
    _textInputConnection = null;
    _lastKnownRemoteTextEditingValue = null;
    _sentRemoteValues.clear();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    _focusAttachment!.reparent();
    super.build(context);

    Document _doc = widget.controller.document;
    if (_doc.isEmpty() &&
        !widget.focusNode.hasFocus &&
        widget.placeholder != null) {
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
          textDirection: _textDirection,
          startHandleLayerLink: _startHandleLayerLink,
          endHandleLayerLink: _endHandleLayerLink,
          onSelectionChanged: _handleSelectionChanged,
          padding: widget.padding,
          children: _buildChildren(_doc, context),
        ),
      ),
    );

    if (widget.scrollable) {
      EdgeInsets baselinePadding =
          EdgeInsets.only(top: _styles!.paragraph!.verticalSpacing.item1);
      child = BaselineProxy(
        textStyle: _styles!.paragraph!.style,
        padding: baselinePadding,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: widget.scrollPhysics,
          child: child,
        ),
      );
    }

    BoxConstraints constraints = widget.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.minHeight ?? 0.0,
            maxHeight: widget.maxHeight ?? double.infinity);

    return QuillStyles(
      data: _styles!,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Container(
          constraints: constraints,
          child: child,
        ),
      ),
    );
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    widget.controller.updateSelection(selection, ChangeSource.LOCAL);

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();

    if (!_keyboardVisible) {
      requestKeyboard();
    }
  }

  List<Widget> _buildChildren(Document doc, BuildContext context) {
    final result = <Widget>[];
    Map<int, int> indentLevelCounts = {};
    for (Node node in doc.root.children) {
      if (node is Line) {
        EditableTextLine editableTextLine =
            _getEditableTextLineFromNode(node, context);
        result.add(editableTextLine);
      } else if (node is Block) {
        Map<String, Attribute> attrs = node.style.attributes;
        EditableTextBlock editableTextBlock = EditableTextBlock(
            node,
            _textDirection,
            _getVerticalSpacingForBlock(node, _styles),
            widget.controller.selection,
            widget.selectionColor,
            _styles,
            widget.enableInteractiveSelection,
            _hasFocus,
            attrs.containsKey(Attribute.codeBlock.key)
                ? const EdgeInsets.all(16.0)
                : null,
            widget.embedBuilder,
            _cursorCont,
            indentLevelCounts);
        result.add(editableTextBlock);
      } else {
        throw StateError('Unreachable.');
      }
    }
    return result;
  }

  EditableTextLine _getEditableTextLineFromNode(
      Line node, BuildContext context) {
    TextLine textLine = TextLine(
      line: node,
      textDirection: _textDirection,
      embedBuilder: widget.embedBuilder,
      styles: _styles!,
    );
    EditableTextLine editableTextLine = EditableTextLine(
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
    Map<String, Attribute> attrs = line.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      int? level = attrs[Attribute.header.key]!.value;
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
    Map<String, Attribute> attrs = node.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles!.quote!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles!.code!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.indent.key)) {
      return defaultStyles!.indent!.verticalSpacing;
    }
    return defaultStyles!.lists!.verticalSpacing;
  }

  @override
  void initState() {
    super.initState();

    _clipboardStatus?.addListener(_onChangedClipboardStatus);

    widget.controller.addListener(_didChangeTextEditingValue);

    _scrollController = widget.scrollController;
    _scrollController!.addListener(_updateSelectionOverlayForScroll);

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(widget.showCursor),
      style: widget.cursorStyle,
      tickerProvider: this,
    );

    _keyboardListener = KeyboardListener(
      handleCursorMovement,
      handleShortcut,
      handleDelete,
    );

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia) {
      _keyboardVisible = true;
    } else {
      _keyboardVisibilityController = KeyboardVisibilityController();
      _keyboardVisible = _keyboardVisibilityController!.isVisible;
      _keyboardVisibilitySubscription =
          _keyboardVisibilityController?.onChange.listen((bool visible) {
        _keyboardVisible = visible;
        if (visible) {
          _onChangeTextEditingValue();
        }
      });
    }

    _focusAttachment = widget.focusNode.attach(context,
        onKey: (node, event) => _keyboardListener.handleRawKeyEvent(event));
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DefaultStyles? parentStyles = QuillStyles.getStyles(context, true);
    DefaultStyles defaultStyles = DefaultStyles.getInstance(context);
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
      _scrollController!.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.scrollController;
      _scrollController!.addListener(_updateSelectionOverlayForScroll);
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

  void handleDelete(bool forward) {
    TextSelection selection = widget.controller.selection;
    String plainText = textEditingValue.text;
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

  void handleShortcut(InputShortcut? shortcut) async {
    TextSelection selection = widget.controller.selection;
    String plainText = textEditingValue.text;
    if (shortcut == InputShortcut.COPY) {
      if (!selection.isCollapsed) {
        await Clipboard.setData(
            ClipboardData(text: selection.textInside(plainText)));
      }
      return;
    }
    if (shortcut == InputShortcut.CUT && !widget.readOnly) {
      if (!selection.isCollapsed) {
        final data = selection.textInside(plainText);
        await Clipboard.setData(ClipboardData(text: data));

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
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        widget.controller.replaceText(
          selection.start,
          selection.end - selection.start,
          data.text,
          TextSelection.collapsed(offset: selection.start + data.text!.length),
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
    _keyboardVisibilitySubscription?.cancel();
    assert(!hasConnection);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    widget.controller.removeListener(_didChangeTextEditingValue);
    widget.focusNode.removeListener(_handleFocusChanged);
    _focusAttachment!.detach();
    _cursorCont.dispose();
    _clipboardStatus?.removeListener(_onChangedClipboardStatus);
    _clipboardStatus?.dispose();
    super.dispose();
  }

  void _updateSelectionOverlayForScroll() {
    _selectionOverlay?.markNeedsBuild();
  }

  void _didChangeTextEditingValue() {
    if (kIsWeb) {
      _onChangeTextEditingValue();
      requestKeyboard();
      return;
    }

    if (_keyboardVisible) {
      _onChangeTextEditingValue();
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

  void _onChangeTextEditingValue() {
    _showCaretOnScreen();
    updateRemoteValueIfNeeded();
    _cursorCont.startOrStopCursorTimerIfNeeded(
        _hasFocus, widget.controller.selection);
    if (hasConnection) {
      _cursorCont.stopCursorTimer(resetCharTicks: false);
      _cursorCont.startCursorTimer();
    }

    SchedulerBinding.instance!.addPostFrameCallback(
        (Duration _) => _updateOrDisposeSelectionOverlayIfNeeded());
    if (!mounted) return;
    setState(() {
      // Use widget.controller.value in build()
      // Trigger build and updateChildren
    });
  }

  void _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      if (_hasFocus) {
        _selectionOverlay!.update(textEditingValue);
      } else {
        _selectionOverlay!.dispose();
        _selectionOverlay = null;
      }
    } else if (_hasFocus) {
      _selectionOverlay?.hide();
      _selectionOverlay = null;

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
        _clipboardStatus!,
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

  bool _showCaretOnScreenScheduled = false;

  void _showCaretOnScreen() {
    if (!widget.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      _showCaretOnScreenScheduled = false;

      final viewport = RenderAbstractViewport.of(getRenderEditor())!;
      final editorOffset = getRenderEditor()!
          .localToGlobal(const Offset(0.0, 0.0), ancestor: viewport);
      final offsetInViewport = _scrollController!.offset + editorOffset.dy;

      final offset = getRenderEditor()!.getOffsetToRevealCursor(
        _scrollController!.position.viewportDimension,
        _scrollController!.offset,
        offsetInViewport,
      );

      if (offset != null) {
        _scrollController!.animateTo(
          offset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  RenderEditor? getRenderEditor() {
    return _editorKey.currentContext!.findRenderObject() as RenderEditor?;
  }

  @override
  EditorTextSelectionOverlay? getSelectionOverlay() {
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
  void requestKeyboard() {
    if (_hasFocus) {
      openConnectionIfNeeded();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  @override
  void setTextEditingValue(TextEditingValue value) {
    if (value.text == textEditingValue.text) {
      widget.controller.updateSelection(value.selection, ChangeSource.LOCAL);
    } else {
      __setEditingValue(value);
    }
  }

  void __setEditingValue(TextEditingValue value) async {
    if (await __isItCut(value)) {
      widget.controller.replaceText(
        textEditingValue.selection.start,
        textEditingValue.text.length - value.text.length,
        '',
        value.selection,
      );
    } else {
      final TextEditingValue value = textEditingValue;
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        final length =
            textEditingValue.selection.end - textEditingValue.selection.start;
        widget.controller.replaceText(
          value.selection.start,
          length,
          data.text,
          value.selection,
        );
        // move cursor to the end of pasted text selection
        widget.controller.updateSelection(
            TextSelection.collapsed(
                offset: value.selection.start + data.text!.length),
            ChangeSource.LOCAL);
      }
    }
  }

  Future<bool> __isItCut(TextEditingValue value) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) {
      return false;
    }
    return textEditingValue.text.length - value.text.length ==
        data.text!.length;
  }

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
  bool get wantKeepAlive => widget.focusNode.hasFocus;

  void openOrCloseConnection() {
    if (widget.focusNode.hasFocus && widget.focusNode.consumeKeyboardToken()) {
      openConnectionIfNeeded();
    } else if (!widget.focusNode.hasFocus) {
      closeConnectionIfNeeded();
    }
  }
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
      const EdgeInsets.fromLTRB(4, 4, 4, 5),
    );
  }

  @override
  void updateRenderObject(
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
