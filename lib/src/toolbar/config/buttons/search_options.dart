import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';

class QuillToolbarSearchButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSearchButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarSearchButtonOptions extends QuillToolbarBaseButtonOptions {
  const QuillToolbarSearchButtonOptions({
    super.iconData,
    super.childBuilder,
    super.tooltip,
    super.afterButtonPressed,
    super.iconTheme,
    this.dialogTheme,
    super.iconSize,
    super.iconButtonFactor,
    this.customOnPressedCallback,
    this.searchBarAlignment,
  });

  final QuillDialogTheme? dialogTheme;

  /// By default we will show simple search dialog ui
  /// you can pass value to this callback to change this
  final QuillToolbarSearchButtonOnPressedCallback? customOnPressedCallback;

  final AlignmentGeometry? searchBarAlignment;
}

typedef QuillToolbarSearchButtonOnPressedCallback = Future<void> Function(
  QuillController controller,
);
