import 'package:flutter/widgets.dart'
    show IconData, TextStyle, ValueChanged, VoidCallback;

import '../../../document/attribute.dart';
import '../../base_toolbar.dart';
import '../../theme/quill_icon_theme.dart';

class QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    required this.currentValue,
  });
  final Attribute currentValue;
}

class QuillToolbarSelectLineHeightStyleDropdownButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectLineHeightStyleDropdownButtonOptions,
        QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions> {
  const QuillToolbarSelectLineHeightStyleDropdownButtonOptions({
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    super.iconSize,
    super.iconButtonFactor,
    this.textStyle,
    super.iconData,
    this.attributes,
    this.defaultDisplayText,
    this.width,
  });

  final TextStyle? textStyle;

  /// Line-height attributes, defaults to:
  /// ```dart
  /// [
  ///   Attribute.lineHeightNormal,
  ///   Attribute.lineHeightTight,
  ///   Attribute.lineHeightOneAndHalf,
  ///   Attribute.lineHeightDouble,
  /// ]
  /// ```
  final List<Attribute<double?>>? attributes;
  final double? width;

  final String? defaultDisplayText;

  QuillToolbarSelectLineHeightStyleDropdownButtonOptions copyWith({
    ValueChanged<String>? onSelected,
    List<Attribute<double>>? attributes,
    TextStyle? style,
    double? iconSize,
    double? iconButtonFactor,
    IconData? iconData,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    QuillIconTheme? iconTheme,
    String? defaultDisplayText,
    double? width,
  }) {
    return QuillToolbarSelectLineHeightStyleDropdownButtonOptions(
      attributes: attributes ?? this.attributes,
      iconData: iconData ?? this.iconData,
      afterButtonPressed: afterButtonPressed ?? this.afterButtonPressed,
      tooltip: tooltip ?? this.tooltip,
      iconTheme: iconTheme ?? this.iconTheme,
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      defaultDisplayText: defaultDisplayText ?? this.defaultDisplayText,
      width: width ?? this.width,
    );
  }
}
