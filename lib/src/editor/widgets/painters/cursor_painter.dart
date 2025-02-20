import 'dart:ui';
import '../../../common/utils/platform.dart';
import '../box.dart';
import '../styles/cursor_style.dart';

/// Paints the editing cursor.
class CursorPainter {
  CursorPainter({
    required this.editable,
    required this.style,
    required this.prototype,
    required this.color,
    required this.devicePixelRatio,
  });

  final RenderContentProxyBox? editable;
  final CursorStyle style;
  final Rect prototype;
  final Color color;
  final double devicePixelRatio;

  /// Paints cursor on [canvas] at specified [position].
  /// [offset] is global top left (x, y) of text line
  /// [position] is relative (x) in text line
  void paint(
    Canvas canvas,
    Offset offset,
    TextPosition position,
    bool lineHasEmbed,
  ) {
    // relative (x, y) to global offset
    var relativeCaretOffset = editable!.getOffsetForCaret(position, prototype);
    if (lineHasEmbed && relativeCaretOffset == Offset.zero) {
      relativeCaretOffset = editable!.getOffsetForCaret(
          TextPosition(
              offset: position.offset - 1, affinity: position.affinity),
          prototype);
      // Hardcoded 6 as estimate of the width of a character
      relativeCaretOffset =
          Offset(relativeCaretOffset.dx + 6, relativeCaretOffset.dy);
    }

    final caretOffset = relativeCaretOffset + offset;
    var caretRect = prototype.shift(caretOffset);
    if (style.offset != null) {
      caretRect = caretRect.shift(style.offset!);
    }

    if (caretRect.left < 0.0) {
      // For iOS the cursor may get clipped by the scroll view when
      // it's located at a beginning of a line. We ensure that this
      // does not happen here. This may result in the cursor being painted
      // closer to the character on the right, but it's arguably better
      // then painting clipped cursor (or even cursor completely hidden).
      caretRect = caretRect.shift(Offset(-caretRect.left, 0));
    }

    final caretHeight = editable!.getFullHeightForCaret(position);
    if (caretHeight != null) {
      if (isAppleOSApp) {
        // Center the caret vertically along the text.
        caretRect = Rect.fromLTWH(
          caretRect.left,
          caretRect.top + (caretHeight - caretRect.height) / 2,
          caretRect.width,
          caretRect.height,
        );
      } else {
        // Override the height to take the full height of the glyph at the
        // TextPosition when not on iOS. iOS has special handling that
        // creates a taller caret.
        caretRect = Rect.fromLTWH(
          caretRect.left,
          caretRect.top - 2.0,
          caretRect.width,
          caretHeight,
        );
      }
    }

    final pixelPerfectOffset = _getPixelPerfectCursorOffset(caretRect);
    if (!pixelPerfectOffset.isFinite) {
      return;
    }
    caretRect = caretRect.shift(pixelPerfectOffset);

    final paint = Paint()..color = color;
    if (style.radius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final caretRRect = RRect.fromRectAndRadius(caretRect, style.radius!);
      canvas.drawRRect(caretRRect, paint);
    }
  }

  Offset _getPixelPerfectCursorOffset(
    Rect caretRect,
  ) {
    final caretPosition = editable!.localToGlobal(caretRect.topLeft);
    final pixelMultiple = 1.0 / devicePixelRatio;

    final pixelPerfectOffsetX = caretPosition.dx.isFinite
        ? (caretPosition.dx / pixelMultiple).round() * pixelMultiple -
            caretPosition.dx
        : caretPosition.dx;
    final pixelPerfectOffsetY = caretPosition.dy.isFinite
        ? (caretPosition.dy / pixelMultiple).round() * pixelMultiple -
            caretPosition.dy
        : caretPosition.dy;

    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }
}
