import 'package:flutter/widgets.dart' show BoxConstraints;
import 'package:meta/meta.dart' show immutable;

@immutable
class QuillEditorWebImageEmbedConfig {
  const QuillEditorWebImageEmbedConfig({
    this.constraints,
  });

  final BoxConstraints? constraints;
}
