import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'blocks/code_block.dart';

export 'blocks/code_block.dart';

@immutable
class QuillEditorBlockOptions extends Equatable {
  const QuillEditorBlockOptions({
    this.code = const QuillEditorCodeBlockOptions(),
  });

  final QuillEditorCodeBlockOptions code;
  @override
  List<Object?> get props => [
        code,
      ];
}
