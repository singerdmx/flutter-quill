import 'dart:convert';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/container.dart'
    as containerNode;
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/utils/universal_ui/universal_ui.dart';
import 'package:flutter_quill/widgets/image.dart';
import 'package:flutter_quill/widgets/raw_editor.dart';
import 'package:flutter_quill/widgets/responsive_widget.dart';
import 'package:flutter_quill/widgets/text_selection.dart';
import 'package:string_validator/string_validator.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';

const linkPrefixes = [
  'mailto:', // email
  'tel:', // telephone
  'sms:', // SMS
  'callto:',
  'wtai:',
  'market:',
  'geopoint:',
  'ymsgr:',
  'msnim:',
  'gtalk:', // Google Talk
  'skype:',
  'sip:', // Lync
  'whatsapp:',
  'http'
];

abstract class EditorState extends State<RawEditor> {
  TextEditingValue getTextEditingValue();

  void setTextEditingValue(TextEditingValue value);

  RenderEditor? getRenderEditor();

  EditorTextSelectionOverlay? getSelectionOverlay();

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

Widget _defaultEmbedBuilder(BuildContext context, leaf.Embed node) {
  switch (node.value.type) {
    case 'image':
      String imageUrl = node.value.data;
      return imageUrl.startsWith('http')
          ? Image.network(imageUrl)
          : Image.file(io.File(imageUrl));
    default:
      throw UnimplementedError(
          'Embeddable type "${node.value.type}" is not supported by default embed '
          'builder of QuillEditor. You must pass your own builder function to '
          'embedBuilder property of QuillEditor or QuillField widgets.');
  }
}

Widget _defaultEmbedBuilderWeb(BuildContext context, leaf.Embed node) {
  switch (node.value.type) {
    case 'image':
      String imageUrl = node.value.data;
      Size size = MediaQuery.of(context).size;
      UniversalUI().platformViewRegistry.registerViewFactory(
          imageUrl, (int viewId) => html.ImageElement()..src = imageUrl);
      return Padding(
        padding: EdgeInsets.only(
          right: ResponsiveWidget.isMediumScreen(context)
              ? size.width * 0.5
              : (ResponsiveWidget.isLargeScreen(context))
                  ? size.width * 0.75
                  : size.width * 0.2,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: HtmlElementView(
            viewType: imageUrl,
          ),
        ),
      );

    default:
      throw UnimplementedError(
          'Embeddable type "${node.value.type}" is not supported by default embed '
          'builder of QuillEditor. You must pass your own builder function to '
          'embedBuilder property of QuillEditor or QuillField widgets.');
  }
}

class QuillEditor extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool autoFocus;
  final bool? showCursor;
  final bool readOnly;
  final String? placeholder;
  final bool enableInteractiveSelection;
  final double? minHeight;
  final double? maxHeight;
  final DefaultStyles? customStyles;
  final bool expands;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<String>? onLaunchUrl;
  final EmbedBuilder embedBuilder;

  QuillEditor(
      {required this.controller,
      required this.focusNode,
      required this.scrollController,
      required this.scrollable,
      required this.padding,
      required this.autoFocus,
      this.showCursor,
      required this.readOnly,
      this.placeholder,
      this.enableInteractiveSelection = true,
      this.minHeight,
      this.maxHeight,
      this.customStyles,
      required this.expands,
      this.textCapitalization = TextCapitalization.sentences,
      this.keyboardAppearance = Brightness.light,
      this.scrollPhysics,
      this.onLaunchUrl,
      this.embedBuilder =
          kIsWeb ? _defaultEmbedBuilderWeb : _defaultEmbedBuilder});

  factory QuillEditor.basic(
      {required QuillController controller, required bool readOnly}) {
    return QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: FocusNode(),
        autoFocus: true,
        readOnly: readOnly,
        enableInteractiveSelection: true,
        expands: false,
        padding: EdgeInsets.zero);
  }

  @override
  _QuillEditorState createState() => _QuillEditorState();
}

