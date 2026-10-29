import 'package:flutter/material.dart';

/// Builds the magnifier that is shown on Android and iOS while the user drags
/// a selection handle or selects text with a long press.
///
/// [dragPosition] is the point to magnify. Vertically, it is in the middle of
/// the line that is being selected. Horizontally, it moves with the drag, but
/// it stays between the two ends of that line.
///
/// The returned widget is shown in the root [Overlay], and [dragPosition] is
/// given in the coordinates of that overlay. Place the widget relative to
/// [dragPosition] with a [Positioned] widget, as [QuillMagnifier] does.
typedef QuillMagnifierBuilder = Widget Function(Offset dragPosition);

/// Builds a [QuillMagnifier]. Set `QuillEditorConfig.quillMagnifierBuilder` to
/// this function to enable the default magnifier.
Widget defaultQuillMagnifierBuilder(Offset dragPosition) =>
    QuillMagnifier(dragPosition: dragPosition);

/// A magnifier that appears above [dragPosition] and shows an enlarged view of
/// the text at that point.
///
/// The magnifier always stays inside the screen and does not cover the system
/// bars, such as the status bar. Near an edge of the screen, it moves from its
/// usual place above [dragPosition], but it still shows the text at that
/// point.
class QuillMagnifier extends StatelessWidget {
  const QuillMagnifier({required this.dragPosition, super.key});

  /// The point to magnify, in the coordinates of the [Overlay] that shows the
  /// magnifier.
  final Offset dragPosition;

  static const _magnifierSize = Size(100, 45);

  // The distance between `dragPosition` and the bottom edge of the magnifier.
  static const _gapAbovePoint = 22.0;

  @override
  Widget build(BuildContext context) {
    final magnifierRect = MagnifierController.shiftWithinBounds(
      rect: Rect.fromCenter(
        center: dragPosition.translate(
          0,
          -_gapAbovePoint - _magnifierSize.height / 2,
        ),
        width: _magnifierSize.width,
        height: _magnifierSize.height,
      ),
      bounds: MediaQuery.paddingOf(
        context,
      ).deflateRect(Offset.zero & MediaQuery.sizeOf(context)),
    );
    return Positioned.fromRect(
      rect: magnifierRect,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: RawMagnifier(
            clipBehavior: Clip.hardEdge,
            decoration: MagnifierDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(3, 3), // changes position of shadow
                ),
              ],
            ),
            size: _magnifierSize,
            focalPointOffset: dragPosition - magnifierRect.center,
            magnificationScale: 1.3,
          ),
        ),
      ),
    );
  }
}
