import 'package:flutter/material.dart';

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
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    this.iconSize,
    this.iconButtonFactor,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.onSelected,
    this.attributes,
    this.padding,
    this.style,
    this.width,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor,
    this.renderItemTextStyle = false,
  });

  final double? iconSize;
  final double? iconButtonFactor;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final ValueChanged<String>? onSelected;
  final List<Attribute>? attributes;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final TextOverflow labelOverflow;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;
  final bool renderItemTextStyle;

  QuillToolbarSelectHeaderStyleDropdownButtonOptions copyWith({
    Color? fillColor,
    double? hoverElevation,
    double? highlightElevation,
    List<PopupMenuEntry<String>>? items,
    ValueChanged<String>? onSelected,
    List<Attribute>? attributes,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
    double? width,
    TextOverflow? labelOverflow,
    bool? renderFontFamilies,
    bool? overrideTooltipByFontFamily,
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    double? iconSize,
    double? iconButtonFactor,
    IconData? iconData,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    QuillIconTheme? iconTheme,
    bool? renderItemTextStyle,
  }) {
    return QuillToolbarSelectHeaderStyleDropdownButtonOptions(
      attributes: attributes ?? this.attributes,
      iconData: iconData ?? this.iconData,
      afterButtonPressed: afterButtonPressed ?? this.afterButtonPressed,
      tooltip: tooltip ?? this.tooltip,
      iconTheme: iconTheme ?? this.iconTheme,
      onSelected: onSelected ?? this.onSelected,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      width: width ?? this.width,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      itemHeight: itemHeight ?? this.itemHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      fillColor: fillColor ?? this.fillColor,
      hoverElevation: hoverElevation ?? this.hoverElevation,
      highlightElevation: highlightElevation ?? this.highlightElevation,
      renderItemTextStyle: renderItemTextStyle ?? this.renderItemTextStyle,
    );
  }
}
