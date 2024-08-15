import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

class QuillToolbarTableButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarTableButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

@immutable
class QuillToolbarTableButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarTableButtonOptions, QuillToolbarTableButtonExtraOptions> {
  const QuillToolbarTableButtonOptions({
    super.iconData,
    super.iconSize,
    super.iconButtonFactor,

    /// specifies the tooltip text for the image button.
    super.tooltip,
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
  });
}
