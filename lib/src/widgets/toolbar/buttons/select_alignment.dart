import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../translations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/extensions/build_context.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';
import '../toolbar.dart';

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
  _QuillToolbarSelectAlignmentButtonState createState() =>
      _QuillToolbarSelectAlignmentButtonState();
}

class _QuillToolbarSelectAlignmentButtonState
    extends State<QuillToolbarSelectAlignmentButton> {
  Attribute? _value;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    });
    widget.controller.addListener(_didChangeEditingValue);
  }

  QuillToolbarSelectAlignmentButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return options.controller ?? widget.controller;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
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
      leftAlignment: 'Align left'.i18n,
      centerAlignment: 'Align center'.i18n,
      rightAlignment: 'Align right'.i18n,
      justifyAlignment: 'Justify win width'.i18n,
    );
  }

  /// Since it's not safe to call anything related to the context in dispose
  /// then we will save a reference to the [controller]
  /// and update it in [didChangeDependencies]
  /// and use it in dispose method
  late QuillController _controller;

  void _didChangeEditingValue() {
    setState(() {
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    });
  }

  @override
  void didUpdateWidget(covariant QuillToolbarSelectAlignmentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = controller;
  }

  @override
  void dispose() {
    _controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _valueToText = <Attribute, String>{
      if (widget.showLeftAlignment!)
        Attribute.leftAlignment: Attribute.leftAlignment.value!,
      if (widget.showCenterAlignment!)
        Attribute.centerAlignment: Attribute.centerAlignment.value!,
      if (widget.showRightAlignment!)
        Attribute.rightAlignment: Attribute.rightAlignment.value!,
      if (widget.showJustifyAlignment!)
        Attribute.justifyAlignment: Attribute.justifyAlignment.value!,
    };

    final _valueAttribute = <Attribute>[
      if (widget.showLeftAlignment!) Attribute.leftAlignment,
      if (widget.showCenterAlignment!) Attribute.centerAlignment,
      if (widget.showRightAlignment!) Attribute.rightAlignment,
      if (widget.showJustifyAlignment!) Attribute.justifyAlignment
    ];
    final _valueString = <String>[
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

    final theme = Theme.of(context);

    final buttonCount = ((widget.showLeftAlignment!) ? 1 : 0) +
        ((widget.showCenterAlignment!) ? 1 : 0) +
        ((widget.showRightAlignment!) ? 1 : 0) +
        ((widget.showJustifyAlignment!) ? 1 : 0);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;

    if (childBuilder != null) {
      throw UnsupportedError(
        'Sorry but the `childBuilder` for the Select alignment button'
        ' is not supported. Yet but we will work on that soon.',
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttonCount, (index) {
        return Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: iconSize * kIconButtonFactor,
              height: iconSize * kIconButtonFactor,
            ),
            child: UtilityWidgets.maybeTooltip(
              message: _valueString[index] == Attribute.leftAlignment.value
                  ? _tooltips.leftAlignment
                  : _valueString[index] == Attribute.centerAlignment.value
                      ? _tooltips.centerAlignment
                      : _valueString[index] == Attribute.rightAlignment.value
                          ? _tooltips.rightAlignment
                          : _tooltips.justifyAlignment,
              child: RawMaterialButton(
                hoverElevation: 0,
                highlightElevation: 0,
                elevation: 0,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(iconTheme?.borderRadius ?? 2)),
                fillColor: _valueToText[_value] == _valueString[index]
                    ? (iconTheme?.iconSelectedFillColor ??
                        Theme.of(context).primaryColor)
                    : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
                onPressed: () {
                  _valueAttribute[index] == Attribute.leftAlignment
                      ? widget.controller.formatSelection(
                          Attribute.clone(Attribute.align, null),
                        )
                      : widget.controller
                          .formatSelection(_valueAttribute[index]);
                  afterButtonPressed?.call();
                },
                child: Icon(
                  _valueString[index] == Attribute.leftAlignment.value
                      ? _iconsData.leftAlignment
                      : _valueString[index] == Attribute.centerAlignment.value
                          ? _iconsData.centerAlignment
                          : _valueString[index] ==
                                  Attribute.rightAlignment.value
                              ? _iconsData.rightAlignment
                              : _iconsData.justifyAlignment,
                  size: iconSize,
                  color: _valueToText[_value] == _valueString[index]
                      ? (iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (iconTheme?.iconUnselectedColor ??
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
