import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'elements/code_block.dart';
import 'elements/list/ordered_list.dart';
import 'elements/list/unordered_list.dart';

export 'elements/code_block.dart';
export 'elements/list/ordered_list.dart';
export 'elements/list/unordered_list.dart';

@immutable
class QuillEditorElementOptions extends Equatable {
  const QuillEditorElementOptions({
    this.codeBlock = const QuillEditorCodeBlockElementOptions(),
    this.orderedList = const QuillEditorOrderedListElementOptions(),
    this.unorderedList = const QuillEditorUnOrderedListElementOptions(),
  });

  final QuillEditorCodeBlockElementOptions codeBlock;

  final QuillEditorOrderedListElementOptions orderedList;
  final QuillEditorUnOrderedListElementOptions unorderedList;
  @override
  List<Object?> get props => [
        codeBlock,
      ];
}
