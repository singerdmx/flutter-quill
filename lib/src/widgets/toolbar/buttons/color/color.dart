import 'package:flutter/material.dart';

import '../../../../extensions/quill_provider.dart';
import '../../../../l10n/extensions/localizations.dart';
import '../../../../l10n/widgets/localizations.dart';
import '../../../../models/documents/attribute.dart';
import '../../../../models/documents/style.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../../utils/color.dart';
import '../../../controller.dart';
import '../../../utils/provider.dart';
import '../../base_toolbar.dart';
import 'dialog.dart';

/// Controls color styles.
///
/// When pressed, this button displays overlay toolbar with
/// buttons for each color.
class QuillToolbarColorButton extends StatefulWidget {
  const QuillToolbarColorButton({
    required this.controller,
    required this.isBackground,
    this.options = const QuillToolbarColorButtonOptions(),
    super.key,
  });

  /// Is this background color button or font color
  final bool isBackground;
  final QuillController controller;
  final QuillToolbarColorButtonOptions options;

  @override
  QuillToolbarColorButtonState createState() => QuillToolbarColorButtonState();
}

class QuillToolbarColorButtonState extends State<QuillToolbarColorButton> {
  late bool _isToggledColor;
  late bool _isToggledBackground;
  late bool _isWhite;
  late bool _isWhiteBackground;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _isToggledColor =
          _getIsToggledColor(widget.controller.getSelectionStyle().attributes);
      _isToggledBackground = _getIsToggledBackground(
          widget.controller.getSelectionStyle().attributes);
      _isWhite = _isToggledColor &&
          _selectionStyle.attributes['color']!.value == '#ffffff';
      _isWhiteBackground = _isToggledBackground &&
          _selectionStyle.attributes['background']!.value == '#ffffff';
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggledColor = _getIsToggledColor(_selectionStyle.attributes);
    _isToggledBackground = _getIsToggledBackground(_selectionStyle.attributes);
    _isWhite = _isToggledColor &&
        _selectionStyle.attributes['color']!.value == '#ffffff';
    _isWhiteBackground = _isToggledBackground &&
        _selectionStyle.attributes['background']!.value == '#ffffff';
    widget.controller.addListener(_didChangeEditingValue);
  }

  bool _getIsToggledColor(Map<String, Attribute> attrs) {
    return attrs.containsKey(Attribute.color.key);
  }

  bool _getIsToggledBackground(Map<String, Attribute> attrs) {
    return attrs.containsKey(Attribute.background.key);
  }

  @override
  void didUpdateWidget(covariant QuillToolbarColorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggledColor = _getIsToggledColor(_selectionStyle.attributes);
      _isToggledBackground =
          _getIsToggledBackground(_selectionStyle.attributes);
      _isWhite = _isToggledColor &&
          _selectionStyle.attributes['color']!.value == '#ffffff';
      _isWhiteBackground = _isToggledBackground &&
          _selectionStyle.attributes['background']!.value == '#ffffff';
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  QuillToolbarColorButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return widget.controller;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
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

  IconData get iconData {
    return options.iconData ??
        baseButtonExtraOptions.iconData ??
        (widget.isBackground ? Icons.format_color_fill : Icons.color_lens);
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        (widget.isBackground
            ? context.loc.backgroundColor
            : context.loc.fontColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _isToggledColor && !widget.isBackground && !_isWhite
        ? stringToColor(_selectionStyle.attributes['color']!.value)
        : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color);

    final iconColorBackground =
        _isToggledBackground && widget.isBackground && !_isWhiteBackground
            ? stringToColor(_selectionStyle.attributes['background']!.value)
            : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color);

    final fillColor = _isToggledColor && !widget.isBackground && _isWhite
        ? stringToColor('#ffffff')
        : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor);
    final fillColorBackground =
        _isToggledBackground && widget.isBackground && _isWhiteBackground
            ? stringToColor('#ffffff')
            : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;
    if (childBuilder != null) {
      // if the caller using Cupertino app he might need to wrap the builder
      // with Material() widget
      return childBuilder(
        QuillToolbarColorButtonOptions(
          afterButtonPressed: afterButtonPressed,
          dialogBarrierColor: options.dialogBarrierColor,
          tooltip: tooltip,
          iconTheme: iconTheme,
          iconSize: iconSize,
          iconData: iconData,
          iconButtonFactor: iconButtonFactor,
          customOnPressedCallback: options.customOnPressedCallback,
        ),
        QuillToolbarColorButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _showColorPicker();
            afterButtonPressed?.call();
          },
          iconColor: null,
          iconColorBackground: iconColorBackground,
          fillColor: fillColor,
          fillColorBackground: fillColorBackground,
        ),
      );
    }

    return QuillToolbarIconButton(
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * iconButtonFactor,
      icon: Icon(iconData,
          size: iconSize,
          color: widget.isBackground ? iconColorBackground : iconColor),
      fillColor: widget.isBackground ? fillColorBackground : fillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: _showColorPicker,
      afterPressed: afterButtonPressed,
    );
  }

  void _changeColor(BuildContext context, Color color) {
    var hex = colorToHex(color);
    hex = '#$hex';
    widget.controller.formatSelection(
      widget.isBackground ? BackgroundAttribute(hex) : ColorAttribute(hex),
    );
  }

  Future<void> _showColorPicker() async {
    final customCallback = options.customOnPressedCallback;
    if (customCallback != null) {
      await customCallback(controller, widget.isBackground);
      return;
    }
    showDialog<String>(
      context: context,
      barrierColor: options.dialogBarrierColor ??
          context.requireQuillSharedConfigurations.dialogBarrierColor,
      builder: (_) => QuillProvider.value(
        value: context.requireQuillProvider,
        child: FlutterQuillLocalizationsWidget(
          child: ColorPickerDialog(
            isBackground: widget.isBackground,
            onRequestChangeColor: _changeColor,
            isToggledColor: _isToggledColor,
            selectionStyle: _selectionStyle,
          ),
        ),
      ),
    );
  }
}

Color hexToColor(String? hexString) {
  if (hexString == null) {
    return Colors.black;
  }
  final hexRegex = RegExp(r'([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');

  hexString = hexString.replaceAll('#', '');
  if (!hexRegex.hasMatch(hexString)) {
    return Colors.black;
  }

  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString);
  return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF000000);
}

String colorToHex(Color color) {
  return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
}
