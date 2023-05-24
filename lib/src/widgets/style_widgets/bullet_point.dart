import 'package:flutter/material.dart';

class QuillBulletPoint extends StatelessWidget {
  const QuillBulletPoint({
    required this.style,
    required this.width,
    this.padding = 0,
    Key? key,
  }) : super(key: key);

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
