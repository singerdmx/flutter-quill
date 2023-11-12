import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

class QuillToolbarSelectAlignmentButton extends StatefulWidget {
  const QuillToolbarSelectAlignmentButton({
    required this.controller,
    required this.options,
    this.showLeftAlignment,
    this.showCenterAlignment,
    this.showRightAlignment,
    this.showJustifyAlignment,
    this.padding,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectAlignmentButtonOptions options;

  final bool? showLeftAlignment;
  final bool? showCenterAlignment;
  final bool? showRightAlignment;
  final bool? showJustifyAlignment;
  final EdgeInsetsGeometry? padding;

  @override
  QuillToolbarSelectAlignmentButtonState createState() =>
      QuillToolbarSelectAlignmentButtonState();
}

class QuillToolbarSelectAlignmentButtonState
    extends State<QuillToolbarSelectAlignmentButton> {
  Attribute? _value;

  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    });
    controller.addListener(_didChangeEditingValue);
  }

  QuillToolbarSelectAlignmentButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return widget.controller;
  }

  double get _iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double get _iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? get _afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions.afterButtonPressed;
  }

  QuillIconTheme? get _iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions.iconTheme;
  }

  QuillToolbarBaseButtonOptions get baseButtonExtraOptions {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  QuillSelectAlignmentValues<IconData> get _iconsData {
    final iconsData = options.iconsData;
    if (iconsData != null) {
      return iconsData;
    }
    final baseIconData = baseButtonExtraOptions.iconData;
    if (baseIconData != null) {
      return QuillSelectAlignmentValues(
        leftAlignment: baseIconData,
        centerAlignment: baseIconData,
        rightAlignment: baseIconData,
        justifyAlignment: baseIconData,
      );
    }
    return const QuillSelectAlignmentValues(
      leftAlignment: Icons.format_align_left,
      centerAlignment: Icons.format_align_center,
      rightAlignment: Icons.format_align_right,
      justifyAlignment: Icons.format_align_justify,
    );
  }

  QuillSelectAlignmentValues<String> get _tooltips {
    final tooltips = options.tooltips;
    if (tooltips != null) {
      return tooltips;
    }
    final baseToolTip = baseButtonExtraOptions.tooltip;
    if (baseToolTip != null) {
      return QuillSelectAlignmentValues(
        leftAlignment: baseToolTip,
        centerAlignment: baseToolTip,
        rightAlignment: baseToolTip,
        justifyAlignment: baseToolTip,
      );
    }
    return QuillSelectAlignmentValues(
      leftAlignment: context.loc.alignLeft,
      centerAlignment: context.loc.alignCenter,
      rightAlignment: context.loc.alignRight,
      justifyAlignment: context.loc.justifyWinWidth,
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    });
  }

  @override
  void didUpdateWidget(covariant QuillToolbarSelectAlignmentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      controller.addListener(_didChangeEditingValue);
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    }
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valueToText = <Attribute, String>{
      if (widget.showLeftAlignment!)
        Attribute.leftAlignment: Attribute.leftAlignment.value!,
      if (widget.showCenterAlignment!)
        Attribute.centerAlignment: Attribute.centerAlignment.value!,
      if (widget.showRightAlignment!)
        Attribute.rightAlignment: Attribute.rightAlignment.value!,
      if (widget.showJustifyAlignment!)
        Attribute.justifyAlignment: Attribute.justifyAlignment.value!,
    };

    final valueAttribute = <Attribute>[
      if (widget.showLeftAlignment!) Attribute.leftAlignment,
      if (widget.showCenterAlignment!) Attribute.centerAlignment,
      if (widget.showRightAlignment!) Attribute.rightAlignment,
      if (widget.showJustifyAlignment!) Attribute.justifyAlignment
    ];
    final valueString = <String>[
      if (widget.showLeftAlignment!) Attribute.leftAlignment.value!,
      if (widget.showCenterAlignment!) Attribute.centerAlignment.value!,
      if (widget.showRightAlignment!) Attribute.rightAlignment.value!,
      if (widget.showJustifyAlignment!) Attribute.justifyAlignment.value!,
    ];
    // final _valueToButtons = <Attribute, ToolbarButtons>{
    //   if (widget.showLeftAlignment!)
    //     Attribute.leftAlignment: ToolbarButtons.leftAlignment,
    //   if (widget.showCenterAlignment!)
    //     Attribute.centerAlignment: ToolbarButtons.centerAlignment,
    //   if (widget.showRightAlignment!)
    //     Attribute.rightAlignment: ToolbarButtons.rightAlignment,
    //   if (widget.showJustifyAlignment!)
    //     Attribute.justifyAlignment: ToolbarButtons.justifyAlignment,
    // };

    final buttonCount = ((widget.showLeftAlignment!) ? 1 : 0) +
        ((widget.showCenterAlignment!) ? 1 : 0) +
        ((widget.showRightAlignment!) ? 1 : 0) +
        ((widget.showJustifyAlignment!) ? 1 : 0);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;

    void sharedOnPressed(int index) {
      valueAttribute[index] == Attribute.leftAlignment
          ? controller.formatSelection(
              Attribute.clone(Attribute.align, null),
            )
          : controller.formatSelection(valueAttribute[index]);
      _afterButtonPressed?.call();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttonCount, (index) {
        if (childBuilder != null) {
          return childBuilder(
            QuillToolbarSelectAlignmentButtonOptions(
              afterButtonPressed: _afterButtonPressed,
              iconSize: _iconSize,
              iconButtonFactor: _iconButtonFactor,
              iconTheme: _iconTheme,
              tooltips: _tooltips,
              iconsData: _iconsData,
            ),
            QuillToolbarSelectAlignmentButtonExtraOptions(
              context: context,
              controller: controller,
              onPressed: () => sharedOnPressed(index),
            ),
          );
        }
        final theme = Theme.of(context);
        return Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: _iconSize * _iconButtonFactor,
              height: _iconSize * _iconButtonFactor,
            ),
            child: UtilityWidgets.maybeTooltip(
              message: valueString[index] == Attribute.leftAlignment.value
                  ? _tooltips.leftAlignment
                  : valueString[index] == Attribute.centerAlignment.value
                      ? _tooltips.centerAlignment
                      : valueString[index] == Attribute.rightAlignment.value
                          ? _tooltips.rightAlignment
                          : _tooltips.justifyAlignment,
              child: RawMaterialButton(
                hoverElevation: 0,
                highlightElevation: 0,
                elevation: 0,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_iconTheme?.borderRadius ?? 2)),
                fillColor: valueToText[_value] == valueString[index]
                    ? (_iconTheme?.iconSelectedFillColor ?? theme.primaryColor)
                    : (_iconTheme?.iconUnselectedFillColor ??
                        theme.canvasColor),
                onPressed: () => sharedOnPressed(index),
                child: Icon(
                  valueString[index] == Attribute.leftAlignment.value
                      ? _iconsData.leftAlignment
                      : valueString[index] == Attribute.centerAlignment.value
                          ? _iconsData.centerAlignment
                          : valueString[index] == Attribute.rightAlignment.value
                              ? _iconsData.rightAlignment
                              : _iconsData.justifyAlignment,
                  size: _iconSize,
                  color: valueToText[_value] == valueString[index]
                      ? (_iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (_iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
