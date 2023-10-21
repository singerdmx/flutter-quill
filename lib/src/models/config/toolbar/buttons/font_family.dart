import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Colors, PopupMenuEntry;
import 'package:flutter/widgets.dart'
    show
        Color,
        ValueChanged,
        EdgeInsetsGeometry,
        TextStyle,
        EdgeInsets,
        TextOverflow;

import '../../../../../flutter_quill.dart';

@immutable
class QuillToolbarFontFamilyButtonExtraOptions {
  const QuillToolbarFontFamilyButtonExtraOptions({
    required this.defaultDisplayText,
    required this.currentValue,
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
    @Deprecated('It is not required because of `rawItemsMap`') this.items,
    this.highlightElevation = 1,
    this.hoverElevation = 1,
    this.fillColor,
    this.iconSize,
  });

  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  @Deprecated('It is not required because of `rawItemsMap`')
  final List<PopupMenuEntry<String>>? items;

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
}
