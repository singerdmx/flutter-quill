import 'package:flutter/foundation.dart' show immutable;

import '../../../document/attribute.dart';
import '../../../editor_toolbar_controller_shared/quill_configurations.dart';

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
    this.isShouldRequestKeyboard = false,
    super.iconTheme,
    super.tooltip,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
  });

  final Attribute attribute;

  /// Should we request the keyboard when you press the toggle check list button
  /// ? if true then we will request the keyboard, if false then we will not
  /// but I think you already know that
  final bool isShouldRequestKeyboard;
}
