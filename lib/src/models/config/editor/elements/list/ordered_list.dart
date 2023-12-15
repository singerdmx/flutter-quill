import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class QuillEditorOrderedListElementOptions extends Equatable {
  const QuillEditorOrderedListElementOptions({
    this.useTextColorForDot = true,
  });

  final bool useTextColorForDot;
  @override
  List<Object?> get props => [];
}
