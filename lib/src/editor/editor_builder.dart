import 'package:flutter/widgets.dart';

import 'raw_editor/raw_editor.dart';

typedef QuillEditorBuilder = Widget Function(
  BuildContext context,
  QuillRawEditor rawEditor,
);

class QuillEditorBuilderWidget extends StatelessWidget {
  const QuillEditorBuilderWidget({
    required this.child,
    this.builder,
    super.key,
  });

  final QuillRawEditor child;
  final QuillEditorBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final builderCallback = builder;
    if (builderCallback != null) {
      return builderCallback(
        context,
        child,
      );
    }
    return child;
  }
}
