import 'dart:math' as math;

// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';

import '../models/documents/document.dart';
import '../models/documents/nodes/container.dart' as container_node;
import '../models/documents/nodes/leaf.dart';
import '../models/structs/offset_value.dart';
import '../models/themes/quill_dialog_theme.dart';
import '../utils/platform.dart';
import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';
import 'embeds.dart';
import 'float_cursor.dart';
import 'link.dart';
import 'raw_editor.dart';
import 'text_selection.dart';

/// Base interface for the editor state which defines contract used by
/// various mixins.
abstract class EditorState extends State<RawEditor>
    implements TextSelectionDelegate {
  ScrollController get scrollController;

  RenderEditor get renderEditor;

  EditorTextSelectionOverlay? get selectionOverlay;

  List<OffsetValue> get pasteStyleAndEmbed;

  String get pastePlainText;

  /// Controls the floating cursor animation when it is released.
  /// The floating cursor is animated to merge with the regular cursor.
  AnimationController get floatingCursorResetController;

  /// Returns true if the editor has been marked as needing to be rebuilt.
  bool get dirty;

  bool showToolbar();

  void requestKeyboard();
}

/// Base interface for editable render objects.
abstract class RenderAbstractEditor implements TextLayoutMetrics {
  TextSelection selectWordAtPosition(TextPosition position);

  TextSelection selectLineAtPosition(TextPosition position);

  /// Returns preferred line height at specified `position` in text.
  double preferredLineHeight(TextPosition position);

  /// Returns [Rect] for caret in local coordinates
  ///
  /// Useful to enforce visibility of full caret at given position
  Rect getLocalRectForCaret(TextPosition position);

  /// Returns the local coordinates of the endpoints of the given selection.
  ///
  /// If the selection is collapsed (and therefore occupies a single point), the
  /// returned list is of length one. Otherwise, the selection is not collapsed
  /// and the returned list is of length two. In this case, however, the two
  /// points might actually be co-located (e.g., because of a bidirectional
  /// selection that contains some text but whose ends meet in the middle).
  TextPosition getPositionForOffset(Offset offset);

  /// Returns the local coordinates of the endpoints of the given selection.
  ///
  /// If the selection is collapsed (and therefore occupies a single point), the
  /// returned list is of length one. Otherwise, the selection is not collapsed
  /// and the returned list is of length two. In this case, however, the two
  /// points might actually be co-located (e.g., because of a bidirectional
  /// selection that contains some text but whose ends meet in the middle).
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection);

  /// Sets the screen position of the floating cursor and the text position
  /// closest to the cursor.
  /// `resetLerpValue` drives the size of the floating cursor.
  /// See [EditorState.floatingCursorResetController].
  void setFloatingCursor(FloatingCursorDragState dragState,
      Offset lastBoundedOffset, TextPosition lastTextPosition,
      {double? resetLerpValue});

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [TapGestureRecognizer.onTapDown]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to tap
  /// down events by calling this method.
  void handleTapDown(TapDownDetails details);

  /// Selects the set words of a paragraph in a given range of global positions.
  ///
  /// The first and last endpoints of the selection will always be at the
  /// beginning and end of a word respectively.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWordsInRange(
    Offset from,
    Offset to,
    SelectionChangedCause cause,
  );

  /// Move the selection to the beginning or end of a word.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWordEdge(SelectionChangedCause cause);

  ///
  /// Returns the new selection. Note that the returned value may not be
  /// yet reflected in the latest widget state.
  ///
  /// Returns null if no change occurred.
  TextSelection? selectPositionAt(
      {required Offset from, required SelectionChangedCause cause, Offset? to});

  /// Select a word around the location of the last tap down.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWord(SelectionChangedCause cause);

  /// Move selection to the location of the last tap down.
  ///
  /// {@template flutter.rendering.editable.select}
  /// This method is mainly used to translate user inputs in global positions
  /// into a [TextSelection]. When used in conjunction with a [EditableText],
  /// the selection change is fed back into [TextEditingController.selection].
  ///
  /// If you have a [TextEditingController], it's generally easier to
  /// programmatically manipulate its `value` or `selection` directly.
  /// {@endtemplate}
  void selectPosition({required SelectionChangedCause cause});
}

class QuillEditor extends StatefulWidget {
  const QuillEditor({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.scrollable,
    required this.padding,
    required this.autoFocus,
    required this.readOnly,
    required this.expands,
    this.showCursor,
    this.paintCursorAboveText,
    this.placeholder,
    this.enableInteractiveSelection = true,
    this.enableSelectionToolbar = true,
    this.scrollBottomInset = 0,
    this.minHeight,
    this.maxHeight,
    this.maxContentWidth,
    this.customStyles,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardAppearance = Brightness.light,
    this.scrollPhysics,
    this.onLaunchUrl,
    this.onTapDown,
    this.onTapUp,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.embedBuilders,
    this.unknownEmbedBuilder,
    this.linkActionPickerDelegate = defaultLinkActionPickerDelegate,
    this.customStyleBuilder,
    this.customRecognizerBuilder,
    this.locale,
    this.floatingCursorDisabled = false,
    this.textSelectionControls,
    this.onImagePaste,
    this.customShortcuts,
    this.customActions,
    this.detectWordBoundary = true,
    this.enableUnfocusOnTapOutside = true,
    this.customLinkPrefixes = const <String>[],
    this.dialogTheme,
    this.contentInsertionConfiguration,
    this.contextMenuBuilder,
    Key? key,
  }) : super(key: key);

