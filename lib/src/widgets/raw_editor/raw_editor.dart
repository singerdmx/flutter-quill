import 'package:flutter/widgets.dart'
    show
        AnimationController,
        BuildContext,
        ScrollController,
        State,
        StatefulWidget,
        TextSelectionDelegate,
        Widget;
import 'package:meta/meta.dart' show immutable;

import '../../models/config/raw_editor/raw_editor_configurations.dart';
import '../../models/structs/offset_value.dart';
import '../editor/editor.dart';
import '../others/text_selection.dart';
import 'raw_editor_state.dart';

class QuillRawEditor extends StatefulWidget {
  QuillRawEditor({
    required this.configurations,
    super.key,
  })  : assert(
            configurations.maxHeight == null || configurations.maxHeight! > 0,
            'maxHeight cannot be null'),
        assert(
            configurations.minHeight == null || configurations.minHeight! >= 0,
            'minHeight cannot be null'),
        assert(
            configurations.maxHeight == null ||
                configurations.minHeight == null ||
                configurations.maxHeight! >= configurations.minHeight!,
            'maxHeight cannot be null');

  final QuillRawEditorConfigurations configurations;

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
typedef QuillEditorContextMenuBuilder = Widget Function(
  BuildContext context,
  QuillRawEditorState rawEditorState,
);

@immutable
class QuillEditorGlyphHeights {
  const QuillEditorGlyphHeights(
    this.startGlyphHeight,
    this.endGlyphHeight,
  );

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
