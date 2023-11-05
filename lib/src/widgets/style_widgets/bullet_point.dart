import 'package:flutter/material.dart';

class QuillEditorBulletPoint extends StatelessWidget {
  const QuillEditorBulletPoint({
    required this.style,
    required this.width,
    this.padding = 0,
    super.key,
  });

  final TextStyle style;
  final double width;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: EdgeInsetsDirectional.only(end: padding),
      child: Text('•', style: style),
    );
  }
}
