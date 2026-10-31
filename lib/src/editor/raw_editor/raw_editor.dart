import 'package:flutter/widgets.dart';

import '../../common/structs/offset_value.dart';
import '../../controller/quill_controller.dart';
import '../editor.dart';
import '../widgets/text/text_selection.dart';
import 'config/raw_editor_config.dart';
import 'raw_editor_state.dart';

class QuillRawEditor extends StatefulWidget {
  QuillRawEditor({
    required this.config,
    required this.controller,
    this.dragOffsetNotifier,
    super.key,
  }) : assert(
         config.maxHeight == null || config.maxHeight! > 0,
         'maxHeight cannot be null',
       ),
       assert(
         config.minHeight == null || config.minHeight! >= 0,
         'minHeight cannot be null',
       ),
       assert(
         config.maxHeight == null ||
             config.minHeight == null ||
             config.maxHeight! >= config.minHeight!,
         'maxHeight cannot be null',
       );

  final QuillController controller;
  final QuillRawEditorConfig config;

  /// {@template drag_offset_notifier}
  /// dragOffsetNotifier - Only used on iOS and Android
  ///
  /// [QuillRawEditor] contains a gesture detector [EditorTextSelectionGestureDetector]
  /// within its widget tree that shows the magnifier in the root [Overlay]. The
  /// value is the point that is being selected, in global coordinates. During
  /// a long press or a mouse drag, it is the position of the touch or of the
  /// mouse. During a handle drag, it is the point to which the dragged end of
  /// the selection moves. The magnifier shows the line at this point. Setting
  /// the value to `null` hides the magnifier.
  ///
  /// Initial selection events are posted by [EditorTextSelectionGestureDetector]. Once
  /// a selection has been created, dragging the selection handles happens in
  /// [EditorTextSelectionOverlay].
  ///
  /// Both [EditorTextSelectionGestureDetector] and [EditorTextSelectionOverlay] will update
  /// the value of the dragOffsetNotifier.
  ///
  /// The [EditorTextSelectionGestureDetector] will use the value to display the magnifier in
  /// the correct location (or hide the magnifier if null). [EditorTextSelectionOverlay] will
  /// use the value of the dragOffsetNotifier to hide the context menu when the magnifier is
  /// displayed and show the context menu when dragging is complete.
  /// {@endtemplate}
  final ValueNotifier<Offset?>? dragOffsetNotifier;

  @override
  State<StatefulWidget> createState() => QuillRawEditorState();
}

/// Signature for a widget builder that builds a context menu for the given
/// [QuillRawEditorState].
///
/// See also:
///
///  * [EditableTextContextMenuBuilder], which performs the same role for
///    [EditableText]
typedef QuillEditorContextMenuBuilder =
    Widget Function(BuildContext context, QuillRawEditorState rawEditorState);

@immutable
class QuillEditorGlyphHeights {
  const QuillEditorGlyphHeights(this.startGlyphHeight, this.endGlyphHeight);

  final double startGlyphHeight;
  final double endGlyphHeight;
}

/// Base interface for the editor state which defines contract used by
/// various mixins.
abstract class EditorState extends State<QuillRawEditor>
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
