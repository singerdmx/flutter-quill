import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/text_selection.dart';

import 'controller.dart';
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
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
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

class RawEditor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
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