  factory QuillEditor.basic({
    required QuillController controller,
    required bool readOnly,
    Brightness? keyboardAppearance,
    Iterable<EmbedBuilder>? embedBuilders,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool autoFocus = true,
    bool expands = false,
    FocusNode? focusNode,
    String? placeholder,

    /// The locale to use for the editor toolbar, defaults to system locale
    /// More at https://github.com/singerdmx/flutter-quill#translation
    Locale? locale,
  }) {
    return QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: focusNode ?? FocusNode(),
      autoFocus: autoFocus,
      readOnly: readOnly,
      expands: expands,
      padding: padding,
      keyboardAppearance: keyboardAppearance ?? Brightness.light,
      locale: locale,
      embedBuilders: embedBuilders,
      placeholder: placeholder,
    );
  }

  /// Controller object which establishes a link between a rich text document
  /// and this editor.
  ///
  /// Must not be null.
  final QuillController controller;

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;

  /// The [ScrollController] to use when vertically scrolling the contents.
  final ScrollController scrollController;

  /// Whether this editor should create a scrollable container for its content.
  ///
  /// When set to `true` the editor's height can be controlled by [minHeight],
  /// [maxHeight] and [expands] properties.
  ///
  /// When set to `false` the editor always expands to fit the entire content
  /// of the document and should normally be placed as a child of another
  /// scrollable widget, otherwise the content may be clipped.
  final bool scrollable;
  final double scrollBottomInset;

  /// Additional space around the content of this editor.
  final EdgeInsetsGeometry padding;

  /// Whether this editor should focus itself if nothing else is already
  /// focused.
  ///
  /// If true, the keyboard will open as soon as this editor obtains focus.
  /// Otherwise, the keyboard is only shown after the user taps the editor.
  ///
  /// Defaults to `false`. Cannot be `null`.
  final bool autoFocus;

  /// Whether focus should be revoked on tap outside the editor.
  final bool enableUnfocusOnTapOutside;

  /// Whether to show cursor.
  ///
  /// The cursor refers to the blinking caret when the editor is focused.
  final bool? showCursor;
  final bool? paintCursorAboveText;

  /// Whether the text can be changed.
  ///
  /// When this is set to `true`, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to `false`. Must not be `null`.
  final bool readOnly;
  final String? placeholder;

  /// Whether to enable user interface affordances for changing the
  /// text selection.
  ///
  /// For example, setting this to true will enable features such as
  /// long-pressing the editor to select text and show the
  /// cut/copy/paste menu, and tapping to move the text cursor.
  ///
  /// When this is false, the text selection cannot be adjusted by
  /// the user, text cannot be copied, and the user cannot paste into
  /// the text field from the clipboard.
  ///
  /// To disable just the selection toolbar, set enableSelectionToolbar
  /// to false.
  final bool enableInteractiveSelection;

  /// Whether to show the cut/copy/paste menu when selecting text.
  final bool enableSelectionToolbar;

  /// The minimum height to be occupied by this editor.
  ///
  /// This only has effect if [scrollable] is set to `true` and [expands] is
  /// set to `false`.
  final double? minHeight;

  /// The maximum height to be occupied by this editor.
  ///
  /// This only has effect if [scrollable] is set to `true` and [expands] is
  /// set to `false`.
  final double? maxHeight;

  /// The maximum width to be occupied by the content of this editor.
  ///
  /// If this is not null and and this editor's width is larger than this value
  /// then the contents will be constrained to the provided maximum width and
  /// horizontally centered. This is mostly useful on devices with wide screens.
  final double? maxContentWidth;

  /// Allows to override [DefaultStyles].
  final DefaultStyles? customStyles;

  /// Whether this editor's height will be sized to fill its parent.
  ///
  /// This only has effect if [scrollable] is set to `true`.
  ///
  /// If expands is set to true and wrapped in a parent widget like [Expanded]
  /// or [SizedBox], the editor will expand to fill the parent.
  ///
  /// [maxHeight] and [minHeight] must both be `null` when this is set to
  /// `true`.
  ///
  /// Defaults to `false`.
  final bool expands;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  ///
  /// Only supports text keyboards, other keyboard types will ignore this
  /// configuration. Capitalization is locale-aware.
  ///
  /// Defaults to [TextCapitalization.sentences]. Must not be `null`.
  final TextCapitalization textCapitalization;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

  /// The [ScrollPhysics] to use when vertically scrolling the input.
  ///
  /// This only has effect if [scrollable] is set to `true`.
  ///
  /// If not specified, it will behave according to the current platform.
  ///
  /// See [Scrollable.physics].
  final ScrollPhysics? scrollPhysics;

  /// Callback to invoke when user wants to launch a URL.
  final ValueChanged<String>? onLaunchUrl;

  // Returns whether gesture is handled
  final bool Function(
      TapDownDetails details, TextPosition Function(Offset offset))? onTapDown;

  // Returns whether gesture is handled
  final bool Function(
      TapUpDetails details, TextPosition Function(Offset offset))? onTapUp;

  // Returns whether gesture is handled
  final bool Function(
          LongPressStartDetails details, TextPosition Function(Offset offset))?
      onSingleLongTapStart;

  // Returns whether gesture is handled
  final bool Function(LongPressMoveUpdateDetails details,
      TextPosition Function(Offset offset))? onSingleLongTapMoveUpdate;

  // Returns whether gesture is handled
  final bool Function(
          LongPressEndDetails details, TextPosition Function(Offset offset))?
      onSingleLongTapEnd;

  final Iterable<EmbedBuilder>? embedBuilders;
  final EmbedBuilder? unknownEmbedBuilder;
  final CustomStyleBuilder? customStyleBuilder;
  final CustomRecognizerBuilder? customRecognizerBuilder;

  /// The locale to use for the editor toolbar, defaults to system locale
  /// More https://github.com/singerdmx/flutter-quill#translation
  final Locale? locale;

  /// Delegate function responsible for showing menu with link actions on
  /// mobile platforms (iOS, Android).
  ///
  /// The menu is triggered in editing mode ([readOnly] is set to `false`)
  /// when the user long-presses a link-styled text segment.
  ///
  /// FlutterQuill provides default implementation which can be overridden by
  /// this field to customize the user experience.
  ///
  /// By default on iOS the menu is displayed with [showCupertinoModalPopup]
  /// which constructs an instance of [CupertinoActionSheet]. For Android,
  /// the menu is displayed with [showModalBottomSheet] and a list of
  /// Material [ListTile]s.
  final LinkActionPickerDelegate linkActionPickerDelegate;

  final bool floatingCursorDisabled;

  /// allows to create a custom textSelectionControls,
  /// if this is null a default textSelectionControls based on the app's theme
  /// will be used
  final TextSelectionControls? textSelectionControls;

  /// Callback when the user pastes the given image.
  ///
  /// Returns the url of the image if the image should be inserted.
  final Future<String?> Function(Uint8List imageBytes)? onImagePaste;

  /// Contains user-defined shortcuts map.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#shortcuts]
  final Map<ShortcutActivator, Intent>? customShortcuts;

  /// Contains user-defined actions.
  ///
  /// [https://docs.flutter.dev/development/ui/advanced/actions-and-shortcuts#actions]
  final Map<Type, Action<Intent>>? customActions;

  final bool detectWordBoundary;

  /// Additional list if links prefixes, which must not be prepended
  /// with "https://" when [LinkMenuAction.launch] happened
  ///
  /// Useful for deeplinks
  final List<String> customLinkPrefixes;

  /// Configures the dialog theme.
  final QuillDialogTheme? dialogTheme;

  // Allows for creating a custom context menu
  final QuillEditorContextMenuBuilder? contextMenuBuilder;

  /// Configuration of handler for media content inserted via the system input
  /// method.
  ///
  /// See [https://api.flutter.dev/flutter/widgets/EditableText/contentInsertionConfiguration.html]
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  @override
  QuillEditorState createState() => QuillEditorState();
}

