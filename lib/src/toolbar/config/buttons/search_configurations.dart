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

class QuillToolbarSearchButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarBaseButtonOptions, QuillToolbarSearchButtonExtraOptions> {
  const QuillToolbarSearchButtonOptions({
    super.iconData,
    super.childBuilder,
    super.tooltip,
    super.afterButtonPressed,
    super.iconTheme,
    this.dialogTheme,
    super.iconSize,
    super.iconButtonFactor,
    this.dialogBarrierColor,
    this.customOnPressedCallback,
    this.searchBarAlignment,
  });

  final QuillDialogTheme? dialogTheme;

  /// By default will be [dialogBarrierColor] from [QuillSharedConfigurations]
  final Color? dialogBarrierColor;

  /// By default we will show simple search dialog ui
  /// you can pass value to this callback to change this
  final QuillToolbarSearchButtonOnPressedCallback? customOnPressedCallback;

  final AlignmentGeometry? searchBarAlignment;
}

typedef QuillToolbarSearchButtonOnPressedCallback = Future<void> Function(
  QuillController controller,
);

// typedef QuillToolbarSearchButtonFindTextCallback = List<int> Function({
//   required int index,
//   required String text,
//   required QuillController controller,
//   required List<int> offsets,
//   required bool wholeWord,
//   required bool caseSensitive,
//   bool moveToPosition,
// });

// typedef QuillToolbarSearchButtonMoveToPositionCallback = void Function({
//   required int index,
//   required String text,
//   required QuillController controller,
//   required List<int> offsets,
// });
