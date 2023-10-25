import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class QuillEditorCodeBlockElementOptions extends Equatable {
  const QuillEditorCodeBlockElementOptions({
    this.enableLineNumbers = false,
  });

  /// If you want line numbers in the code block, please pass true
  /// by default it's false as it's not really needed in most cases
  final bool enableLineNumbers;

  @override
  List<Object?> get props => [
        enableLineNumbers,
      ];
}
