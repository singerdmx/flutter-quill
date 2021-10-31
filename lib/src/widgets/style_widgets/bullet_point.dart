import 'package:flutter/material.dart';

class QuillBulletPoint extends StatelessWidget {
  const QuillBulletPoint({
    required this.style,
    required this.width,
    Key? key,
  }) : super(key: key);

  final TextStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: const EdgeInsetsDirectional.only(end: 13),
      child: Text('•', style: style),
    );
  }
}
