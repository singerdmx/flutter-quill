import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Colors, PopupMenuEntry;
import 'package:flutter/widgets.dart'
    show
        Color,
        EdgeInsets,
        EdgeInsetsGeometry,
        IconData,
        TextOverflow,
        TextStyle,
        ValueChanged,
        VoidCallback;

import '../../../../../flutter_quill.dart';

@immutable
class QuillToolbarFontFamilyButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarFontFamilyButtonExtraOptions({
    required this.defaultDisplayText,
    required this.currentValue,
    required super.controller,
    required super.context,
    required super.onPressed,
  });
  final String defaultDisplayText;
  final String currentValue;
}

class QuillToolbarFontFamilyButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarFontFamilyButtonOptions,
    QuillToolbarFontFamilyButtonExtraOptions> {
  const QuillToolbarFontFamilyButtonOptions({
    this.attribute = Attribute.font,
    this.rawItemsMap,
    super.controller,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    this.onSelected,
    this.padding,
    this.style,
    this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.overrideTooltipByFontFamily = false,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
    this.renderFontFamilies = true,
    this.highlightElevation = 1,
    this.hoverElevation = 1,
    this.fillColor,
    this.iconSize,
    this.iconButtonFactor,
  });

  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;

  /// By default it will be [fontFamilyValues] from [QuillToolbarConfigurations]
  /// You can override this if you want
  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  final Attribute attribute;

  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final bool renderFontFamilies;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final bool overrideTooltipByFontFamily;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;

  /// By default will use [globalIconSize]
  final double? iconSize;
  final double? iconButtonFactor;

  QuillToolbarFontFamilyButtonOptions copyWith({
    Color? fillColor,
    double? hoverElevation,
    double? highlightElevation,
    List<PopupMenuEntry<String>>? items,
    Map<String, String>? rawItemsMap,
    ValueChanged<String>? onSelected,
    Attribute? attribute,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
    double? width,
    String? initialValue,
    TextOverflow? labelOverflow,
    bool? renderFontFamilies,
    bool? overrideTooltipByFontFamily,
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    double? iconSize,
    double? iconButtonFactor,
    // Add properties to override inherited properties
    QuillController? controller,
    IconData? iconData,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    QuillIconTheme? iconTheme,
  }) {
    return QuillToolbarFontFamilyButtonOptions(
      attribute: attribute ?? this.attribute,
      rawItemsMap: rawItemsMap ?? this.rawItemsMap,
      controller: controller ?? this.controller,
      iconData: iconData ?? this.iconData,
      afterButtonPressed: afterButtonPressed ?? this.afterButtonPressed,
      tooltip: tooltip ?? this.tooltip,
      iconTheme: iconTheme ?? this.iconTheme,
      onSelected: onSelected ?? this.onSelected,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      width: width ?? this.width,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      renderFontFamilies: renderFontFamilies ?? this.renderFontFamilies,
      overrideTooltipByFontFamily:
          overrideTooltipByFontFamily ?? this.overrideTooltipByFontFamily,
      itemHeight: itemHeight ?? this.itemHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      fillColor: fillColor ?? this.fillColor,
      hoverElevation: hoverElevation ?? this.hoverElevation,
      highlightElevation: highlightElevation ?? this.highlightElevation,
    );
  }
}
