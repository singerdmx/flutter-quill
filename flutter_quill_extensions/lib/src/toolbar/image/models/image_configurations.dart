import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../../editor/image/image_embed_types.dart';

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
    super.iconSize,
    super.iconButtonFactor,

    /// specifies the tooltip text for the image button.
    super.tooltip,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    this.dialogTheme,
    this.linkRegExp,
    this.imageButtonConfigurations = const QuillToolbarImageConfigurations(),
  });

  final QuillDialogTheme? dialogTheme;

  /// [imageLinkRegExp] is a regular expression to identify image links.
  final RegExp? linkRegExp;

  final QuillToolbarImageConfigurations imageButtonConfigurations;
}
