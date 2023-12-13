import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Color;

@immutable
class QuillEditorOrderedListElementOptions extends Equatable {
  const QuillEditorOrderedListElementOptions({
    this.backgroundColor,
    this.fontColor,
    this.useTextColorForDot = true,
  });

  final Color? backgroundColor;
  final Color? fontColor;
  final bool useTextColorForDot;
  @override
  List<Object?> get props => [];
}
