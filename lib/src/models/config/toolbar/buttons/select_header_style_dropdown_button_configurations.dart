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
    this.iconSize,
    this.iconButtonFactor,
    this.textStyle,
    super.iconData,
    this.attributes,
  });

  /// By default we will the toolbar axis from [QuillSimpleToolbarConfigurations]
  final double? iconSize;
  final double? iconButtonFactor;
  final TextStyle? textStyle;

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
  }) {
    return QuillToolbarSelectHeaderStyleDropdownButtonOptions(
      attributes: attributes ?? this.attributes,
      iconData: iconData ?? this.iconData,
      afterButtonPressed: afterButtonPressed ?? this.afterButtonPressed,
      tooltip: tooltip ?? this.tooltip,
      iconTheme: iconTheme ?? this.iconTheme,
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
    );
  }
}
