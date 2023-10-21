import 'package:flutter/foundation.dart' show VoidCallback, immutable;

import '../../../../../flutter_quill.dart';

@immutable
class HistoryButtonExtraOptions {
  const HistoryButtonExtraOptions({
    required this.onPressed,
    required this.canPressed,
  });

  /// When the button pressed
  final VoidCallback onPressed;

  /// If it can redo or undo
  final bool canPressed;
}

@immutable
class QuillToolbarHistoryButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarHistoryButtonOptions, HistoryButtonExtraOptions> {
  const QuillToolbarHistoryButtonOptions({
    required this.isUndo,
    super.iconData,
    super.controller,
    super.iconTheme,
    super.afterButtonPressed,
    super.tooltip,
    super.childBuilder,
    this.iconSize,
  });

  /// If this true then it will be the undo button
  /// otherwise it will be redo
  final bool isUndo;

  /// By default will use [globalIconSize]
  final double? iconSize;
}
