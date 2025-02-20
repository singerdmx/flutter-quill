import 'package:flutter/cupertino.dart'
    show CupertinoTheme, cupertinoTextSelectionControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/utils/platform.dart';
import '../controller/quill_controller.dart';
import '../document/nodes/leaf.dart';
import 'config/editor_config.dart';
import 'embed/embed_editor_builder.dart';
import 'raw_editor/config/raw_editor_config.dart';
import 'raw_editor/editor_state.dart';
import 'raw_editor/raw_editor.dart';
import 'render/quill_editor_text_selection_gestures.dart';
import 'widgets/delegate.dart';
import 'widgets/styles/cursor_style.dart';

class QuillEditor extends StatefulWidget {
  /// Quick start guide:
  ///
  /// Instantiate a controller:
  /// ```dart
  /// QuillController _controller = QuillController.basic();
  /// ```
  ///
  /// Connect the controller to the `QuillEditor` and `QuillSimpleToolbar` widgets.
  ///
  /// ```dart
  /// QuillSimpleToolbar(
  ///   controller: _controller,
  /// ),
  /// Expanded(
  ///   child: QuillEditor.basic(
  ///     controller: _controller,
  ///   ),
  /// ),
  /// ```
  ///
  QuillEditor({
    required this.focusNode,
    required this.scrollController,
    required this.controller,
    this.config = const QuillEditorConfig(),
    super.key,
  }) {
    // Store editor config in the controller to pass them to the document to
    // support search within embed objects https://github.com/singerdmx/flutter-quill/pull/2090.
    // For internal use only, should not be exposed as a public API.
    controller.editorConfig = config;
  }

  factory QuillEditor.basic({
    required QuillController controller,
    Key? key,
    QuillEditorConfig config = const QuillEditorConfig(),
    FocusNode? focusNode,
    ScrollController? scrollController,
  }) {
    return QuillEditor(
      key: key,
      scrollController: scrollController ?? ScrollController(),
      focusNode: focusNode ?? FocusNode(),
      controller: controller,
      config: config,
    );
  }

  /// Controller object which establishes a link between a rich text document
  /// and this editor.
  final QuillController controller;

  /// The configurations for the editor widget.
  final QuillEditorConfig config;

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;

  /// The [ScrollController] to use when vertically scrolling the contents.
  final ScrollController scrollController;

  @override
  QuillEditorState createState() => QuillEditorState();
}

