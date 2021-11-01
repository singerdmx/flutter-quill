import 'package:flutter/material.dart';

class QuillCheckbox extends StatelessWidget {
  const QuillCheckbox({
    Key? key,
    this.style,
    this.width,
    this.isChecked = false,
    this.offset,
    this.onTap,
    this.uiBuilder,
  }) : super(key: key);
  final TextStyle? style;
  final double? width;
  final bool isChecked;
  final int? offset;
  final Function(int, bool)? onTap;
  final QuillCheckboxBuilder? uiBuilder;

  void _onCheckboxClicked(bool? newValue) {
    if (onTap != null && newValue != null && offset != null) {
      onTap!(offset!, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (uiBuilder != null) {
      child = uiBuilder!.build(
        context: context,
        isChecked: isChecked,
        onChanged: _onCheckboxClicked,
      );
    } else {
      child = Container(
        alignment: AlignmentDirectional.topEnd,
        width: width,
        padding: const EdgeInsetsDirectional.only(end: 13),
        child: GestureDetector(
          onLongPress: () => _onCheckboxClicked(!isChecked),
          child: Checkbox(
            value: isChecked,
            onChanged: _onCheckboxClicked,
          ),
        ),
      );
    }

    return child;
  }
}

abstract class QuillCheckboxBuilder {
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required void Function(bool?) onChanged,
  });
}
