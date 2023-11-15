import 'package:flutter/widgets.dart' show Color;

import '../../../../../flutter_quill.dart';

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
    super.controller,
    super.childBuilder,
    super.tooltip,
    super.afterButtonPressed,
    super.iconTheme,
    this.dialogTheme,
    this.iconSize,
    this.iconButtonFactor,
    this.dialogBarrierColor,
    this.fillColor,
    this.customOnPressedCallback,
  });

  final QuillDialogTheme? dialogTheme;
  final double? iconSize;
  final double? iconButtonFactor;

  /// By default will be [dialogBarrierColor] from [QuillSharedConfigurations]
  final Color? dialogBarrierColor;

  final Color? fillColor;

  /// By default we will show simple search dialog ui
  /// you can pass value to this callback to change this
  final QuillToolbarSearchButtonOnPressedCallback? customOnPressedCallback;
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
