import 'package:flutter/foundation.dart' show immutable;

import '../../../document/attribute.dart';
import '../../../editor_toolbar_controller_shared/quill_config.dart';

class QuillToolbarToggleCheckListButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarToggleCheckListButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    this.isToggled = false,
  });
  final bool isToggled;
}

@immutable
class QuillToolbarToggleCheckListButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarToggleCheckListButtonOptions,
        QuillToolbarToggleCheckListButtonExtraOptions> {
  const QuillToolbarToggleCheckListButtonOptions({
    super.iconSize,
    super.iconButtonFactor,
    this.attribute = Attribute.unchecked,
    this.shouldRequestKeyboard = false,
    super.iconTheme,
    super.tooltip,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
  });

  final Attribute attribute;

  final bool shouldRequestKeyboard;
}