class QuillEditorState extends State<QuillEditor>
    implements EditorTextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  late EditorTextSelectionGestureDetectorBuilder
      _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _QuillEditorSelectionGestureDetectorBuilder(
            this, widget.detectWordBoundary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectionTheme = TextSelectionTheme.of(context);

    TextSelectionControls textSelectionControls;
    bool paintCursorAboveText;
    bool cursorOpacityAnimates;
    Offset? cursorOffset;
    Color? cursorColor;
    Color selectionColor;
    Radius? cursorRadius;

    if (isAppleOS(theme.platform)) {
      final cupertinoTheme = CupertinoTheme.of(context);
      textSelectionControls = cupertinoTextSelectionControls;
      paintCursorAboveText = true;
      cursorOpacityAnimates = true;
      cursorColor ??= selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
      selectionColor = selectionTheme.selectionColor ??
          cupertinoTheme.primaryColor.withOpacity(0.40);
      cursorRadius ??= const Radius.circular(2);
      cursorOffset = Offset(
          iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
    } else {
      textSelectionControls = materialTextSelectionControls;
      paintCursorAboveText = false;
      cursorOpacityAnimates = false;
      cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
      selectionColor = selectionTheme.selectionColor ??
          theme.colorScheme.primary.withOpacity(0.40);
    }

    final showSelectionToolbar =
        widget.enableInteractiveSelection && widget.enableSelectionToolbar;

    final child = RawEditor(
      key: _editorKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      scrollController: widget.scrollController,
      scrollable: widget.scrollable,
      scrollBottomInset: widget.scrollBottomInset,
      padding: widget.padding,
      readOnly: widget.readOnly,
      placeholder: widget.placeholder,
      onLaunchUrl: widget.onLaunchUrl,
      contextMenuBuilder: showSelectionToolbar
          ? (widget.contextMenuBuilder ?? RawEditor.defaultContextMenuBuilder)
          : null,
      showSelectionHandles: isMobile(theme.platform),
      showCursor: widget.showCursor,
      cursorStyle: CursorStyle(
        color: cursorColor,
        backgroundColor: Colors.grey,
        width: 2,
        radius: cursorRadius,
        offset: cursorOffset,
        paintAboveText: widget.paintCursorAboveText ?? paintCursorAboveText,
        opacityAnimates: cursorOpacityAnimates,
      ),
      textCapitalization: widget.textCapitalization,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      maxContentWidth: widget.maxContentWidth,
      customStyles: widget.customStyles,
      expands: widget.expands,
      autoFocus: widget.autoFocus,
      selectionColor: selectionColor,
      selectionCtrls: widget.textSelectionControls ?? textSelectionControls,
      keyboardAppearance: widget.keyboardAppearance,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      scrollPhysics: widget.scrollPhysics,
      embedBuilder: _getEmbedBuilder,
      linkActionPickerDelegate: widget.linkActionPickerDelegate,
      customStyleBuilder: widget.customStyleBuilder,
      customRecognizerBuilder: widget.customRecognizerBuilder,
      floatingCursorDisabled: widget.floatingCursorDisabled,
      onImagePaste: widget.onImagePaste,
      customShortcuts: widget.customShortcuts,
      customActions: widget.customActions,
      customLinkPrefixes: widget.customLinkPrefixes,
      enableUnfocusOnTapOutside: widget.enableUnfocusOnTapOutside,
      dialogTheme: widget.dialogTheme,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
    );

    final editor = I18n(
      initialLocale: widget.locale,
      child: selectionEnabled
          ? _selectionGestureDetectorBuilder.build(
              behavior: HitTestBehavior.translucent,
              detectWordBoundary: widget.detectWordBoundary,
              child: child,
            )
          : child,
    );

    if (kIsWeb) {
      // Intercept RawKeyEvent on Web to prevent it from propagating to parents
      // that might interfere with the editor key behavior, such as
      // SingleChildScrollView. Thanks to @wliumelb for the workaround.
      // See issue https://github.com/singerdmx/flutter-quill/issues/304
      return RawKeyboardListener(
        onKey: (_) {},
        focusNode: FocusNode(
          onKey: (node, event) => KeyEventResult.skipRemainingHandlers,
        ),
        child: editor,
      );
    }

    return editor;
  }

  EmbedBuilder _getEmbedBuilder(Embed node) {
    final builders = widget.embedBuilders;

    if (builders != null) {
      for (final builder in builders) {
        if (builder.key == node.value.type) {
          return builder;
        }
      }
    }

    if (widget.unknownEmbedBuilder != null) {
      return widget.unknownEmbedBuilder!;
    }

    throw UnimplementedError(
      'Embeddable type "${node.value.type}" is not supported by supplied '
      'embed builders. You must pass your own builder function to '
      'embedBuilders property of QuillEditor or QuillField widgets or '
      'specify an unknownEmbedBuilder.',
    );
  }

  @override
  GlobalKey<EditorState> get editableTextKey => _editorKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enableInteractiveSelection;

  void _requestKeyboard() {
    _editorKey.currentState!.requestKeyboard();
  }
}

