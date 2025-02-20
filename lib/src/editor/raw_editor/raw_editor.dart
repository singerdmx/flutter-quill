import 'package:flutter/widgets.dart';

import '../../controller/quill_controller.dart';
import 'config/raw_editor_config.dart';
import 'raw_editor_state.dart';

class QuillRawEditor extends StatefulWidget {
  QuillRawEditor({
    required this.config,
    required this.controller,
    super.key,
  })  : assert(config.maxHeight == null || config.maxHeight! > 0,
            'maxHeight cannot be null'),
        assert(config.minHeight == null || config.minHeight! >= 0,
            'minHeight cannot be null'),
        assert(
            config.maxHeight == null ||
                config.minHeight == null ||
                config.maxHeight! >= config.minHeight!,
            'maxHeight cannot be null');

  final QuillController controller;
  final QuillRawEditorConfig config;

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
