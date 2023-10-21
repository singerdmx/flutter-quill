import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart'
    show Colors, PopupMenuEntry, ValueChanged;
import 'package:flutter/widgets.dart'
    show
        Color,
        EdgeInsetsGeometry,
        TextStyle,
        VoidCallback,
        TextOverflow,
        EdgeInsets;

import '../../../../widgets/controller.dart';
import '../../../documents/attribute.dart';
import '../../../themes/quill_icon_theme.dart';
import '../../quill_configurations.dart';

@immutable
class QuillToolbarFontSizeButtonOptions extends QuillToolbarBaseButtonOptions {
  const QuillToolbarFontSizeButtonOptions({
    this.iconSize,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.items,
    this.rawItemsMap,
    this.onSelected,
    this.iconTheme,
    this.attribute = Attribute.size,
    this.controller,
    this.afterButtonPressed,
    this.tooltip,
    this.padding,
    this.style,
    this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
  });

  final double? iconSize;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  @Deprecated('It is not required because of `rawItemsMap`')
  final List<PopupMenuEntry<String>>? items;
  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  @override
  final QuillIconTheme? iconTheme;
  final Attribute attribute;
  @override
  final QuillController? controller;
  @override
  final VoidCallback? afterButtonPressed;
  @override
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;
}
