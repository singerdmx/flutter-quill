import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../../../embeds/embed_types.dart';

class QuillToolbarImageButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarImageButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

@immutable
class QuillToolbarImageButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarImageButtonOptions, QuillToolbarImageButtonExtraOptions> {
  const QuillToolbarImageButtonOptions({
    super.iconData,
    super.controller,
    this.iconSize,

    /// specifies the tooltip text for the image button.
    super.tooltip,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    this.fillColor,
    this.onImagePickCallback,
    this.filePickImpl,
    this.webImagePickImpl,
    this.mediaPickSettingSelector,
    this.dialogTheme,
    this.linkRegExp,
  });

  final double? iconSize;
  final Color? fillColor;

  final OnImagePickCallback? onImagePickCallback;

  final WebImagePickImpl? webImagePickImpl;

  final FilePickImpl? filePickImpl;

  final MediaPickSettingSelector? mediaPickSettingSelector;

  final QuillDialogTheme? dialogTheme;

  /// [imageLinkRegExp] is a regular expression to identify image links.
  final RegExp? linkRegExp;
}
