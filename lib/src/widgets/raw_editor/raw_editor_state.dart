import 'dart:async' show StreamSubscription;
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;
import 'dart:ui' as ui hide TextStyle;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/services.dart'
    show
        Clipboard,
        ClipboardData,
        HardwareKeyboard,
        LogicalKeyboardKey,
        KeyDownEvent,
        SystemChannels,
        TextInputControl;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart'
    show KeyboardVisibilityController;
import 'package:html/parser.dart' as html_parser;
import 'package:super_clipboard/super_clipboard.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/delta_x.dart';
import '../../models/documents/document.dart';
import '../../models/documents/nodes/block.dart';
import '../../models/documents/nodes/embeddable.dart';
import '../../models/documents/nodes/leaf.dart' as leaf;
import '../../models/documents/nodes/line.dart';
import '../../models/documents/nodes/node.dart';
import '../../models/structs/offset_value.dart';
import '../../models/structs/vertical_spacing.dart';
import '../../utils/cast.dart';
import '../../utils/delta.dart';
import '../../utils/embeds.dart';
import '../../utils/platform.dart';
import '../editor/editor.dart';
import '../others/cursor.dart';
import '../others/default_styles.dart';
import '../others/keyboard_listener.dart';
import '../others/link.dart';
import '../others/proxy.dart';
import '../others/text_selection.dart';
import '../quill/quill_controller.dart';
import '../quill/text_block.dart';
import '../quill/text_line.dart';
import 'quill_single_child_scroll_view.dart';
import 'raw_editor.dart';
import 'raw_editor_actions.dart';
import 'raw_editor_render_object.dart';
import 'raw_editor_state_selection_delegate_mixin.dart';
import 'raw_editor_state_text_input_client_mixin.dart';
import 'raw_editor_text_boundaries.dart';
import 'scribble_focusable.dart';

