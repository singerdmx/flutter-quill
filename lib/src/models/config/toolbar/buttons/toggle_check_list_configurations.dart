import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Color;

import '../../../documents/attribute.dart';
import '../../quill_configurations.dart';

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
    this.iconSize,
    this.iconButtonFactor,
    this.fillColor,
    this.attribute = Attribute.unchecked,
    this.isShouldRequestKeyboard = false,
    super.controller,
    super.iconTheme,
    super.tooltip,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
  });

  final double? iconSize;
  final double? iconButtonFactor;

  final Color? fillColor;

  final Attribute attribute;

  /// Should we request the keyboard when you press the toggle check list button
  /// ? if true then we will request the keyboard, if false then we will not
  /// but I think you already know that
  final bool isShouldRequestKeyboard;
}
