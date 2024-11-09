import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' show ColorPicker, colorToHex;

import '../../../../translations.dart';
import '../../../document/style.dart';
import 'color_button.dart' show hexToColor;

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    required this.isBackground,
    required this.onRequestChangeColor,
    required this.isToggledColor,
    required this.selectionStyle,
    this.colorPickerSize,
    this.dialogBoxBgColor,
    this.applyButtonBgColo,
    this.cancleButtonBgColo,
    super.key,
  });
  final bool isBackground;
  final bool isToggledColor;
  final Function(BuildContext context, Color? color) onRequestChangeColor;
  final Style selectionStyle;
  final Size? colorPickerSize;
  final Color? dialogBoxBgColor;
  final Color? applyButtonBgColo;
  final Color? cancleButtonBgColo;

  @override
  State<ColorPickerDialog> createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  var selectedColor = Colors.black;
  // late void Function(void Function()) colorBoxSetState;
  late Color newcolor;

  @override
  void initState() {
    super.initState();
    if (widget.isToggledColor) {
      selectedColor = widget.isBackground
          ? hexToColor(widget.selectionStyle.attributes['background']?.value)
          : hexToColor(widget.selectionStyle.attributes['color']?.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    newcolor = selectedColor;

    return AlertDialog(
      title: Text(context.loc.selectColor),
      backgroundColor: widget.dialogBoxBgColor ?? Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      titlePadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      contentPadding: const EdgeInsets.all(8),
      insetPadding: const EdgeInsets.all(0),
      content: SingleChildScrollView(
        child: ColorPicker(
          colorPickerWidth: widget.colorPickerSize?.width ?? MediaQuery.of(context).size.width * 0.80,
          pickerColor: selectedColor,
          applyButtonBgColo: widget.applyButtonBgColo,
          cancleButtonBgColo: widget.cancleButtonBgColo,
          onColorChanged: (color) {
            newcolor = color;
            selectedColor = hexToColor(colorToHex(color));
          },
          onApplyClicked: () {
            widget.onRequestChangeColor(context, selectedColor);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
