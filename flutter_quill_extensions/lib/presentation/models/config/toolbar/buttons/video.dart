import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../embeds/embed_types/video.dart';

class QuillToolbarVideoButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarVideoButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarVideoButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarVideoButtonOptions, QuillToolbarVideoButtonExtraOptions> {
  const QuillToolbarVideoButtonOptions({
    this.linkRegExp,
    this.dialogTheme,
    this.fillColor,
    this.iconSize,
    this.iconButtonFactor,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
    this.videoConfigurations = const QuillToolbarVideoConfigurations(),
  });

  final RegExp? linkRegExp;
  final QuillDialogTheme? dialogTheme;
  final QuillToolbarVideoConfigurations videoConfigurations;

  final Color? fillColor;

  final double? iconSize;
  final double? iconButtonFactor;
}
