import 'package:flutter/widgets.dart' show AutovalidateMode;
import 'package:flutter/widgets.dart' show Color, Size;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../embeds/embed_types.dart';

class QuillToolbarMediaButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarMediaButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarMediaButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarMediaButtonOptions, QuillToolbarMediaButtonExtraOptions> {
  const QuillToolbarMediaButtonOptions({
    required this.type,
    required this.onMediaPickedCallback,
    // required this.onVideoPickCallback,
    this.dialogBarrierColor,
    this.mediaFilePicker,
    this.childrenSpacing = 16.0,
    this.autovalidateMode = AutovalidateMode.disabled,
    super.iconSize,
    this.dialogTheme,
    this.labelText,
    this.hintText,
    this.submitButtonText,
    this.submitButtonSize,
    this.galleryButtonText,
    this.linkButtonText,
    this.validationMessage,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
  });

  final QuillMediaType type;
  final QuillDialogTheme? dialogTheme;
  final MediaFilePicker? mediaFilePicker;
  final MediaPickedCallback? onMediaPickedCallback;
  final Color? dialogBarrierColor;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  /// The text of label in link add mode.
  final String? labelText;

  /// The hint text for link [TextField].
  final String? hintText;

  /// The text of the submit button.
  final String? submitButtonText;

  /// The size of dialog buttons.
  final Size? submitButtonSize;

  /// The text of the gallery button [MediaSourceSelectorDialog].
  final String? galleryButtonText;

  /// The text of the link button [MediaSourceSelectorDialog].
  final String? linkButtonText;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;
}
