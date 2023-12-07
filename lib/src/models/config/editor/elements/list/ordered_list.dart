import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Color;

@immutable
class QuillEditorOrderedListElementOptions extends Equatable {
  const QuillEditorOrderedListElementOptions(
      {this.backgroundColor, this.fontColor});

  final Color? backgroundColor;
  final Color? fontColor;
  @override
  List<Object?> get props => [];
}