class QuillEditorState extends State<QuillEditor>
    implements EditorTextSelectionGestureDetectorBuilderDelegate {
  late GlobalKey<EditorState> _editorKey;
  late EditorTextSelectionGestureDetectorBuilder
      _selectionGestureDetectorBuilder;

  QuillController get controller => widget.controller;

  QuillEditorConfig get configurations => widget.config;

  @override
  void initState() {
    super.initState();
    _editorKey = configurations.editorKey ?? GlobalKey<EditorState>();
    _selectionGestureDetectorBuilder =
        QuillEditorSelectionGestureDetectorBuilder(
      this,
      configurations.detectWordBoundary,
    );

    final focusNode = widget.focusNode;

    if (configurations.autoFocus) {
      focusNode.requestFocus();
    }

    // Hide toolbar when the editor loses focus.
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _editorKey.currentState?.hideToolbar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectionTheme =
        configurations.textSelectionThemeData ?? TextSelectionTheme.of(context);

    TextSelectionControls textSelectionControls;
    bool paintCursorAboveText;
    bool cursorOpacityAnimates;
    Offset? cursorOffset;
    Color? cursorColor;
    Color selectionColor;
    Radius? cursorRadius;

    if (theme.isCupertino) {
      final cupertinoTheme = CupertinoTheme.of(context);
      textSelectionControls = cupertinoTextSelectionControls;
      paintCursorAboveText = true;
      cursorOpacityAnimates = true;
      cursorColor ??= selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
      selectionColor = selectionTheme.selectionColor ??
          cupertinoTheme.primaryColor.withValues(alpha: 0.40);
      cursorRadius ??= const Radius.circular(2);
      cursorOffset = Offset(
          iOSHorizontalOffset / MediaQuery.devicePixelRatioOf(context), 0);
    } else {
      textSelectionControls = materialTextSelectionControls;
      paintCursorAboveText = false;
      cursorOpacityAnimates = false;
      cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
      selectionColor = selectionTheme.selectionColor ??
          theme.colorScheme.primary.withValues(alpha: 0.40);
    }

    final showSelectionToolbar = configurations.enableInteractiveSelection &&
        configurations.enableSelectionToolbar;

    final child = QuillRawEditor(
      key: _editorKey,
      controller: controller,
      config: QuillRawEditorConfig(
        characterShortcutEvents: widget.config.characterShortcutEvents,
        spaceShortcutEvents: widget.config.spaceShortcutEvents,
        onKeyPressed: widget.config.onKeyPressed,
        customLeadingBuilder: widget.config.customLeadingBlockBuilder,
        focusNode: widget.focusNode,
        scrollController: widget.scrollController,
        scrollable: configurations.scrollable,
        enableAlwaysIndentOnTab: configurations.enableAlwaysIndentOnTab,
        scrollBottomInset: configurations.scrollBottomInset,
        padding: configurations.padding,
        readOnly: controller.readOnly,
        checkBoxReadOnly: configurations.checkBoxReadOnly,
        disableClipboard: configurations.disableClipboard,
        placeholder: configurations.placeholder,
        onLaunchUrl: configurations.onLaunchUrl,
        contextMenuBuilder: showSelectionToolbar
            ? (configurations.contextMenuBuilder ??
                QuillRawEditorConfig.defaultContextMenuBuilder)
            : null,
        showSelectionHandles: isMobile,
        showCursor: configurations.showCursor ?? true,
        cursorStyle: CursorStyle(
          color: cursorColor,
          backgroundColor: Colors.grey,
          width: 2,
          radius: cursorRadius,
          offset: cursorOffset,
          paintAboveText:
              configurations.paintCursorAboveText ?? paintCursorAboveText,
          opacityAnimates: cursorOpacityAnimates,
        ),
        textCapitalization: configurations.textCapitalization,
        minHeight: configurations.minHeight,
        maxHeight: configurations.maxHeight,
        maxContentWidth: configurations.maxContentWidth,
        customStyles: configurations.customStyles,
        expands: configurations.expands,
        autoFocus: configurations.autoFocus,
        selectionColor: selectionColor,
        selectionCtrls:
            configurations.textSelectionControls ?? textSelectionControls,
        keyboardAppearance: configurations.keyboardAppearance,
        enableInteractiveSelection: configurations.enableInteractiveSelection,
        scrollPhysics: configurations.scrollPhysics,
        embedBuilder: _getEmbedBuilder,
        textSpanBuilder: configurations.textSpanBuilder,
        linkActionPickerDelegate: configurations.linkActionPickerDelegate,
        customStyleBuilder: configurations.customStyleBuilder,
        customRecognizerBuilder: configurations.customRecognizerBuilder,
        floatingCursorDisabled: configurations.floatingCursorDisabled,
        customShortcuts: configurations.customShortcuts,
        customActions: configurations.customActions,
        customLinkPrefixes: configurations.customLinkPrefixes,
        onTapOutsideEnabled: configurations.onTapOutsideEnabled,
        onTapOutside: configurations.onTapOutside,
        dialogTheme: configurations.dialogTheme,
        contentInsertionConfiguration:
            configurations.contentInsertionConfiguration,
        enableScribble: configurations.enableScribble,
        onScribbleActivated: configurations.onScribbleActivated,
        scribbleAreaInsets: configurations.scribbleAreaInsets,
        readOnlyMouseCursor: configurations.readOnlyMouseCursor,
        textInputAction: configurations.textInputAction,
        onPerformAction: configurations.onPerformAction,
      ),
    );

    final editor = selectionEnabled
        ? _selectionGestureDetectorBuilder.build(
            behavior: HitTestBehavior.translucent,
            detectWordBoundary: configurations.detectWordBoundary,
            child: child,
          )
        : child;

    if (kIsWeb) {
      // Intercept RawKeyEvent on Web to prevent it from propagating to parents
      // that might interfere with the editor key behavior, such as
      // SingleChildScrollView. Thanks to @wliumelb for the workaround.
      // See issue https://github.com/singerdmx/flutter-quill/issues/304
      return KeyboardListener(
        onKeyEvent: (_) {},
        focusNode: FocusNode(
          onKeyEvent: (node, event) => KeyEventResult.skipRemainingHandlers,
        ),
        child: editor,
      );
    }

    return editor;
  }

  EmbedBuilder _getEmbedBuilder(Embed node) {
    final builders = configurations.embedBuilders;

    if (builders != null) {
      for (final builder in builders) {
        if (builder.key == node.value.type) {
          return builder;
        }
      }
    }

    final unknownEmbedBuilder = configurations.unknownEmbedBuilder;
    if (unknownEmbedBuilder != null) {
      return unknownEmbedBuilder;
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
  bool get selectionEnabled => configurations.enableInteractiveSelection;
}
