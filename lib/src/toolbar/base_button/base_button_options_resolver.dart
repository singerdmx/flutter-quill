import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../../editor_toolbar_controller_shared/quill_config.dart';
import '../theme/quill_icon_theme.dart';

@internal
class QuillToolbarButtonOptionsResolver {
  const QuillToolbarButtonOptionsResolver({
    required this.baseOptions,
    required this.specificOptions,
  });

  /// The default options for all buttons.
  final QuillToolbarBaseButtonOptions? baseOptions;

  /// The options for a specific button; falls back to [baseOptions] if not set.
  final QuillToolbarBaseButtonOptions? specificOptions;

  IconData? get iconData => specificOptions?.iconData ?? baseOptions?.iconData;

  String? get tooltip => specificOptions?.tooltip ?? baseOptions?.tooltip;

  double? get iconSize => specificOptions?.iconSize ?? baseOptions?.iconSize;

  double? get iconButtonFactor =>
      specificOptions?.iconButtonFactor ?? baseOptions?.iconButtonFactor;

  VoidCallback? get afterButtonPressed =>
      specificOptions?.afterButtonPressed ?? baseOptions?.afterButtonPressed;

  QuillIconTheme? get iconTheme =>
      specificOptions?.iconTheme ?? baseOptions?.iconTheme;

  QuillToolbarButtonOptionsChildBuilder get childBuilder =>
      specificOptions?.childBuilder ?? baseOptions?.childBuilder;
}