class _QuillEditorSelectionGestureDetectorBuilder
    extends EditorTextSelectionGestureDetectorBuilder {
  _QuillEditorSelectionGestureDetectorBuilder(
      this._state, this._detectWordBoundary)
      : super(delegate: _state, detectWordBoundary: _detectWordBoundary);

  final QuillEditorState _state;
  final bool _detectWordBoundary;

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.selectionEnabled && shouldShowSelectionToolbar) {
      editor!.showToolbar();
    }
  }

  @override
  void onForcePressEnd(ForcePressDetails details) {}

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_state.widget.onSingleLongTapMoveUpdate != null) {
      if (renderEditor != null &&
          _state.widget.onSingleLongTapMoveUpdate!(
              details, renderEditor!.getPositionForOffset)) {
        return;
      }
    }
    if (!delegate.selectionEnabled) {
      return;
    }

    final _platform = Theme.of(_state.context).platform;
    if (isAppleOS(_platform)) {
      renderEditor!.selectPositionAt(
        from: details.globalPosition,
        cause: SelectionChangedCause.longPress,
      );
    } else {
      renderEditor!.selectWordsInRange(
        details.globalPosition - details.offsetFromOrigin,
        details.globalPosition,
        SelectionChangedCause.longPress,
      );
    }
  }

  bool _isPositionSelected(TapUpDetails details) {
    if (_state.widget.controller.document.isEmpty()) {
      return false;
    }
    final pos = renderEditor!.getPositionForOffset(details.globalPosition);
    final result =
        editor!.widget.controller.document.querySegmentLeafNode(pos.offset);
    final line = result.line;
    if (line == null) {
      return false;
    }
    final segmentLeaf = result.leaf;
    if (segmentLeaf == null && line.length == 1) {
      editor!.widget.controller.updateSelection(
          TextSelection.collapsed(offset: pos.offset), ChangeSource.LOCAL);
      return true;
    }
    return false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (_state.widget.onTapDown != null) {
      if (renderEditor != null &&
          _state.widget.onTapDown!(
              details, renderEditor!.getPositionForOffset)) {
        return;
      }
    }
    super.onTapDown(details);
  }

  bool isShiftClick(PointerDeviceKind deviceKind) {
    final pressed = RawKeyboard.instance.keysPressed;
    return deviceKind == PointerDeviceKind.mouse &&
        (pressed.contains(LogicalKeyboardKey.shiftLeft) ||
            pressed.contains(LogicalKeyboardKey.shiftRight));
  }

  @override
  void onSingleTapUp(TapUpDetails details) {
    if (_state.widget.onTapUp != null &&
        renderEditor != null &&
        _state.widget.onTapUp!(details, renderEditor!.getPositionForOffset)) {
      return;
    }

    editor!.hideToolbar();

    try {
      if (delegate.selectionEnabled && !_isPositionSelected(details)) {
        final _platform = Theme.of(_state.context).platform;
        if (isAppleOS(_platform) || isDesktop()) {
          // added isDesktop() to enable extend selection in Windows platform
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              // Precise devices should place the cursor at a precise position.
              // If `Shift` key is pressed then
              // extend current selection instead.
              if (isShiftClick(details.kind)) {
                renderEditor!
                  ..extendSelection(details.globalPosition,
                      cause: SelectionChangedCause.tap)
                  ..onSelectionCompleted();
              } else {
                renderEditor!
                  ..selectPosition(cause: SelectionChangedCause.tap)
                  ..onSelectionCompleted();
              }

              break;
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              // On macOS/iOS/iPadOS a touch tap places the cursor at the edge
              // of the word.
              if (_detectWordBoundary) {
                renderEditor!
                  ..selectWordEdge(SelectionChangedCause.tap)
                  ..onSelectionCompleted();
              } else {
                renderEditor!
                  ..selectPosition(cause: SelectionChangedCause.tap)
                  ..onSelectionCompleted();
              }
              break;
            case PointerDeviceKind.trackpad:
              // TODO: Handle this case.
              break;
          }
        } else {
          renderEditor!
            ..selectPosition(cause: SelectionChangedCause.tap)
            ..onSelectionCompleted();
        }
      }
    } finally {
      _state._requestKeyboard();
    }
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (_state.widget.onSingleLongTapStart != null) {
      if (renderEditor != null &&
          _state.widget.onSingleLongTapStart!(
              details, renderEditor!.getPositionForOffset)) {
        return;
      }
    }

    if (delegate.selectionEnabled) {
      final _platform = Theme.of(_state.context).platform;
      if (isAppleOS(_platform)) {
        renderEditor!.selectPositionAt(
          from: details.globalPosition,
          cause: SelectionChangedCause.longPress,
        );
      } else {
        renderEditor!.selectWord(SelectionChangedCause.longPress);
        Feedback.forLongPress(_state.context);
      }
    }
  }

  @override
  void onSingleLongTapEnd(LongPressEndDetails details) {
    if (_state.widget.onSingleLongTapEnd != null) {
      if (renderEditor != null) {
        if (_state.widget.onSingleLongTapEnd!(
            details, renderEditor!.getPositionForOffset)) {
          return;
        }

        if (delegate.selectionEnabled) {
          renderEditor!.onSelectionCompleted();
        }
      }
    }
    super.onSingleLongTapEnd(details);
  }
}

/// Signature for the callback that reports when the user changes the selection
/// (including the cursor location).
///
/// Used by [RenderEditor.onSelectionChanged].
typedef TextSelectionChangedHandler = void Function(
    TextSelection selection, SelectionChangedCause cause);

/// Signature for the callback that reports when a selection action is actually
/// completed and ratified. Completion is defined as when the user input has
/// concluded for an entire selection action. For simple taps and keyboard input
/// events that change the selection, this callback is invoked immediately
/// following the TextSelectionChangedHandler. For long taps, the selection is
/// considered complete at the up event of a long tap. For drag selections, the
/// selection completes once the drag/pan event ends or is interrupted.
///
/// Used by [RenderEditor.onSelectionCompleted].
typedef TextSelectionCompletedHandler = void Function();

// The padding applied to text field. Used to determine the bounds when
// moving the floating cursor.
const EdgeInsets _kFloatingCursorAddedMargin = EdgeInsets.fromLTRB(4, 4, 4, 5);

// The additional size on the x and y axis with which to expand the prototype
// cursor to render the floating cursor in pixels.
const EdgeInsets _kFloatingCaretSizeIncrease =
    EdgeInsets.symmetric(horizontal: 0.5, vertical: 1);

