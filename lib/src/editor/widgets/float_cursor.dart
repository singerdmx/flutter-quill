// The corner radius of the floating cursor in pixels.
import 'dart:ui';

import 'cursor.dart';

const Radius _kFloatingCaretRadius = Radius.circular(1);

/// Floating painter responsible for painting the floating cursor when
/// floating mode is activated
class FloatingCursorPainter {
  FloatingCursorPainter({
    required this.floatingCursorRect,
    required this.style,
  });

  CursorStyle style;

  Rect? floatingCursorRect;

  final Paint floatingCursorPaint = Paint();

  void paint(Canvas canvas) {
    final floatingCursorRect = this.floatingCursorRect;
    final floatingCursorColor = style.color.withOpacity(0.75);
    if (floatingCursorRect == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(floatingCursorRect, _kFloatingCaretRadius),
      floatingCursorPaint..color = floatingCursorColor,
    );
  }
}
