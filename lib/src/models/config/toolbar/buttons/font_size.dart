import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart'
    show Colors, PopupMenuEntry, ValueChanged;
import 'package:flutter/widgets.dart'
    show Color, EdgeInsets, EdgeInsetsGeometry, TextOverflow, TextStyle;

import '../../../../widgets/controller.dart';
import '../../../documents/attribute.dart';
import '../../../themes/quill_icon_theme.dart';
import '../../quill_configurations.dart';

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
    this.iconSize,
    this.iconButtonFactor,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.rawItemsMap,
    this.onSelected,
    super.iconTheme,
    this.attribute = Attribute.size,
    super.controller,
    super.afterButtonPressed,
    super.tooltip,
    this.padding,
    this.style,
    this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
    super.childBuilder,
  });

  final double? iconSize;
  final double? iconButtonFactor;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;

  /// By default it will be [fontSizesValues] from [QuillToolbarConfigurations]
  /// You can override this if you want
  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  final Attribute attribute;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;

  QuillToolbarFontSizeButtonOptions copyWith({
    double? iconSize,
    double? iconButtonFactor,
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
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    QuillIconTheme? iconTheme,
    QuillController? controller,
  }) {
    return QuillToolbarFontSizeButtonOptions(
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      fillColor: fillColor ?? this.fillColor,
      hoverElevation: hoverElevation ?? this.hoverElevation,
      highlightElevation: highlightElevation ?? this.highlightElevation,
      rawItemsMap: rawItemsMap ?? this.rawItemsMap,
      onSelected: onSelected ?? this.onSelected,
      attribute: attribute ?? this.attribute,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      width: width ?? this.width,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      itemHeight: itemHeight ?? this.itemHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      tooltip: tooltip ?? super.tooltip,
      iconTheme: iconTheme ?? super.iconTheme,
      afterButtonPressed: afterButtonPressed ?? super.afterButtonPressed,
      controller: controller ?? super.controller,
    );
  }
}
