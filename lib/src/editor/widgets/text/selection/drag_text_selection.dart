import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// internal use, used to get drag direction information
@internal
class DragTextSelection extends TextSelection {
  const DragTextSelection({
    super.affinity,
    super.baseOffset = 0,
    super.extentOffset = 0,
    super.isDirectional,
    this.first = true,
  });

  final bool first;

  @override
  DragTextSelection copyWith({
    int? baseOffset,
    int? extentOffset,
    TextAffinity? affinity,
    bool? isDirectional,
    bool? first,
  }) {
    return DragTextSelection(
      baseOffset: baseOffset ?? this.baseOffset,
      extentOffset: extentOffset ?? this.extentOffset,
      affinity: affinity ?? this.affinity,
      isDirectional: isDirectional ?? this.isDirectional,
      first: first ?? this.first,
    );
  }
}