class _QuillEditorState extends State<QuillEditor>
    implements EditorTextSelectionGestureDetectorBuilderDelegate {
  GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  late EditorTextSelectionGestureDetectorBuilder
      _selectionGestureDetectorBuilder;

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
    Offset? cursorOffset;
    Color? cursorColor;
    Color selectionColor;
    Radius? cursorRadius;

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
          widget.placeholder,
          widget.onLaunchUrl,
          ToolbarOptions(
            copy: widget.enableInteractiveSelection,
            cut: widget.enableInteractiveSelection,
            paste: widget.enableInteractiveSelection,
            selectAll: widget.enableInteractiveSelection,
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
          widget.customStyles,
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
    _editorKey.currentState!.requestKeyboard();
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
      getEditor()!.showToolbar();
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
        getRenderEditor()!.selectPositionAt(
          details.globalPosition,
          null,
          SelectionChangedCause.longPress,
        );
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        getRenderEditor()!.selectWordsInRange(
          details.globalPosition - details.offsetFromOrigin,
          details.globalPosition,
          SelectionChangedCause.longPress,
        );
        break;
      default:
        throw ('Invalid platform');
    }
  }

  bool _onTapping(TapUpDetails details) {
    if (_state.widget.controller.document.isEmpty()) {
      return false;
    }
    TextPosition pos =
        getRenderEditor()!.getPositionForOffset(details.globalPosition);
    containerNode.ChildQuery result =
        getEditor()!.widget.controller.document.queryChild(pos.offset);
    if (result.node == null) {
      return false;
    }
    Line line = result.node as Line;
    containerNode.ChildQuery segmentResult =
        line.queryChild(result.offset, false);
    if (segmentResult.node == null) {
      if (line.length == 1) {
        // tapping when no text yet on this line
        _flipListCheckbox(pos, line, segmentResult);
        getEditor()!.widget.controller.updateSelection(
            TextSelection.collapsed(offset: pos.offset), ChangeSource.LOCAL);
        return true;
      }
      return false;
    }
    leaf.Leaf segment = segmentResult.node as leaf.Leaf;
    if (segment.style.containsKey(Attribute.link.key)) {
      var launchUrl = getEditor()!.widget.onLaunchUrl;
      if (launchUrl == null) {
        launchUrl = _launchUrl;
      }
      String? link = segment.style.attributes[Attribute.link.key]!.value;
      if (getEditor()!.widget.readOnly && link != null) {
        link = link.trim();
        if (!linkPrefixes
            .any((linkPrefix) => link!.toLowerCase().startsWith(linkPrefix))) {
          link = 'https://$link';
        }
        launchUrl(link);
      }
      return false;
    }
    if (getEditor()!.widget.readOnly && segment.value is BlockEmbed) {
      BlockEmbed blockEmbed = segment.value as BlockEmbed;
      if (blockEmbed.type == 'image') {
        final String imageUrl = blockEmbed.data;
        Navigator.push(
          getEditor()!.context,
          MaterialPageRoute(
            builder: (context) => ImageTapWrapper(
              imageProvider: imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : isBase64(imageUrl)
                      ? Image.memory(base64.decode(imageUrl))
                          as ImageProvider<Object>?
                      : FileImage(io.File(imageUrl)),
            ),
          ),
        );
      }
      return false;
    }
    if (_flipListCheckbox(pos, line, segmentResult)) {
      return true;
    }
    return false;
  }

  bool _flipListCheckbox(
      TextPosition pos, Line line, containerNode.ChildQuery segmentResult) {
    if (getEditor()!.widget.readOnly ||
        !line.style.containsKey(Attribute.list.key) ||
        segmentResult.offset != 0) {
      return false;
    }
    // segmentResult.offset == 0 means tap at the beginning of the TextLine
    String? listVal = line.style.attributes[Attribute.list.key]!.value;
    if (listVal == Attribute.unchecked.value) {
      getEditor()!
          .widget
          .controller
          .formatText(pos.offset, 0, Attribute.checked);
    } else if (listVal == Attribute.checked.value) {
      getEditor()!
          .widget
          .controller
          .formatText(pos.offset, 0, Attribute.unchecked);
    }
    getEditor()!.widget.controller.updateSelection(
        TextSelection.collapsed(offset: pos.offset), ChangeSource.LOCAL);
    return true;
  }

  void _launchUrl(String url) async {
    await launch(url);
  }

  @override
  onSingleTapUp(TapUpDetails details) {
    getEditor()!.hideToolbar();

    bool positionSelected = _onTapping(details);

    if (delegate.getSelectionEnabled() && !positionSelected) {
      switch (Theme.of(_state.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              getRenderEditor()!.selectPosition(SelectionChangedCause.tap);
              break;
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              getRenderEditor()!.selectWordEdge(SelectionChangedCause.tap);
              break;
          }
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          getRenderEditor()!.selectPosition(SelectionChangedCause.tap);
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
          getRenderEditor()!.selectPositionAt(
            details.globalPosition,
            null,
            SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          getRenderEditor()!.selectWord(SelectionChangedCause.longPress);
          Feedback.forLongPress(_state.context);
          break;
        default:
          throw ('Invalid platform');
      }
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
      List<RenderEditableBox>? children,
      TextDirection textDirection,
      EdgeInsetsGeometry padding,
      this.document,
      this.selection,
      this._hasFocus,
      this.onSelectionChanged,
      this._startHandleLayerLink,
      this._endHandleLayerLink,
      EdgeInsets floatingCursorAddedMargin)
      : super(
          children,
          document.root,
          textDirection,
          padding,
        );

  setDocument(Document doc) {
    if (document == doc) {
      return;
    }
    document = doc;
    markNeedsLayout();
  }

  setHasFocus(bool h) {
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
    if (textSelection.isCollapsed) {
      RenderEditableBox child = childAtPosition(textSelection.extent);
      TextPosition localPosition = TextPosition(
          offset:
              textSelection.extentOffset - child.getContainer().getOffset());
      Offset localOffset = child.getOffsetForCaret(localPosition);
      BoxParentData parentData = child.parentData as BoxParentData;
      return <TextSelectionPoint>[
        TextSelectionPoint(
            Offset(0.0, child.preferredLineHeight(localPosition)) +
                localOffset +
                parentData.offset,
            null)
      ];
    }

    Node? baseNode = _container.queryChild(textSelection.start, false).node;

    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.getContainer() == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    BoxParentData baseParentData = baseChild!.parentData as BoxParentData;
    TextSelection baseSelection =
        localSelection(baseChild.getContainer(), textSelection, true);
    TextSelectionPoint basePoint =
        baseChild.getBaseEndpointForSelection(baseSelection);
    basePoint = TextSelectionPoint(
        basePoint.point + baseParentData.offset, basePoint.direction);

    Node? extentNode = _container.queryChild(textSelection.end, false).node;
    RenderEditableBox? extentChild = baseChild;
    while (extentChild != null) {
      if (extentChild.getContainer() == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    BoxParentData extentParentData = extentChild!.parentData as BoxParentData;
    TextSelection extentSelection =
        localSelection(extentChild.getContainer(), textSelection, true);
    TextSelectionPoint extentPoint =
        extentChild.getExtentEndpointForSelection(extentSelection);
    extentPoint = TextSelectionPoint(
        extentPoint.point + extentParentData.offset, extentPoint.direction);

    return <TextSelectionPoint>[basePoint, extentPoint];
  }

  Offset? _lastTapDownPosition;

  @override
  handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  @override
  selectWordsInRange(
    Offset from,
    Offset? to,
    SelectionChangedCause cause,
  ) {
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
    onSelectionChanged(nextSelection, cause);
  }

  @override
  selectWordEdge(SelectionChangedCause cause) {
    assert(_lastTapDownPosition != null);
    TextPosition position = getPositionForOffset(_lastTapDownPosition!);
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
    Offset? to,
    SelectionChangedCause cause,
  ) {
    TextPosition fromPosition = getPositionForOffset(from);
    TextPosition? toPosition = to == null ? null : getPositionForOffset(to);

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
    selectWordsInRange(_lastTapDownPosition!, null, cause);
  }

  @override
  selectPosition(SelectionChangedCause cause) {
    selectPositionAt(_lastTapDownPosition!, null, cause);
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
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
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
    RenderEditableBox child = childAtOffset(local)!;

    BoxParentData parentData = child.parentData as BoxParentData;
    Offset localOffset = local - parentData.offset;
    TextPosition localPosition = child.getPositionForOffset(localOffset);
    return TextPosition(
      offset: localPosition.offset + child.getContainer().getOffset(),
      affinity: localPosition.affinity,
    );
  }

  double? getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport) {
    List<TextSelectionPoint> endpoints = getEndpointsForSelection(selection);
    TextSelectionPoint endpoint = endpoints.first;
    RenderEditableBox child = childAtPosition(selection.extent);
    const kMargin = 8.0;

    double caretTop = endpoint.point.dy -
        child.preferredLineHeight(TextPosition(
            offset:
                selection.extentOffset - child.getContainer().getOffset())) -
        kMargin +
        offsetInViewport;
    final caretBottom = endpoint.point.dy + kMargin + offsetInViewport;
    double? dy;
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
  EdgeInsets? _resolvedPadding;

  RenderEditableContainerBox(List<RenderEditableBox>? children, this._container,
      this.textDirection, this._padding)
      : assert(_padding.isNonNegative) {
    addAll(children);
  }

  containerNode.Container getContainer() {
    return _container;
  }

  setContainer(containerNode.Container c) {
    if (_container == c) {
      return;
    }
    _container = c;
    markNeedsLayout();
  }

  EdgeInsetsGeometry getPadding() => _padding;

  setPadding(EdgeInsetsGeometry value) {
    assert(value.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    _markNeedsPaddingResolution();
  }

  EdgeInsets? get resolvedPadding => _resolvedPadding;

  _resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = _padding.resolve(textDirection);
    _resolvedPadding = _resolvedPadding!.copyWith(left: _resolvedPadding!.left);

    assert(_resolvedPadding!.isNonNegative);
  }

  RenderEditableBox childAtPosition(TextPosition position) {
    assert(firstChild != null);

    Node? targetNode = _container.queryChild(position.offset, false).node;

    var targetChild = firstChild;
    while (targetChild != null) {
      if (targetChild.getContainer() == targetNode) {
        break;
      }
      targetChild = childAfter(targetChild);
    }
    if (targetChild == null) {
      throw ('targetChild should not be null');
    }
    return targetChild;
  }

  _markNeedsPaddingResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  RenderEditableBox? childAtOffset(Offset offset) {
    assert(firstChild != null);
    _resolvePadding();

    if (offset.dy <= _resolvedPadding!.top) {
      return firstChild;
    }
    if (offset.dy >= size.height - _resolvedPadding!.bottom) {
      return lastChild;
    }

    var child = firstChild;
    double dx = -offset.dx, dy = _resolvedPadding!.top;
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

    double mainAxisExtent = _resolvedPadding!.top;
    var child = firstChild;
    BoxConstraints innerConstraints =
        BoxConstraints.tightFor(width: constraints.maxWidth)
            .deflate(_resolvedPadding!);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final EditableContainerParentData childParentData =
          child.parentData as EditableContainerParentData;
      childParentData.offset = Offset(_resolvedPadding!.left, mainAxisExtent);
      mainAxisExtent += child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += _resolvedPadding!.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));

    assert(size.isFinite);
  }

  double _getIntrinsicCrossAxis(double Function(RenderBox child) childSize) {
    double extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      EditableContainerParentData childParentData =
          child.parentData as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  double _getIntrinsicMainAxis(double Function(RenderBox child) childSize) {
    double extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent += childSize(child);
      EditableContainerParentData childParentData =
          child.parentData as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolvePadding();
    return _getIntrinsicCrossAxis((RenderBox child) {
      double childHeight = math.max(
          0.0, height - _resolvedPadding!.top + _resolvedPadding!.bottom);
      return child.getMinIntrinsicWidth(childHeight) +
          _resolvedPadding!.left +
          _resolvedPadding!.right;
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    return _getIntrinsicCrossAxis((RenderBox child) {
      double childHeight = math.max(
          0.0, height - _resolvedPadding!.top + _resolvedPadding!.bottom);
      return child.getMaxIntrinsicWidth(childHeight) +
          _resolvedPadding!.left +
          _resolvedPadding!.right;
    });
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    return _getIntrinsicMainAxis((RenderBox child) {
      double childWidth = math.max(
          0.0, width - _resolvedPadding!.left + _resolvedPadding!.right);
      return child.getMinIntrinsicHeight(childWidth) +
          _resolvedPadding!.top +
          _resolvedPadding!.bottom;
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolvePadding();
    return _getIntrinsicMainAxis((RenderBox child) {
      final childWidth = math.max(
          0.0, width - _resolvedPadding!.left + _resolvedPadding!.right);
      return child.getMaxIntrinsicHeight(childWidth) +
          _resolvedPadding!.top +
          _resolvedPadding!.bottom;
    });
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return defaultComputeDistanceToFirstActualBaseline(baseline)! +
        _resolvedPadding!.top;
  }
}