/// Displays a document as a vertical list of document segments (lines
/// and blocks).
///
/// Children of [RenderEditor] must be instances of [RenderEditableBox].
class RenderEditor extends RenderEditableContainerBox
    with RelayoutWhenSystemFontsChangeMixin
    implements RenderAbstractEditor {
  RenderEditor({
    required this.document,
    required TextDirection textDirection,
    required bool hasFocus,
    required this.selection,
    required this.scrollable,
    required LayerLink startHandleLayerLink,
    required LayerLink endHandleLayerLink,
    required EdgeInsetsGeometry padding,
    required CursorCont cursorController,
    required this.onSelectionChanged,
    required this.onSelectionCompleted,
    required double scrollBottomInset,
    required this.floatingCursorDisabled,
    ViewportOffset? offset,
    List<RenderEditableBox>? children,
    EdgeInsets floatingCursorAddedMargin =
        const EdgeInsets.fromLTRB(4, 4, 4, 5),
    double? maxContentWidth,
  })  : _hasFocus = hasFocus,
        _extendSelectionOrigin = selection,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink,
        _cursorController = cursorController,
        _maxContentWidth = maxContentWidth,
        super(
          children: children,
          container: document.root,
          textDirection: textDirection,
          scrollBottomInset: scrollBottomInset,
          padding: padding,
        );

  final CursorCont _cursorController;
  final bool floatingCursorDisabled;
  final bool scrollable;

  Document document;
  TextSelection selection;
  bool _hasFocus = false;
  LayerLink _startHandleLayerLink;
  LayerLink _endHandleLayerLink;

  /// Called when the selection changes.
  TextSelectionChangedHandler onSelectionChanged;
  TextSelectionCompletedHandler onSelectionCompleted;
  final ValueNotifier<bool> _selectionStartInViewport =
      ValueNotifier<bool>(true);

  ValueListenable<bool> get selectionStartInViewport =>
      _selectionStartInViewport;

  ValueListenable<bool> get selectionEndInViewport => _selectionEndInViewport;
  final ValueNotifier<bool> _selectionEndInViewport = ValueNotifier<bool>(true);

  void _updateSelectionExtentsVisibility(Offset effectiveOffset) {
    final visibleRegion = Offset.zero & size;
    final startPosition =
        TextPosition(offset: selection.start, affinity: selection.affinity);
    final startOffset = _getOffsetForCaret(startPosition);
    // TODO(justinmc): https://github.com/flutter/flutter/issues/31495
    // Check if the selection is visible with an approximation because a
    // difference between rounded and unrounded values causes the caret to be
    // reported as having a slightly (< 0.5) negative y offset. This rounding
    // happens in paragraph.cc's layout and TextPainer's
    // _applyFloatingPointHack. Ideally, the rounding mismatch will be fixed and
    // this can be changed to be a strict check instead of an approximation.
    const visibleRegionSlop = 0.5;
    _selectionStartInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(startOffset + effectiveOffset);

    final endPosition =
        TextPosition(offset: selection.end, affinity: selection.affinity);
    final endOffset = _getOffsetForCaret(endPosition);
    _selectionEndInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(endOffset + effectiveOffset);
  }

  // returns offset relative to this at which the caret will be painted
  // given a global TextPosition
  Offset _getOffsetForCaret(TextPosition position) {
    final child = childAtPosition(position);
    final childPosition = child.globalToLocalPosition(position);
    final boxParentData = child.parentData as BoxParentData;
    final localOffsetForCaret = child.getOffsetForCaret(childPosition);
    return boxParentData.offset + localOffsetForCaret;
  }

  void setDocument(Document doc) {
    if (document == doc) {
      return;
    }
    document = doc;
    markNeedsLayout();
  }

  void setHasFocus(bool h) {
    if (_hasFocus == h) {
      return;
    }
    _hasFocus = h;
    markNeedsSemanticsUpdate();
  }

  Offset get _paintOffset => Offset(0, -(offset?.pixels ?? 0.0));

  ViewportOffset? get offset => _offset;
  ViewportOffset? _offset;

  set offset(ViewportOffset? value) {
    if (_offset == value) return;
    if (attached) _offset?.removeListener(markNeedsPaint);
    _offset = value;
    if (attached) _offset?.addListener(markNeedsPaint);
    markNeedsLayout();
  }

  void setSelection(TextSelection t) {
    if (selection == t) {
      return;
    }
    selection = t;
    markNeedsPaint();

    if (!_shiftPressed && !_isDragging) {
      // Only update extend selection origin if Shift key is not pressed and
      // user is not dragging selection.
      _extendSelectionOrigin = selection;
    }
  }

  bool get _shiftPressed =>
      RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
      RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftRight);

  void setStartHandleLayerLink(LayerLink value) {
    if (_startHandleLayerLink == value) {
      return;
    }
    _startHandleLayerLink = value;
    markNeedsPaint();
  }

  void setEndHandleLayerLink(LayerLink value) {
    if (_endHandleLayerLink == value) {
      return;
    }
    _endHandleLayerLink = value;
    markNeedsPaint();
  }

  void setScrollBottomInset(double value) {
    if (scrollBottomInset == value) {
      return;
    }
    scrollBottomInset = value;
    markNeedsPaint();
  }

  double? _maxContentWidth;

  set maxContentWidth(double? value) {
    if (_maxContentWidth == value) return;
    _maxContentWidth = value;
    markNeedsLayout();
  }

  @override
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection) {
    if (textSelection.isCollapsed) {
      final child = childAtPosition(textSelection.extent);
      final localPosition = TextPosition(
        offset: textSelection.extentOffset - child.container.offset,
        affinity: textSelection.affinity,
      );
      final localOffset = child.getOffsetForCaret(localPosition);
      final parentData = child.parentData as BoxParentData;
      return <TextSelectionPoint>[
        TextSelectionPoint(
            Offset(0, child.preferredLineHeight(localPosition)) +
                localOffset +
                parentData.offset,
            null)
      ];
    }

    final baseNode = _container.queryChild(textSelection.start, false).node;

    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.container == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    final baseParentData = baseChild!.parentData as BoxParentData;
    final baseSelection =
        localSelection(baseChild.container, textSelection, true);
    var basePoint = baseChild.getBaseEndpointForSelection(baseSelection);
    basePoint = TextSelectionPoint(
        basePoint.point + baseParentData.offset, basePoint.direction);

    final extentNode = _container.queryChild(textSelection.end, false).node;
    RenderEditableBox? extentChild = baseChild;
    while (extentChild != null) {
      if (extentChild.container == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    final extentParentData = extentChild!.parentData as BoxParentData;
    final extentSelection =
        localSelection(extentChild.container, textSelection, true);
    var extentPoint =
        extentChild.getExtentEndpointForSelection(extentSelection);
    extentPoint = TextSelectionPoint(
        extentPoint.point + extentParentData.offset, extentPoint.direction);

    return <TextSelectionPoint>[basePoint, extentPoint];
  }

  Offset? _lastTapDownPosition;

  // Used on Desktop (mouse and keyboard enabled platforms) as base offset
  // for extending selection, either with combination of `Shift` + Click or
  // by dragging
  TextSelection? _extendSelectionOrigin;

  @override
  void handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  bool _isDragging = false;

  void handleDragStart(DragStartDetails details) {
    _isDragging = true;

    final newSelection = selectPositionAt(
      from: details.globalPosition,
      cause: SelectionChangedCause.drag,
    );

    if (newSelection == null) return;
    // Make sure to remember the origin for extend selection.
    _extendSelectionOrigin = newSelection;
  }

  void handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    onSelectionCompleted();
  }

  @override
  void selectWordsInRange(
    Offset from,
    Offset? to,
    SelectionChangedCause cause,
  ) {
    final firstPosition = getPositionForOffset(from);
    final firstWord = selectWordAtPosition(firstPosition);
    final lastWord =
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

  void _handleSelectionChange(
    TextSelection nextSelection,
    SelectionChangedCause cause,
  ) {
    final focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !_hasFocus;
    if (nextSelection == selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    onSelectionChanged(nextSelection, cause);
  }

  /// Extends current selection to the position closest to specified offset.
  void extendSelection(Offset to, {required SelectionChangedCause cause}) {
    /// The below logic does not exactly match the native version because
    /// we do not allow swapping of base and extent positions.
    assert(_extendSelectionOrigin != null);
    final position = getPositionForOffset(to);

    if (position.offset < _extendSelectionOrigin!.baseOffset) {
      _handleSelectionChange(
        TextSelection(
          baseOffset: position.offset,
          extentOffset: _extendSelectionOrigin!.extentOffset,
          affinity: selection.affinity,
        ),
        cause,
      );
    } else if (position.offset > _extendSelectionOrigin!.extentOffset) {
      _handleSelectionChange(
        TextSelection(
          baseOffset: _extendSelectionOrigin!.baseOffset,
          extentOffset: position.offset,
          affinity: selection.affinity,
        ),
        cause,
      );
    }
  }

  @override
  void selectWordEdge(SelectionChangedCause cause) {
    assert(_lastTapDownPosition != null);
    final position = getPositionForOffset(_lastTapDownPosition!);
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
      offset: position.offset - nodeOffset,
      affinity: position.affinity,
    );
    final localWord = child.getWordBoundary(localPosition);
    final word = TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
    if (position.offset - word.start <= 1 && word.end != position.offset) {
      _handleSelectionChange(
        TextSelection.collapsed(offset: word.start),
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
  TextSelection? selectPositionAt({
    required Offset from,
    required SelectionChangedCause cause,
    Offset? to,
  }) {
    final fromPosition = getPositionForOffset(from);
    final toPosition = to == null ? null : getPositionForOffset(to);

    var baseOffset = fromPosition.offset;
    var extentOffset = fromPosition.offset;
    if (toPosition != null) {
      baseOffset = math.min(fromPosition.offset, toPosition.offset);
      extentOffset = math.max(fromPosition.offset, toPosition.offset);
    }

    final newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );

    // Call [onSelectionChanged] only when the selection actually changed.
    _handleSelectionChange(newSelection, cause);
    return newSelection;
  }

  @override
  void selectWord(SelectionChangedCause cause) {
    selectWordsInRange(_lastTapDownPosition!, null, cause);
  }

  @override
  void selectPosition({required SelectionChangedCause cause}) {
    selectPositionAt(from: _lastTapDownPosition!, cause: cause);
  }

  @override
  TextSelection selectWordAtPosition(TextPosition position) {
    final word = getWordBoundary(position);
    // When long-pressing past the end of the text, we want a collapsed cursor.
    if (position.offset >= word.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  @override
  TextSelection selectLineAtPosition(TextPosition position) {
    final line = getLineAtOffset(position);

    // When long-pressing past the end of the text, we want a collapsed cursor.
    if (position.offset >= line.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  @override
  void performLayout() {
    assert(() {
      if (!scrollable || !constraints.hasBoundedHeight) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('RenderEditableContainerBox must have '
            'unlimited space along its main axis when it is scrollable.'),
        ErrorDescription('RenderEditableContainerBox does not clip or'
            ' resize its children, so it must be '
            'placed in a parent that does not constrain the main '
            'axis.'),
        ErrorHint(
            'You probably want to put the RenderEditableContainerBox inside a '
            'RenderViewport with a matching main axis or disable the '
            'scrollable property.')
      ]);
    }());
    assert(() {
      if (constraints.hasBoundedWidth) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('RenderEditableContainerBox must have a bounded'
            ' constraint for its cross axis.'),
        ErrorDescription('RenderEditableContainerBox forces its children to '
            "expand to fit the RenderEditableContainerBox's container, "
            'so it must be placed in a parent that constrains the cross '
            'axis to a finite dimension.'),
      ]);
    }());

    resolvePadding();
    assert(resolvedPadding != null);

    var mainAxisExtent = resolvedPadding!.top;
    var child = firstChild;
    final innerConstraints = BoxConstraints.tightFor(
            width: math.min(
                _maxContentWidth ?? double.infinity, constraints.maxWidth))
        .deflate(resolvedPadding!);
    final leftOffset = _maxContentWidth == null
        ? 0.0
        : math.max((constraints.maxWidth - _maxContentWidth!) / 2, 0);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = child.parentData as EditableContainerParentData
        ..offset = Offset(resolvedPadding!.left + leftOffset, mainAxisExtent);
      mainAxisExtent += child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += resolvedPadding!.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));

    assert(size.isFinite);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasFocus &&
        _cursorController.show.value &&
        !_cursorController.style.paintAboveText) {
      _paintFloatingCursor(context, offset);
    }
    defaultPaint(context, offset);
    _updateSelectionExtentsVisibility(offset + _paintOffset);
    _paintHandleLayers(context, getEndpointsForSelection(selection));

    if (_hasFocus &&
        _cursorController.show.value &&
        _cursorController.style.paintAboveText) {
      _paintFloatingCursor(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _paintHandleLayers(
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
    final child = childAtPosition(position);
    return child.preferredLineHeight(
        TextPosition(offset: position.offset - child.container.offset));
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    final local = globalToLocal(offset);
    final child = childAtOffset(local);

    final parentData = child.parentData as BoxParentData;
    final localOffset = local - parentData.offset;
    final localPosition = child.getPositionForOffset(localOffset);
    return TextPosition(
      offset: localPosition.offset + child.container.offset,
      affinity: localPosition.affinity,
    );
  }

  /// Returns the y-offset of the editor at which [selection] is visible.
  ///
  /// The offset is the distance from the top of the editor and is the minimum
  /// from the current scroll position until [selection] becomes visible.
  /// Returns null if [selection] is already visible.
  ///
  /// Finds the closest scroll offset that fully reveals the editing cursor.
  ///
  /// The `scrollOffset` parameter represents current scroll offset in the
  /// parent viewport.
  ///
  /// The `offsetInViewport` parameter represents the editor's vertical offset
  /// in the parent viewport. This value should normally be 0.0 if this editor
  /// is the only child of the viewport or if it's the topmost child. Otherwise
  /// it should be a positive value equal to total height of all siblings of
  /// this editor from above it.
  ///
  /// Returns `null` if the cursor is currently visible.
  double? getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport) {
    // Endpoints coordinates represents lower left or lower right corner of
    // the selection. If we want to scroll up to reveal the caret we need to
    // adjust the dy value by the height of the line. We also add a small margin
    // so that the caret is not too close to the edge of the viewport.
    final endpoints = getEndpointsForSelection(selection);

    // when we drag the right handle, we should get the last point
    TextSelectionPoint endpoint;
    if (selection.isCollapsed) {
      endpoint = endpoints.first;
    } else {
      if (selection is DragTextSelection) {
        endpoint = (selection as DragTextSelection).first
            ? endpoints.first
            : endpoints.last;
      } else {
        endpoint = endpoints.first;
      }
    }

    // Collapsed selection => caret
    final child = childAtPosition(selection.extent);
    const kMargin = 8.0;

    final caretTop = endpoint.point.dy -
        child.preferredLineHeight(TextPosition(
            offset: selection.extentOffset - child.container.documentOffset)) -
        kMargin +
        offsetInViewport +
        scrollBottomInset;
    final caretBottom =
        endpoint.point.dy + kMargin + offsetInViewport + scrollBottomInset;
    double? dy;
    if (caretTop < scrollOffset) {
      dy = caretTop;
    } else if (caretBottom > scrollOffset + viewportHeight) {
      dy = caretBottom - viewportHeight;
    }
    if (dy == null) {
      return null;
    }
    // Clamping to 0.0 so that the content does not jump unnecessarily.
    return math.max(dy, 0);
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    final targetChild = childAtPosition(position);
    final localPosition = targetChild.globalToLocalPosition(position);

    final childLocalRect = targetChild.getLocalRectForCaret(localPosition);

    final boxParentData = targetChild.parentData as BoxParentData;
    return childLocalRect.shift(Offset(0, boxParentData.offset.dy));
  }

  // Start floating cursor

  FloatingCursorPainter get _floatingCursorPainter => FloatingCursorPainter(
        floatingCursorRect: _floatingCursorRect,
        style: _cursorController.style,
      );

  bool _floatingCursorOn = false;
  Rect? _floatingCursorRect;

  TextPosition get floatingCursorTextPosition => _floatingCursorTextPosition;
  late TextPosition _floatingCursorTextPosition;

  // The relative origin in relation to the distance the user has theoretically
  // dragged the floating cursor offscreen.
  // This value is used to account for the difference
  // in the rendering position and the raw offset value.
  Offset _relativeOrigin = Offset.zero;
  Offset? _previousOffset;
  bool _resetOriginOnLeft = false;
  bool _resetOriginOnRight = false;
  bool _resetOriginOnTop = false;
  bool _resetOriginOnBottom = false;

  /// Returns the position within the editor closest to the raw cursor offset.
  Offset calculateBoundedFloatingCursorOffset(
      Offset rawCursorOffset, double preferredLineHeight) {
    var deltaPosition = Offset.zero;
    final topBound = _kFloatingCursorAddedMargin.top;
    final bottomBound =
        size.height - preferredLineHeight + _kFloatingCursorAddedMargin.bottom;
    final leftBound = _kFloatingCursorAddedMargin.left;
    final rightBound = size.width - _kFloatingCursorAddedMargin.right;

    if (_previousOffset != null) {
      deltaPosition = rawCursorOffset - _previousOffset!;
    }

    // If the raw cursor offset has gone off an edge,
    // we want to reset the relative origin of
    // the dragging when the user drags back into the field.
    if (_resetOriginOnLeft && deltaPosition.dx > 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - leftBound, _relativeOrigin.dy);
      _resetOriginOnLeft = false;
    } else if (_resetOriginOnRight && deltaPosition.dx < 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - rightBound, _relativeOrigin.dy);
      _resetOriginOnRight = false;
    }
    if (_resetOriginOnTop && deltaPosition.dy > 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - topBound);
      _resetOriginOnTop = false;
    } else if (_resetOriginOnBottom && deltaPosition.dy < 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - bottomBound);
      _resetOriginOnBottom = false;
    }

    final currentX = rawCursorOffset.dx - _relativeOrigin.dx;
    final currentY = rawCursorOffset.dy - _relativeOrigin.dy;
    final double adjustedX =
        math.min(math.max(currentX, leftBound), rightBound);
    final double adjustedY =
        math.min(math.max(currentY, topBound), bottomBound);
    final adjustedOffset = Offset(adjustedX, adjustedY);

    if (currentX < leftBound && deltaPosition.dx < 0) {
      _resetOriginOnLeft = true;
    } else if (currentX > rightBound && deltaPosition.dx > 0) {
      _resetOriginOnRight = true;
    }
    if (currentY < topBound && deltaPosition.dy < 0) {
      _resetOriginOnTop = true;
    } else if (currentY > bottomBound && deltaPosition.dy > 0) {
      _resetOriginOnBottom = true;
    }

    _previousOffset = rawCursorOffset;

    return adjustedOffset;
  }

  @override
  void setFloatingCursor(FloatingCursorDragState dragState,
      Offset boundedOffset, TextPosition textPosition,
      {double? resetLerpValue}) {
    if (floatingCursorDisabled) return;

    if (dragState == FloatingCursorDragState.Start) {
      _relativeOrigin = Offset.zero;
      _previousOffset = null;
      _resetOriginOnBottom = false;
      _resetOriginOnTop = false;
      _resetOriginOnRight = false;
      _resetOriginOnBottom = false;
    }
    _floatingCursorOn = dragState != FloatingCursorDragState.End;
    if (_floatingCursorOn) {
      _floatingCursorTextPosition = textPosition;
      final sizeAdjustment = resetLerpValue != null
          ? EdgeInsets.lerp(
              _kFloatingCaretSizeIncrease, EdgeInsets.zero, resetLerpValue)!
          : _kFloatingCaretSizeIncrease;
      final child = childAtPosition(textPosition);
      final caretPrototype =
          child.getCaretPrototype(child.globalToLocalPosition(textPosition));
      _floatingCursorRect =
          sizeAdjustment.inflateRect(caretPrototype).shift(boundedOffset);
      _cursorController
          .setFloatingCursorTextPosition(_floatingCursorTextPosition);
    } else {
      _floatingCursorRect = null;
      _cursorController.setFloatingCursorTextPosition(null);
    }
  }

  void _paintFloatingCursor(PaintingContext context, Offset offset) {
    _floatingCursorPainter.paint(context.canvas);
  }

  // End floating cursor

  // Start TextLayoutMetrics implementation

  /// Return a [TextSelection] containing the line of the given [TextPosition].
  @override
  TextSelection getLineAtOffset(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localLineRange = child.getLineBoundary(localPosition);
    final line = TextRange(
      start: localLineRange.start + nodeOffset,
      end: localLineRange.end + nodeOffset,
    );
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localWord = child.getWordBoundary(localPosition);
    return TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
  }

  /// Returns the TextPosition above the given offset into the text.
  ///
  /// If the offset is already on the first line, the offset of the first
  /// character will be returned.
  @override
  TextPosition getTextPositionAbove(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition =
        TextPosition(offset: position.offset - child.container.documentOffset);

    var newPosition = child.getPositionAbove(localPosition);

    if (newPosition == null) {
      // There was no text above in the current child, check the direct
      // sibling.
      final sibling = childBefore(child);
      if (sibling == null) {
        // reached beginning of the document, move to the
        // first character
        newPosition = const TextPosition(offset: 0);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        final testPosition = TextPosition(offset: sibling.container.length - 1);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
            offset: sibling.container.documentOffset + siblingPosition.offset);
      }
    } else {
      newPosition = TextPosition(
          offset: child.container.documentOffset + newPosition.offset);
    }
    return newPosition;
  }

  /// Returns the TextPosition below the given offset into the text.
  ///
  /// If the offset is already on the last line, the offset of the last
  /// character will be returned.
  @override
  TextPosition getTextPositionBelow(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition =
        TextPosition(offset: position.offset - child.container.documentOffset);

    var newPosition = child.getPositionBelow(localPosition);

    if (newPosition == null) {
      // There was no text above in the current child, check the direct
      // sibling.
      final sibling = childAfter(child);
      if (sibling == null) {
        // reached beginning of the document, move to the
        // last character
        newPosition = TextPosition(offset: document.length - 1);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        const testPosition = TextPosition(offset: 0);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
            offset: sibling.container.documentOffset + siblingPosition.offset);
      }
    } else {
      newPosition = TextPosition(
          offset: child.container.documentOffset + newPosition.offset);
    }
    return newPosition;
  }

  // End TextLayoutMetrics implementation

  QuillVerticalCaretMovementRun startVerticalCaretMovement(
      TextPosition startPosition) {
    return QuillVerticalCaretMovementRun._(
      this,
      startPosition,
    );
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    markNeedsLayout();
  }
}

