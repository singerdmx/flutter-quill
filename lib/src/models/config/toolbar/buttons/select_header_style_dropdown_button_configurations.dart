import 'package:flutter/widgets.dart'
    show IconData, TextStyle, ValueChanged, VoidCallback;

import '../../../../widgets/toolbar/base_toolbar.dart';
import '../../../documents/attribute.dart';
import '../../../themes/quill_icon_theme.dart';

class QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    required this.currentValue,
  });
  final Attribute currentValue;
}

class QuillToolbarSelectHeaderStyleDropdownButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectHeaderStyleDropdownButtonOptions,
        QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions> {
  const QuillToolbarSelectHeaderStyleDropdownButtonOptions({
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    super.iconSize,
    super.iconButtonFactor,
    this.textStyle,
    this.dropdownTextStyle,
    super.iconData,
    this.attributes,
    this.defaultDisplayText,
    this.width,
  });

  final TextStyle? textStyle;
  final TextStyle? dropdownTextStyle;

  /// Header attributes, defaults to:
  /// ```dart
  /// [
  ///   Attribute.h1,
  ///   Attribute.h2,
  ///   Attribute.h3,
  ///   Attribute.h4,
  ///   Attribute.h5,
  ///   Attribute.h6,
  ///   Attribute.header,
  /// ]
  /// ```
  final List<Attribute<int?>>? attributes;
  final double? width;

  final String? defaultDisplayText;

  QuillToolbarSelectHeaderStyleDropdownButtonOptions copyWith({
    ValueChanged<String>? onSelected,
    List<Attribute<int>>? attributes,
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
    return QuillToolbarSelectHeaderStyleDropdownButtonOptions(
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
