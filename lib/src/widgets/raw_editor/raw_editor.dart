import 'package:flutter/widgets.dart'
    show BuildContext, State, StatefulWidget, Widget;
import 'package:meta/meta.dart' show immutable;

import '../../models/config/raw_editor/configurations.dart';
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
