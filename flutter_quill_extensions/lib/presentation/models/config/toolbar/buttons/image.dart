import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../../../../logic/extensions/controller.dart';
import '../../../../embeds/embed_types.dart';
import '../../../../embeds/embed_types/image.dart';

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
    this.dialogTheme,
    this.linkRegExp,
    this.imageButtonConfigurations =
        const QuillToolbarImageButtonConfigurations(),
  });

  final double? iconSize;
  final Color? fillColor;

  final QuillDialogTheme? dialogTheme;

  /// [imageLinkRegExp] is a regular expression to identify image links.
  final RegExp? linkRegExp;

  final QuillToolbarImageButtonConfigurations imageButtonConfigurations;
}

class QuillToolbarImageButtonConfigurations {
  const QuillToolbarImageButtonConfigurations({
    this.onRequestPickImage,
    this.onImagePickedCallback,
    OnImageInsertCallback? onImageInsertCallback,
  }) : _onImageInsertCallback = onImageInsertCallback;

  final OnRequestPickImage? onRequestPickImage;

  final OnImagePickedCallback? onImagePickedCallback;

  final OnImageInsertCallback? _onImageInsertCallback;

  OnImageInsertCallback get onImageInsertCallback {
    return _onImageInsertCallback ?? defaultOnImageInsertCallback();
  }
}
