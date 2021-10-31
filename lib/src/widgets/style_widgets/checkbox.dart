import 'package:flutter/material.dart';

class QuillCheckbox extends StatelessWidget {
  const QuillCheckbox({
    Key? key,
    this.style,
    this.width,
    this.isChecked = false,
    this.offset,
    this.onTap,
  }) : super(key: key);
  final TextStyle? style;
  final double? width;
  final bool isChecked;
  final int? offset;
  final Function(int, bool)? onTap;

  void _onCheckboxClicked(bool? newValue) {
    if (onTap != null && newValue != null && offset != null) {
      onTap!(offset!, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
}
