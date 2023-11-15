import 'package:flutter/foundation.dart' show immutable;

import '../../../../../flutter_quill.dart';

@immutable
class QuillToolbarHistoryButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarHistoryButtonExtraOptions({
    required this.canPressed,
    required super.controller,
    required super.context,
    required super.onPressed,
  });

  /// If it can redo or undo
  final bool canPressed;
}

@immutable
class QuillToolbarHistoryButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarHistoryButtonOptions, QuillToolbarHistoryButtonExtraOptions> {
  const QuillToolbarHistoryButtonOptions({
    required this.isUndo,
    super.iconData,
    super.controller,
    super.iconTheme,
    super.afterButtonPressed,
    super.tooltip,
    super.childBuilder,
    this.iconSize,
    this.iconButtonFactor,
  });

  /// If this true then it will be the undo button
  /// otherwise it will be redo
  final bool isUndo;

  /// By default will use [globalIconSize]
  final double? iconSize;
  final double? iconButtonFactor;
}
