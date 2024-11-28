import 'package:flutter/material.dart';

import '../../../document/attribute.dart';
import '../../../editor_toolbar_controller_shared/quill_config.dart';
import '../../buttons/font_size_button.dart';

class QuillToolbarFontSizeButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarFontSizeButtonExtraOptions({
    required super.controller,
    required this.currentValue,
    required this.defaultDisplayText,
    required super.context,
    required super.onPressed,
  });

  final String currentValue;
  final String defaultDisplayText;
}

@immutable
class QuillToolbarFontSizeButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarFontSizeButtonOptions, QuillToolbarFontSizeButtonExtraOptions> {
  const QuillToolbarFontSizeButtonOptions({
    super.iconSize,
    super.iconButtonFactor,
    this.items,
    this.onSelected,
    this.attribute = Attribute.size,
    super.afterButtonPressed,
    super.tooltip,
    this.padding,
    this.style,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.defaultItemColor = Colors.red,
    super.childBuilder,
    this.shape,
    this.defaultDisplayText,
    this.width,
  });

  final ButtonStyle? shape;

  /// Defaults to:
  ///
  /// ```dart
  /// {
  ///   context.loc.small: 'small',
  ///   context.loc.large: 'large',
  ///   context.loc.huge: 'huge',
  ///   context.loc.clear: '0'
  /// }
  /// ```
  ///
  /// See also: [QuillToolbarFontSizeButtonState._items]
  final Map<String, String>? items;
  final ValueChanged<String>? onSelected;
  final Attribute attribute;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final Color? defaultItemColor;
  final String? defaultDisplayText;
  final double? width;
}
