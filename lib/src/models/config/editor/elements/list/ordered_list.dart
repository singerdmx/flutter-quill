import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Widget;

@immutable
class QuillEditorOrderedListElementOptions extends Equatable {
  const QuillEditorOrderedListElementOptions({
    this.useTextColorForDot = true,
    this.customWidget,
  });

  final bool useTextColorForDot;
  final Widget? customWidget;
  @override
  List<Object?> get props => [];
}
