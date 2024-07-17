import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    show ColorPicker, MaterialPicker, colorToHex;

import '../../../../translations.dart';
import '../../../document/style.dart';
import 'color_button.dart' show hexToColor;

enum _PickerType {
  material,
  color,
}

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    required this.isBackground,
    required this.onRequestChangeColor,
    required this.isToggledColor,
    required this.selectionStyle,
    super.key,
  });
  final bool isBackground;

  final bool isToggledColor;
  final Function(BuildContext context, Color? color) onRequestChangeColor;
  final Style selectionStyle;

  @override
  State<ColorPickerDialog> createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  var pickerType = _PickerType.material;
  var selectedColor = Colors.black;

  late final TextEditingController hexController;
  late void Function(void Function()) colorBoxSetState;

  @override
  void initState() {
    super.initState();
    hexController = TextEditingController(text: colorToHex(selectedColor));
    if (widget.isToggledColor) {
      selectedColor = widget.isBackground
          ? hexToColor(widget.selectionStyle.attributes['background']?.value)
          : hexToColor(widget.selectionStyle.attributes['color']?.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.selectColor),
      actions: [
        TextButton(
            onPressed: () {
              widget.onRequestChangeColor(context, selectedColor);
              Navigator.of(context).pop();
            },
            child: Text(context.loc.ok)),
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
                    setState(() {
                      pickerType = _PickerType.material;
                    });
                  },
                  child: Text(context.loc.material),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      pickerType = _PickerType.color;
                    });
                  },
                  child: Text(context.loc.color),
                ),
                TextButton(
                  onPressed: () {
                    widget.onRequestChangeColor(context, null);
                    Navigator.of(context).pop();
                  },
                  child: Text(context.loc.clear),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              children: [
                if (pickerType == _PickerType.material)
                  MaterialPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      widget.onRequestChangeColor(context, color);
                      Navigator.of(context).pop();
                    },
                  ),
                if (pickerType == _PickerType.color)
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      widget.onRequestChangeColor(context, color);
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
                          colorBoxSetState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: context.loc.hex,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    StatefulBuilder(
                      builder: (context, mcolorBoxSetState) {
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
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
