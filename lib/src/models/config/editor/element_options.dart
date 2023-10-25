import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'elements/code_block.dart';

export 'elements/code_block.dart';

@immutable
class QuillEditorElementOptions extends Equatable {
  const QuillEditorElementOptions({
    this.code = const QuillEditorCodeBlockElementOptions(),
  });

  final QuillEditorCodeBlockElementOptions code;
  @override
  List<Object?> get props => [
        code,
      ];
}
