import 'package:flutter/foundation.dart' show immutable;

@immutable
class QuillEditorCodeBlockElementOptions {
  const QuillEditorCodeBlockElementOptions({
    this.enableLineNumbers = false,
  });

  /// If you want line numbers in the code block, please pass true
  /// by default it's false as it's not really needed in most cases
  final bool enableLineNumbers;
}
