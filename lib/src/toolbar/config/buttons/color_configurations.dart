import 'package:flutter/widgets.dart' show Color;

import '../../../controller/quill_controller.dart';
import '../../../editor_toolbar_shared/config/quill_shared_configurations.dart'
    show QuillSharedConfigurations;
import '../base_button_configurations.dart';

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
    this.dialogBarrierColor,
    super.iconSize,
    super.iconButtonFactor,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    this.customOnPressedCallback,
  });

  /// By default will use the default `dialogBarrierColor` from
  /// [QuillSharedConfigurations]
  final Color? dialogBarrierColor;

  final QuillToolbarColorPickerOnPressedCallback? customOnPressedCallback;
}

typedef QuillToolbarColorPickerOnPressedCallback = Future<void> Function(
  QuillController controller,
  bool isBackground,
);
