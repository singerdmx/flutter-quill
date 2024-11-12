import 'package:flutter/widgets.dart';

class QuillBulletPoint extends StatelessWidget {
  const QuillBulletPoint({
    required this.style,
    required this.width,
    this.padding = 0,
    this.backgroundColor,
    this.textAlign,
    super.key,
  });

  final TextStyle style;
  final double width;
  final double padding;
  final Color? backgroundColor;
  final TextAlign? textAlign;

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
        textAlign: textAlign,
      ),
    );
  }
}
