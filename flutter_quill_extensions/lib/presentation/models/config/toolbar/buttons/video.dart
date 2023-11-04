import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../embeds/embed_types.dart';

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
    this.onVideoPickCallback,
    this.webVideoPickImpl,
    this.filePickImpl,
    this.mediaPickSettingSelector,
    this.fillColor,
    this.iconSize,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
  });

  final RegExp? linkRegExp;
  final QuillDialogTheme? dialogTheme;
  final OnVideoPickCallback? onVideoPickCallback;

  final WebVideoPickImpl? webVideoPickImpl;

  final FilePickImpl? filePickImpl;

  final MediaPickSettingSelector? mediaPickSettingSelector;

  final Color? fillColor;

  final double? iconSize;
}
