import 'package:flutter/widgets.dart' show BoxConstraints;
import 'package:meta/meta.dart' show immutable;

@immutable
class QuillEditorWebImageEmbedConfigurations {
  const QuillEditorWebImageEmbedConfigurations({
    this.constraints,
  });

  final BoxConstraints? constraints;
}
