import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../translations/toolbar.i18n.dart';
import '../../../utils/color.dart';
import '../../../utils/extensions/build_context.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

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
  _QuillToolbarColorButtonState createState() =>
      _QuillToolbarColorButtonState();
}

class _QuillToolbarColorButtonState extends State<QuillToolbarColorButton> {
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
        (widget.isBackground ? Icons.color_lens : Icons.format_color_fill);
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        (widget.isBackground ? 'Font color'.i18n : 'Background color'.i18n);
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
        options,
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
      size: iconSize * kIconButtonFactor,
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
        widget.isBackground ? BackgroundAttribute(hex) : ColorAttribute(hex));
  }

  void _showColorPicker() {
    var pickerType = 'material';

    var selectedColor = Colors.black;

    if (_isToggledColor) {
      selectedColor = widget.isBackground
          ? hexToColor(_selectionStyle.attributes['background']?.value)
          : hexToColor(_selectionStyle.attributes['color']?.value);
    }

    final hexController =
        TextEditingController(text: colorToHex(selectedColor));
    late void Function(void Function()) colorBoxSetState;

    // TODO: Please make this dialog only responsible for picking the color
    // so in the future we will add an option for showing custom method
    // defined by the developer for picking dialog, and it will return
    // color hex

    // I won't for now to save some time for the refactoring
    showDialog<String>(
      context: context,
      barrierColor: options.dialogBarrierColor ??
          context.requireQuillSharedConfigurations.dialogBarrierColor,
      builder: (context) => StatefulBuilder(builder: (context, dlgSetState) {
        return AlertDialog(
            title: Text('Select Color'.i18n),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'.i18n)),
            ],
            backgroundColor: Theme.of(context).canvasColor,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            dlgSetState(() {
                              pickerType = 'material';
                            });
                          },
                          child: Text('Material'.i18n)),
                      TextButton(
                          onPressed: () {
                            dlgSetState(() {
                              pickerType = 'color';
                            });
                          },
                          child: Text('Color'.i18n)),
                    ],
                  ),
                  Column(children: [
                    if (pickerType == 'material')
                      MaterialPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          _changeColor(context, color);
                          Navigator.of(context).pop();
                        },
                      ),
                    if (pickerType == 'color')
                      ColorPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          _changeColor(context, color);
                          hexController.text = colorToHex(color);
                          selectedColor = color;
                          colorBoxSetState(() {});
                        },
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 60,
                          child: TextFormField(
                            controller: hexController,
                            onChanged: (value) {
                              selectedColor = hexToColor(value);
                              _changeColor(context, selectedColor);

                              colorBoxSetState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: 'Hex'.i18n,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        StatefulBuilder(builder: (context, mcolorBoxSetState) {
                          colorBoxSetState = mcolorBoxSetState;
                          return Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black45,
                              ),
                              color: selectedColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ],
                    ),
                  ])
                ],
              ),
            ));
      }),
    );
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
}
