import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class QuillEditorUnOrderedListElementOptions extends Equatable {
  const QuillEditorUnOrderedListElementOptions({
    this.useTextColorForDot = true,
  });

  final bool useTextColorForDot;
  @override
  List<Object?> get props => [];
}
