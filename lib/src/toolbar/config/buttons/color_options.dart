import 'package:flutter/widgets.dart' show Color;

import '../../../controller/quill_controller.dart';
import '../base_button_options.dart';

class QuillToolbarColorButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarColorButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    required this.iconColor,
    required this.iconColorBackground,
    required this.fillColor,
    required this.fillColorBackground,
  });

  final Color? iconColor;
  final Color? iconColorBackground;
  final Color? fillColor;
  final Color? fillColorBackground;
}

class QuillToolbarColorButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarColorButtonOptions, QuillToolbarColorButtonExtraOptions> {
  const QuillToolbarColorButtonOptions({
    super.iconSize,
    super.iconButtonFactor,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    this.customOnPressedCallback,
  });

  final QuillToolbarColorPickerOnPressedCallback? customOnPressedCallback;
}

typedef QuillToolbarColorPickerOnPressedCallback = Future<void> Function(
  QuillController controller,
  bool isBackground,
);