class QuillVerticalCaretMovementRun extends Iterator<TextPosition> {
  QuillVerticalCaretMovementRun._(
    this._editor,
    this._currentTextPosition,
  );

  TextPosition _currentTextPosition;

  final RenderEditor _editor;

  @override
  TextPosition get current {
    return _currentTextPosition;
  }

  @override
  bool moveNext() {
    _currentTextPosition = _editor.getTextPositionBelow(_currentTextPosition);
    return true;
  }

  bool movePrevious() {
    _currentTextPosition = _editor.getTextPositionAbove(_currentTextPosition);
    return true;
  }
}

class EditableContainerParentData
    extends ContainerBoxParentData<RenderEditableBox> {}

/// Multi-child render box of editable content.
///
/// Common ancestor for [RenderEditor] and [RenderEditableTextBlock].
class RenderEditableContainerBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderEditableBox,
            EditableContainerParentData>,
        RenderBoxContainerDefaultsMixin<RenderEditableBox,
            EditableContainerParentData> {
  RenderEditableContainerBox(
      {required container_node.Container container,
      required this.textDirection,
      required this.scrollBottomInset,
      required EdgeInsetsGeometry padding,
      List<RenderEditableBox>? children})
      : assert(padding.isNonNegative),
        _container = container,
        _padding = padding {
    addAll(children);
  }

  container_node.Container _container;
  TextDirection textDirection;
  EdgeInsetsGeometry _padding;
  double scrollBottomInset;
  EdgeInsets? _resolvedPadding;

  container_node.Container get container => _container;

  void setContainer(container_node.Container c) {
    if (_container == c) {
      return;
    }
    _container = c;
    markNeedsLayout();
  }

  EdgeInsetsGeometry getPadding() => _padding;

  void setPadding(EdgeInsetsGeometry value) {
    assert(value.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    _markNeedsPaddingResolution();
  }

  EdgeInsets? get resolvedPadding => _resolvedPadding;

  void resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = _padding.resolve(textDirection);
    _resolvedPadding = _resolvedPadding!.copyWith(left: _resolvedPadding!.left);

    assert(_resolvedPadding!.isNonNegative);
  }

  RenderEditableBox childAtPosition(TextPosition position) {
    assert(firstChild != null);

    final targetNode = container.queryChild(position.offset, false).node;

    var targetChild = firstChild;
    while (targetChild != null) {
      if (targetChild.container == targetNode) {
        break;
      }
      final newChild = childAfter(targetChild);
      if (newChild == null) {
        break;
      }
      targetChild = newChild;
    }
    if (targetChild == null) {
      throw 'targetChild should not be null';
    }
    return targetChild;
  }

  void _markNeedsPaddingResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// Returns child of this container located at the specified local `offset`.
  ///
  /// If `offset` is above this container (offset.dy is negative) returns
  /// the first child. Likewise, if `offset` is below this container then
  /// returns the last child.
  RenderEditableBox childAtOffset(Offset offset) {
    assert(firstChild != null);
    resolvePadding();

    if (offset.dy <= _resolvedPadding!.top) {
      return firstChild!;
    }
    if (offset.dy >= size.height - _resolvedPadding!.bottom) {
      return lastChild!;
    }

    var child = firstChild;
    final dx = -offset.dx;
    var dy = _resolvedPadding!.top;
    while (child != null) {
      if (child.size.contains(offset.translate(dx, -dy))) {
        return child;
      }
      dy += child.size.height;
      child = childAfter(child);
    }

    // this case possible, when editor not scrollable,
    // but minHeight > content height and tap was under content
    return lastChild!;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is EditableContainerParentData) {
      return;
    }

    child.parentData = EditableContainerParentData();
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    resolvePadding();
    assert(_resolvedPadding != null);

    var mainAxisExtent = _resolvedPadding!.top;
    var child = firstChild;
    final innerConstraints =
        BoxConstraints.tightFor(width: constraints.maxWidth)
            .deflate(_resolvedPadding!);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = (child.parentData as EditableContainerParentData)
        ..offset = Offset(_resolvedPadding!.left, mainAxisExtent);
      mainAxisExtent += child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += _resolvedPadding!.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));

    assert(size.isFinite);
  }

  double _getIntrinsicCrossAxis(double Function(RenderBox child) childSize) {
    var extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      final childParentData = child.parentData as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  double _getIntrinsicMainAxis(double Function(RenderBox child) childSize) {
    var extent = 0.0;
    var child = firstChild;
    while (child != null) {
      extent += childSize(child);
      final childParentData = child.parentData as EditableContainerParentData;
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    resolvePadding();
    return _getIntrinsicCrossAxis((child) {
      final childHeight = math.max<double>(
          0, height - _resolvedPadding!.top + _resolvedPadding!.bottom);
      return child.getMinIntrinsicWidth(childHeight) +
          _resolvedPadding!.left +
          _resolvedPadding!.right;
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    resolvePadding();
    return _getIntrinsicCrossAxis((child) {
      final childHeight = math.max<double>(
          0, height - _resolvedPadding!.top + _resolvedPadding!.bottom);
      return child.getMaxIntrinsicWidth(childHeight) +
          _resolvedPadding!.left +
          _resolvedPadding!.right;
    });
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    resolvePadding();
    return _getIntrinsicMainAxis((child) {
      final childWidth = math.max<double>(
          0, width - _resolvedPadding!.left + _resolvedPadding!.right);
      return child.getMinIntrinsicHeight(childWidth) +
          _resolvedPadding!.top +
          _resolvedPadding!.bottom;
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    resolvePadding();
    return _getIntrinsicMainAxis((child) {
      final childWidth = math.max<double>(
          0, width - _resolvedPadding!.left + _resolvedPadding!.right);
      return child.getMaxIntrinsicHeight(childWidth) +
          _resolvedPadding!.top +
          _resolvedPadding!.bottom;
    });
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    resolvePadding();
    return defaultComputeDistanceToFirstActualBaseline(baseline)! +
        _resolvedPadding!.top;
  }
}
