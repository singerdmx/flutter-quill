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
/// The magnifier always stays inside the [Overlay] that shows it and inside
/// the screen, and it does not cover the system bars, such as the status bar.
/// Near an edge, it moves from its usual place above [dragPosition], but it
/// still shows the text at that point.
class QuillMagnifier extends StatelessWidget {
  const QuillMagnifier({required this.dragPosition, super.key});

  /// The point to magnify, in the coordinates of the [Overlay] that shows the
  /// magnifier.
  final Offset dragPosition;

  static const _magnifierSize = Size(100, 45);

  // The distance between `dragPosition` and the bottom edge of the magnifier.
  static const _gapAbovePoint = 22.0;

  // The area in which the magnifier is fully visible, in the coordinates of
  // the overlay that shows it: the part of the overlay that is on the screen
  // and not under the system bars. An app can make its root overlay smaller
  // than the screen, for example with `MaterialApp.builder`.
  static Rect _getVisibleArea(BuildContext context) {
    final safeArea = MediaQuery.paddingOf(
      context,
    ).deflateRect(Offset.zero & MediaQuery.sizeOf(context));
    final overlayBox = Overlay.maybeOf(context)?.context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) {
      return safeArea;
    }
    return (Offset.zero & overlayBox.size).intersect(
      Rect.fromPoints(
        overlayBox.globalToLocal(safeArea.topLeft),
        overlayBox.globalToLocal(safeArea.bottomRight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usualRect = Rect.fromCenter(
      center: dragPosition.translate(
        0,
        -_gapAbovePoint - _magnifierSize.height / 2,
      ),
      width: _magnifierSize.width,
      height: _magnifierSize.height,
    );
    final visibleArea = _getVisibleArea(context);
    // An area smaller than the magnifier cannot hold it anyway.
    final magnifierRect =
        visibleArea.width >= usualRect.width &&
            visibleArea.height >= usualRect.height
        ? MagnifierController.shiftWithinBounds(
            rect: usualRect,
            bounds: visibleArea,
          )
        : usualRect;
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
