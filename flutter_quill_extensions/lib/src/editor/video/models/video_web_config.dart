import 'package:flutter/widgets.dart' show BoxConstraints;
import 'package:meta/meta.dart' show immutable;

@immutable
class QuillEditorWebVideoEmbedConfig {
  const QuillEditorWebVideoEmbedConfig({
    this.constraints,
  });

  @Deprecated('This property is no longer used.')
  final BoxConstraints? constraints;
}
