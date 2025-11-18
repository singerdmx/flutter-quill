import 'package:flutter/material.dart';

typedef QuillMagnifierBuilder = Widget Function(Offset dragPosition);

Widget defaultQuillMagnifierBuilder(Offset dragPosition) =>
    QuillMagnifier(dragPosition: dragPosition);

class QuillMagnifier extends StatelessWidget {
  const QuillMagnifier({required this.dragPosition, super.key});

  final Offset dragPosition;

  @override
  Widget build(BuildContext context) {
    final position = dragPosition.translate(-60, -80);
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: RawMagnifier(
          clipBehavior: Clip.hardEdge,
          decoration: MagnifierDecoration(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadows: const [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(3, 3), // changes position of shadow
              ),
            ],
          ),
          size: const Size(100, 45),
          focalPointOffset: const Offset(5, 55),
          magnificationScale: 1.3,
        ),
      ),
    );
  }
}