class QuillRawEditorState extends EditorState
    with
        AutomaticKeepAliveClientMixin<QuillRawEditor>,
        WidgetsBindingObserver,
        TickerProviderStateMixin<QuillRawEditor>,
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

  QuillController get controller => widget.configurations.controller;

  // Focus
  bool _didAutoFocus = false;

  bool get _hasFocus => widget.configurations.focusNode.hasFocus;

  // Theme
  DefaultStyles? _styles;

  // for pasting style
  @override
  List<OffsetValue> get pasteStyleAndEmbed => _pasteStyleAndEmbed;
  List<OffsetValue> _pasteStyleAndEmbed = <OffsetValue>[];

  @override
  String get pastePlainText => _pastePlainText;
  String _pastePlainText = '';

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
    assert(widget.configurations.contentInsertionConfiguration?.allowedMimeTypes
            .contains(content.mimeType) ??
        false);
    widget.configurations.contentInsertionConfiguration?.onContentInserted
        .call(content);
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
    controller.copiedImageUrl = null;
    _pastePlainText = controller.getPlainText();
    _pasteStyleAndEmbed = controller.getAllIndividualSelectionStylesAndEmbed();

    if (widget.configurations.readOnly) {
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
    if (widget.configurations.readOnly) {
      return;
    }

    // When image copied internally in the editor
    final copiedImageUrl = controller.copiedImageUrl;
    if (copiedImageUrl != null) {
      final index = textEditingValue.selection.baseOffset;
      final length = textEditingValue.selection.extentOffset - index;
      controller.replaceText(
        index,
        length,
        BlockEmbed.image(copiedImageUrl.url),
        null,
      );
      if (copiedImageUrl.styleString.isNotEmpty) {
        controller.formatText(
          getEmbedNode(controller, index + 1).offset,
          1,
          StyleAttribute(copiedImageUrl.styleString),
        );
      }
      controller.copiedImageUrl = null;
      await Clipboard.setData(
        const ClipboardData(text: ''),
      );
      return;
    }

    final selection = textEditingValue.selection;
    if (!selection.isValid) {
      return;
    }

    final clipboard = SystemClipboard.instance;

    if (clipboard != null) {
      final reader = await clipboard.read();
      if (reader.canProvide(Formats.htmlText)) {
        final html = await reader.readValue(Formats.htmlText);
        if (html == null) {
          return;
        }
        final htmlBody = html_parser.parse(html).body?.outerHtml;
        final deltaFromClipboard = DeltaX.fromHtml(htmlBody ?? html);

        controller.replaceText(
          textEditingValue.selection.start,
          textEditingValue.selection.end - textEditingValue.selection.start,
          deltaFromClipboard,
          TextSelection.collapsed(offset: textEditingValue.selection.end),
        );

        bringIntoView(textEditingValue.selection.extent);

        // Collapse the selection and hide the toolbar and handles.
        userUpdateTextEditingValue(
          TextEditingValue(
            text: textEditingValue.text,
            selection: TextSelection.collapsed(
              offset: textEditingValue.selection.end,
            ),
          ),
          cause,
        );

        return;
      }
    }

    // Snapshot the input before using `await`.
    // See https://github.com/flutter/flutter/issues/11427
    final plainText = await Clipboard.getData(Clipboard.kTextPlain);
    if (plainText != null) {
      _replaceText(
        ReplaceTextIntent(
          textEditingValue,
          plainText.text!,
          selection,
          cause,
        ),
      );

      bringIntoView(textEditingValue.selection.extent);

      // Collapse the selection and hide the toolbar and handles.
      userUpdateTextEditingValue(
        TextEditingValue(
          text: textEditingValue.text,
          selection: TextSelection.collapsed(
            offset: textEditingValue.selection.end,
          ),
        ),
        cause,
      );

      return;
    }

    final onImagePaste = widget.configurations.onImagePaste;
    if (onImagePaste != null) {
      if (clipboard != null) {
        final reader = await clipboard.read();
        if (reader.canProvide(Formats.png)) {
          reader.getFile(Formats.png, (value) async {
            final image = value;

            final imageUrl = await onImagePaste(await image.readAll());
            if (imageUrl == null) {
              return;
            }

            controller.replaceText(
              textEditingValue.selection.end,
              0,
              BlockEmbed.image(imageUrl),
              null,
            );
          });
        }
      }
    }

    final onGifPaste = widget.configurations.onGifPaste;
    if (onGifPaste != null) {
      if (clipboard != null) {
        final reader = await clipboard.read();
        if (reader.canProvide(Formats.gif)) {
          reader.getFile(Formats.gif, (value) async {
            final gif = value;

            final gifUrl = await onGifPaste(await gif.readAll());
            if (gifUrl == null) {
              return;
            }

            controller.replaceText(
              textEditingValue.selection.end,
              0,
              BlockEmbed.image(gifUrl),
              null,
            );
          });
        }
      }
    }
    return;
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
            widget.configurations.focusNode.unfocus();
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
        widget.configurations.focusNode.unfocus();
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
      enabled: widget.configurations.enableScribble &&
          !widget.configurations.readOnly,
      renderBoxForBounds: () => context
          .findAncestorStateOfType<QuillEditorState>()
          ?.context
          .findRenderObject() as RenderBox?,
      onScribbleFocus: (offset) {
        widget.configurations.focusNode.requestFocus();
        widget.configurations.onScribbleActivated?.call();
      },
      scribbleAreaInsets: widget.configurations.scribbleAreaInsets,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    super.build(context);

    var doc = controller.document;
    if (doc.isEmpty() && widget.configurations.placeholder != null) {
      final raw = widget.configurations.placeholder?.replaceAll(r'"', '\\"');
      doc = Document.fromJson(
        jsonDecode(
          '[{"attributes":{"placeholder":true},"insert":"$raw\\n"}]',
        ),
      );
    }

    if (!widget.configurations.disableClipboard) {
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
    if (widget.configurations.scrollable) {
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
          QuillSingleChildScrollView(
            controller: _scrollController,
            physics: widget.configurations.scrollPhysics,
            viewportBuilder: (_, offset) => CompositedTransformTarget(
              link: _toolbarLayerLink,
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                child: QuilRawEditorMultiChildRenderObject(
                  key: _editorKey,
                  offset: offset,
                  document: doc,
                  selection: controller.selection,
                  hasFocus: _hasFocus,
                  scrollable: widget.configurations.scrollable,
                  textDirection: _textDirection,
                  startHandleLayerLink: _startHandleLayerLink,
                  endHandleLayerLink: _endHandleLayerLink,
                  onSelectionChanged: _handleSelectionChanged,
                  onSelectionCompleted: _handleSelectionCompleted,
                  scrollBottomInset: widget.configurations.scrollBottomInset,
                  padding: widget.configurations.padding,
                  maxContentWidth: widget.configurations.maxContentWidth,
                  cursorController: _cursorCont,
                  floatingCursorDisabled:
                      widget.configurations.floatingCursorDisabled,
                  children: _buildChildren(doc, context),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      child = _scribbleFocusable(
        CompositedTransformTarget(
          link: _toolbarLayerLink,
          child: Semantics(
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: QuilRawEditorMultiChildRenderObject(
                key: _editorKey,
                document: doc,
                selection: controller.selection,
                hasFocus: _hasFocus,
                scrollable: widget.configurations.scrollable,
                cursorController: _cursorCont,
                textDirection: _textDirection,
                startHandleLayerLink: _startHandleLayerLink,
                endHandleLayerLink: _endHandleLayerLink,
                onSelectionChanged: _handleSelectionChanged,
                onSelectionCompleted: _handleSelectionCompleted,
                scrollBottomInset: widget.configurations.scrollBottomInset,
                padding: widget.configurations.padding,
                maxContentWidth: widget.configurations.maxContentWidth,
                floatingCursorDisabled:
                    widget.configurations.floatingCursorDisabled,
                children: _buildChildren(doc, context),
              ),
            ),
          ),
        ),
      );
    }

    final constraints = widget.configurations.expands
        ? const BoxConstraints.expand()
        : BoxConstraints(
            minHeight: widget.configurations.minHeight ?? 0.0,
            maxHeight: widget.configurations.maxHeight ?? double.infinity,
          );

    // Please notice that this change will make the check fixed
    // so if we ovveride the platform in material app theme data
    // it will not depend on it and doesn't change here but I don't think
    // we need to
    final isDesktopMacOS = isMacOS(supportWeb: true);

    return TextFieldTapRegion(
      enabled: widget.configurations.isOnTapOutsideEnabled,
      onTapOutside: (event) {
        final onTapOutside = widget.configurations.onTapOutside;
        if (onTapOutside != null) {
          onTapOutside.call(event, widget.configurations.focusNode);
          return;
        }
        _defaultOnTapOutside(event);
      },
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
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const UndoTextIntent(SelectionChangedCause.keyboard),
            SingleActivator(
              LogicalKeyboardKey.keyY,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const RedoTextIntent(SelectionChangedCause.keyboard),

            // Selection formatting.
            SingleActivator(
              LogicalKeyboardKey.keyB,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const ToggleTextStyleIntent(Attribute.bold),
            SingleActivator(
              LogicalKeyboardKey.keyU,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const ToggleTextStyleIntent(Attribute.underline),
            SingleActivator(
              LogicalKeyboardKey.keyI,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const ToggleTextStyleIntent(Attribute.italic),
            SingleActivator(
              LogicalKeyboardKey.keyS,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.strikeThrough),
            SingleActivator(
              LogicalKeyboardKey.backquote,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const ToggleTextStyleIntent(Attribute.inlineCode),
            SingleActivator(
              LogicalKeyboardKey.tilde,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.codeBlock),
            SingleActivator(
              LogicalKeyboardKey.keyB,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.blockQuote),
            SingleActivator(
              LogicalKeyboardKey.keyK,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyLinkIntent(),

            // Lists
            SingleActivator(
              LogicalKeyboardKey.keyL,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.ul),
            SingleActivator(
              LogicalKeyboardKey.keyO,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const ToggleTextStyleIntent(Attribute.ol),
            SingleActivator(
              LogicalKeyboardKey.keyC,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const QuillEditorApplyCheckListIntent(),

            // Indents
            SingleActivator(
              LogicalKeyboardKey.keyM,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const IndentSelectionIntent(true),
            SingleActivator(
              LogicalKeyboardKey.keyM,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
              shift: true,
            ): const IndentSelectionIntent(false),

            // Headers
            SingleActivator(
              LogicalKeyboardKey.digit1,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h1),
            SingleActivator(
              LogicalKeyboardKey.digit2,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h2),
            SingleActivator(
              LogicalKeyboardKey.digit3,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h3),
            SingleActivator(
              LogicalKeyboardKey.digit4,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h4),
            SingleActivator(
              LogicalKeyboardKey.digit5,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h5),
            SingleActivator(
              LogicalKeyboardKey.digit6,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.h6),
            SingleActivator(
              LogicalKeyboardKey.digit0,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorApplyHeaderIntent(Attribute.header),

            SingleActivator(
              LogicalKeyboardKey.keyG,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const QuillEditorInsertEmbedIntent(Attribute.image),

            SingleActivator(
              LogicalKeyboardKey.keyF,
              control: !isDesktopMacOS,
              meta: isDesktopMacOS,
            ): const OpenSearchIntent(),
          }, {
            ...?widget.configurations.customShortcuts
          }),
          child: Actions(
            actions: mergeMaps<Type, Action<Intent>>(_actions, {
              ...?widget.configurations.customActions,
            }),
            child: Focus(
              focusNode: widget.configurations.focusNode,
              onKeyEvent: _onKeyEvent,
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

  KeyEventResult _onKeyEvent(node, KeyEvent event) {
    // Don't handle key if there is a meta key pressed.
    if (HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent) {
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

  KeyEventResult _handleSpaceKey(KeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);
    if (child.node == null) {
      return KeyEventResult.ignored;
    }

    final line = child.node as Line?;
    if (line == null) {
      return KeyEventResult.ignored;
    }

    final text = castOrNull<leaf.QuillText>(line.first);
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

  KeyEventResult _handleTabKey(KeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);

    KeyEventResult insertTabCharacter() {
      if (widget.configurations.readOnly) {
        return KeyEventResult.ignored;
      }
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
        controller.indentSelection(!HardwareKeyboard.instance.isShiftPressed);
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

    if (node is! Line || (node.isNotEmpty && node.first is! leaf.QuillText)) {
      return insertTabCharacter();
    }

    final parentBlock = parent;
    if (parentBlock.style.containsKey(Attribute.ol.key) ||
        parentBlock.style.containsKey(Attribute.ul.key) ||
        parentBlock.style.containsKey(Attribute.checked.key)) {
      if (node.isNotEmpty &&
          (node.first as leaf.QuillText).value.isNotEmpty &&
          controller.selection.base.offset > node.documentOffset) {
        return insertTabCharacter();
      }
      controller.indentSelection(!HardwareKeyboard.instance.isShiftPressed);
      return KeyEventResult.handled;
    }

    if (node.isNotEmpty && (node.first as leaf.QuillText).value.isNotEmpty) {
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
        ChangeSource.local);
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
        widget.configurations.requestKeyboardFocusOnCheckListChanged;
    if (!widget.configurations.readOnly) {
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
          scrollBottomInset: widget.configurations.scrollBottomInset,
          verticalSpacing: _getVerticalSpacingForBlock(node, _styles),
          textSelection: controller.selection,
          color: widget.configurations.selectionColor,
          styles: _styles,
          enableInteractiveSelection:
              widget.configurations.enableInteractiveSelection,
          hasFocus: _hasFocus,
          contentPadding: attrs.containsKey(Attribute.codeBlock.key)
              ? const EdgeInsets.all(16)
              : null,
          embedBuilder: widget.configurations.embedBuilder,
          linkActionPicker: _linkActionPicker,
          onLaunchUrl: widget.configurations.onLaunchUrl,
          cursorCont: _cursorCont,
          indentLevelCounts: indentLevelCounts,
          clearIndents: clearIndents,
          onCheckboxTap: _handleCheckboxTap,
          readOnly: widget.configurations.readOnly,
          customStyleBuilder: widget.configurations.customStyleBuilder,
          customLinkPrefixes: widget.configurations.customLinkPrefixes,
        );
        result.add(
          Directionality(
            textDirection: getDirectionOfNode(node),
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
      embedBuilder: widget.configurations.embedBuilder,
      customStyleBuilder: widget.configurations.customStyleBuilder,
      customRecognizerBuilder: widget.configurations.customRecognizerBuilder,
      styles: _styles!,
      readOnly: widget.configurations.readOnly,
      controller: controller,
      linkActionPicker: _linkActionPicker,
      onLaunchUrl: widget.configurations.onLaunchUrl,
      customLinkPrefixes: widget.configurations.customLinkPrefixes,
    );
    final editableTextLine = EditableTextLine(
        node,
        null,
        textLine,
        0,
        _getVerticalSpacingForLine(node, _styles),
        _textDirection,
        controller.selection,
        widget.configurations.selectionColor,
        widget.configurations.enableInteractiveSelection,
        _hasFocus,
        MediaQuery.devicePixelRatioOf(context),
        _cursorCont);
    return editableTextLine;
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

  void _didChangeTextEditingValueListener() {
    _didChangeTextEditingValue(controller.ignoreFocusOnTextChange);
  }

  @override
  void initState() {
    super.initState();
    if (_clipboardStatus != null) {
      _clipboardStatus!.addListener(_onChangedClipboardStatus);
    }

    controller.addListener(_didChangeTextEditingValueListener);

    _scrollController = widget.configurations.scrollController;
    _scrollController.addListener(_updateSelectionOverlayForScroll);

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(widget.configurations.showCursor),
      style: widget.configurations.cursorStyle,
      tickerProvider: this,
    );

    // Floating cursor
    _floatingCursorResetController = AnimationController(vsync: this);
    _floatingCursorResetController.addListener(onFloatingCursorResetTick);

    if (isKeyboardOS(supportWeb: true)) {
      _keyboardVisible = true;
    } else if (!isWeb() && isFlutterTest()) {
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
    widget.configurations.focusNode.addListener(_handleFocusChanged);
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

    if (widget.configurations.customStyles != null) {
      _styles = _styles!.merge(widget.configurations.customStyles!);
    }

    _requestAutoFocusIfShould();
  }

  Future<void> _requestAutoFocusIfShould() async {
    final focusManager = FocusScope.of(context);
    if (!_didAutoFocus && widget.configurations.autoFocus) {
      await Future.delayed(Duration.zero); // To avoid exceptions
      focusManager.autofocus(widget.configurations.focusNode);
      _didAutoFocus = true;
    }
  }

  @override
  void didUpdateWidget(QuillRawEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    _cursorCont.show.value = widget.configurations.showCursor;
    _cursorCont.style = widget.configurations.cursorStyle;

    if (controller != oldWidget.configurations.controller) {
      oldWidget.configurations.controller
          .removeListener(_didChangeTextEditingValue);
      controller.addListener(_didChangeTextEditingValue);
      updateRemoteValueIfNeeded();
    }

    if (widget.configurations.scrollController != _scrollController) {
      _scrollController.removeListener(_updateSelectionOverlayForScroll);
      _scrollController = widget.configurations.scrollController;
      _scrollController.addListener(_updateSelectionOverlayForScroll);
    }

    if (widget.configurations.focusNode != oldWidget.configurations.focusNode) {
      oldWidget.configurations.focusNode.removeListener(_handleFocusChanged);
      widget.configurations.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
    }

    if (controller.selection != oldWidget.configurations.controller.selection) {
      _selectionOverlay?.update(textEditingValue);
    }

    _selectionOverlay?.handlesVisible = _shouldShowSelectionHandles();
    if (!shouldCreateInputConnection) {
      closeConnectionIfNeeded();
    } else {
      if (oldWidget.configurations.readOnly && _hasFocus) {
        openConnectionIfNeeded();
      }
    }

    // in case customStyles changed in new widget
    if (widget.configurations.customStyles != null) {
      _styles = _styles!.merge(widget.configurations.customStyles!);
    }
  }

  bool _shouldShowSelectionHandles() {
    return widget.configurations.showSelectionHandles &&
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
    widget.configurations.focusNode.removeListener(_handleFocusChanged);
    _cursorCont.dispose();
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

  /// Marks the editor as dirty and trigger a rebuild.
  ///
  /// When the editor is dirty methods that depend on the editor
  /// state being in sync with the controller know they may be
  /// operating on stale data.
  void _markNeedsBuild() {
    if (_dirty) {
      // No need to rebuilt if it already darty
      return;
    }
    setState(() {
      _dirty = true;
    });
  }

  void _didChangeTextEditingValue([bool ignoreFocus = false]) {
    if (isWeb()) {
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
        selectionCtrls: widget.configurations.selectionCtrls,
        selectionDelegate: this,
        clipboardStatus: _clipboardStatus,
        contextMenuBuilder: widget.configurations.contextMenuBuilder == null
            ? null
            : (context) =>
                widget.configurations.contextMenuBuilder!(context, this),
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
    return widget.configurations
        .linkActionPickerDelegate(context, link, linkNode);
  }

  bool _showCaretOnScreenScheduled = false;

  // This is a workaround for checkbox tapping issue
  // https://github.com/singerdmx/flutter-quill/issues/619
  // We cannot treat {"list": "checked"} and {"list": "unchecked"} as
  // block of the same style
  // This causes controller.selection to go to offset 0
  bool _disableScrollControllerAnimateOnce = false;

  void _showCaretOnScreen() {
    if (!widget.configurations.showCursor || _showCaretOnScreenScheduled) {
      return;
    }

    _showCaretOnScreenScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.configurations.scrollable || _scrollController.hasClients) {
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
      // and that just by one simple change
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
      widget.configurations.focusNode.requestFocus();
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
    if (isWeb()) {
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

  @override
  bool get wantKeepAlive => widget.configurations.focusNode.hasFocus;

  @override
  AnimationController get floatingCursorResetController =>
      _floatingCursorResetController;

  late AnimationController _floatingCursorResetController;

  // --------------------------- Text Editing Actions --------------------------

  QuillEditorTextBoundary _characterBoundary(
      DirectionalTextEditingIntent intent) {
    final atomicTextBoundary = QuillEditorCharacterBoundary(textEditingValue);
    return QuillEditorCollapsedSelectionBoundary(
        atomicTextBoundary, intent.forward);
  }

  QuillEditorTextBoundary _nextWordBoundary(
      DirectionalTextEditingIntent intent) {
    final QuillEditorTextBoundary atomicTextBoundary;
    final QuillEditorTextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueforTextLayoutMetrics;
    atomicTextBoundary = QuillEditorCharacterBoundary(textEditingValue);
    // This isn't enough. Newline characters.
    boundary = QuillEditorExpandedTextBoundary(
        QuillEditorWhitespaceBoundary(textEditingValue),
        QuillEditorWordBoundary(renderEditor, textEditingValue));

    final mixedBoundary = intent.forward
        ? QuillEditorMixedBoundary(atomicTextBoundary, boundary)
        : QuillEditorMixedBoundary(boundary, atomicTextBoundary);
    // Use a _MixedBoundary to make sure we don't leave invalid codepoints in
    // the field after deletion.
    return QuillEditorCollapsedSelectionBoundary(mixedBoundary, intent.forward);
  }

  QuillEditorTextBoundary _linebreak(DirectionalTextEditingIntent intent) {
    final QuillEditorTextBoundary atomicTextBoundary;
    final QuillEditorTextBoundary boundary;

    // final TextEditingValue textEditingValue =
    //     _textEditingValueforTextLayoutMetrics;
    atomicTextBoundary = QuillEditorCharacterBoundary(textEditingValue);
    boundary = QuillEditorLineBreak(renderEditor, textEditingValue);

    // The _MixedBoundary is to make sure we don't leave invalid code units in
    // the field after deletion.
    // `boundary` doesn't need to be wrapped in a _CollapsedSelectionBoundary,
    // since the document boundary is unique and the linebreak boundary is
    // already caret-location based.
    return intent.forward
        ? QuillEditorMixedBoundary(
            QuillEditorCollapsedSelectionBoundary(atomicTextBoundary, true),
            boundary)
        : QuillEditorMixedBoundary(
            boundary,
            QuillEditorCollapsedSelectionBoundary(atomicTextBoundary, false),
          );
  }

  QuillEditorTextBoundary _documentBoundary(
          DirectionalTextEditingIntent intent) =>
      QuillEditorDocumentBoundary(textEditingValue);

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

  late final QuillEditorUpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent> _adjacentLineAction =
      QuillEditorUpdateTextSelectionToAdjacentLineAction<
          ExtendSelectionVerticallyToAdjacentLineIntent>(this);

  late final QuillEditorToggleTextStyleAction _formatSelectionAction =
      QuillEditorToggleTextStyleAction(this);

  late final QuillEditorIndentSelectionAction _indentSelectionAction =
      QuillEditorIndentSelectionAction(this);

  late final QuillEditorOpenSearchAction _openSearchAction =
      QuillEditorOpenSearchAction(this);
  late final QuillEditorApplyHeaderAction _applyHeaderAction =
      QuillEditorApplyHeaderAction(this);
  late final QuillEditorApplyCheckListAction _applyCheckListAction =
      QuillEditorApplyCheckListAction(this);

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    DoNothingAndStopPropagationTextIntent: DoNothingAction(consumesKey: false),
    ReplaceTextIntent: _replaceTextAction,
    UpdateSelectionIntent: _updateSelectionAction,
    DirectionalFocusIntent: DirectionalFocusAction.forTextField(),

    // Delete
    DeleteCharacterIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteCharacterIntent>(
            this, _characterBoundary)),
    DeleteToNextWordBoundaryIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteToNextWordBoundaryIntent>(
            this, _nextWordBoundary)),
    DeleteToLineBreakIntent: _makeOverridable(
        QuillEditorDeleteTextAction<DeleteToLineBreakIntent>(this, _linebreak)),

    // Extend/Move Selection
    ExtendSelectionByCharacterIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<ExtendSelectionByCharacterIntent>(
      this,
      false,
      _characterBoundary,
    )),
    ExtendSelectionToNextWordBoundaryIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<
                ExtendSelectionToNextWordBoundaryIntent>(
            this, true, _nextWordBoundary)),
    ExtendSelectionToLineBreakIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<ExtendSelectionToLineBreakIntent>(
            this, true, _linebreak)),
    ExtendSelectionVerticallyToAdjacentLineIntent:
        _makeOverridable(_adjacentLineAction),
    ExtendSelectionToDocumentBoundaryIntent: _makeOverridable(
        QuillEditorUpdateTextSelectionAction<
                ExtendSelectionToDocumentBoundaryIntent>(
            this, true, _documentBoundary)),
    ExtendSelectionToNextWordBoundaryOrCaretLocationIntent: _makeOverridable(
        QuillEditorExtendSelectionOrCaretPositionAction(
            this, _nextWordBoundary)),

    // Copy Paste
    SelectAllTextIntent: _makeOverridable(QuillEditorSelectAllAction(this)),
    CopySelectionTextIntent:
        _makeOverridable(QuillEditorCopySelectionAction(this)),
    PasteTextIntent: _makeOverridable(CallbackAction<PasteTextIntent>(
        onInvoke: (intent) => pasteText(intent.cause))),

    HideSelectionToolbarIntent:
        _makeOverridable(QuillEditorHideSelectionToolbarAction(this)),
    UndoTextIntent: _makeOverridable(QuillEditorUndoKeyboardAction(this)),
    RedoTextIntent: _makeOverridable(QuillEditorRedoKeyboardAction(this)),

    OpenSearchIntent: _openSearchAction,

    // Selection Formatting
    ToggleTextStyleIntent: _formatSelectionAction,
    IndentSelectionIntent: _indentSelectionAction,
    QuillEditorApplyHeaderIntent: _applyHeaderAction,
    QuillEditorApplyCheckListIntent: _applyCheckListAction,
    QuillEditorApplyLinkIntent: QuillEditorApplyLinkAction(this)
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
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {
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

  // TODO: Review those

  @override
  bool get liveTextInputEnabled => false;

  @override
  bool get lookUpEnabled => false;

  @override
  bool get searchWebEnabled => false;

  @override
  bool get shareEnabled => false;
}
