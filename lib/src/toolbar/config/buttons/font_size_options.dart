import 'package:flutter/material.dart';

import '../../../document/attribute.dart';
import '../../../editor_toolbar_controller_shared/quill_config.dart';

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
    this.rawItemsMap,
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

  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  final Attribute attribute;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final Color? defaultItemColor;
  final String? defaultDisplayText;
  final double? width;

  QuillToolbarFontSizeButtonOptions copyWith({
    double? iconSize,
    double? iconButtonFactor,
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
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    OutlinedBorder? shape,
    String? defaultDisplayText,
  }) {
    return QuillToolbarFontSizeButtonOptions(
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      rawItemsMap: rawItemsMap ?? this.rawItemsMap,
      onSelected: onSelected ?? this.onSelected,
      attribute: attribute ?? this.attribute,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      tooltip: tooltip ?? super.tooltip,
      afterButtonPressed: afterButtonPressed ?? super.afterButtonPressed,
      defaultDisplayText: defaultDisplayText ?? this.defaultDisplayText,
    );
  }
}
