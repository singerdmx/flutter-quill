import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart'
    show ButtonStyle, Colors, PopupMenuEntry, ValueChanged;
import 'package:flutter/widgets.dart'
    show
        Color,
        EdgeInsets,
        EdgeInsetsGeometry,
        OutlinedBorder,
        TextOverflow,
        TextStyle;

import '../../../document/attribute.dart';
import '../../../editor_toolbar_controller_shared/quill_configurations.dart';

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
    @Deprecated('No longer used') this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
    super.childBuilder,
    this.shape,
    this.defaultDisplayText,
  });

  final ButtonStyle? shape;

  /// By default it will be [fontSizesValues] from [QuillSimpleToolbarConfigurations]
  /// You can override this if you want
  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  final Attribute attribute;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final String? initialValue;
  final TextOverflow labelOverflow;
  @Deprecated('No longer used')
  final double? itemHeight;
  @Deprecated('No longer used')
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;
  final String? defaultDisplayText;

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
      // ignore: deprecated_member_use_from_same_package
      width: width ?? this.width,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      // ignore: deprecated_member_use_from_same_package
      itemHeight: itemHeight ?? this.itemHeight,
      // ignore: deprecated_member_use_from_same_package
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      tooltip: tooltip ?? super.tooltip,
      afterButtonPressed: afterButtonPressed ?? super.afterButtonPressed,
      defaultDisplayText: defaultDisplayText ?? this.defaultDisplayText,
    );
  }
}
