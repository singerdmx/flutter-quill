import 'package:flutter/material.dart';

class QuillEditorBulletPoint extends StatelessWidget {
  const QuillEditorBulletPoint({
    required this.style,
    required this.width,
    this.padding = 0,
    this.backgroundColor,
    super.key,
  });

  final TextStyle style;
  final double width;
  final double padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: EdgeInsetsDirectional.only(end: padding),
      color: backgroundColor,
      child: Text(
        '•',
        style: style,
      ),
    );
  }
}
