import 'package:flutter/widgets.dart';

import '../../theme/quill_dialog_theme.dart';
import '../base_button_configurations.dart';

class QuillToolbarLinkStyleButton2ExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarLinkStyleButton2ExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarLinkStyleButton2Options extends QuillToolbarBaseButtonOptions<
    QuillToolbarLinkStyleButton2Options,
    QuillToolbarLinkStyleButton2ExtraOptions> {
  const QuillToolbarLinkStyleButton2Options({
    super.iconSize,
    super.iconButtonFactor,
    this.dialogTheme,
    this.constraints,
    this.addLinkLabel,
    this.editLinkLabel,
    this.linkColor,
    this.validationMessage,
    this.buttonSize,
    this.dialogBarrierColor,
    this.childrenSpacing = 16.0,
    this.autovalidateMode = AutovalidateMode.disabled,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
  });

  final QuillDialogTheme? dialogTheme;

  /// The constrains for dialog.
  final BoxConstraints? constraints;

  /// The text of label in link add mode.
  final String? addLinkLabel;

  /// The text of label in link edit mode.
  final String? editLinkLabel;

  /// The color of URL.
  final Color? linkColor;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  /// The size of dialog buttons.
  final Size? buttonSize;

  final Color? dialogBarrierColor;
}
