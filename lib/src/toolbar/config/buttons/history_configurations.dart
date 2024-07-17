import 'package:flutter/foundation.dart' show immutable;

import '../../../../flutter_quill.dart';

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
    super.iconData,
    super.iconTheme,
    super.afterButtonPressed,
    super.tooltip,
    super.childBuilder,
    super.iconSize,
    super.iconButtonFactor,
  });
}
