import '../../quill_configurations.dart';

class QuillToolbarClearFormatButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarClearFormatButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarClearFormatButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillToolbarClearFormatButtonOptions,
        QuillToolbarClearFormatButtonExtraOptions> {
  const QuillToolbarClearFormatButtonOptions({
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.controller,
    super.iconTheme,
    super.tooltip,
    this.iconSize,
    this.iconButtonFactor,
  });

  final double? iconSize;
  final double? iconButtonFactor;
}
