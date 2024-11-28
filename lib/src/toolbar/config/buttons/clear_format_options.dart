import '../../../editor_toolbar_controller_shared/quill_config.dart';

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
    super.iconTheme,
    super.tooltip,
    super.iconSize,
    super.iconButtonFactor,
  });
}
