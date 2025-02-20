import 'dart:ui';

/// Style properties of editing cursor.
class CursorStyle {
  const CursorStyle({
    required this.color,
    required this.backgroundColor,
    this.width = 1.0,
    this.height,
    this.radius,
    this.offset,
    this.opacityAnimates = false,
    this.paintAboveText = false,
  });

  /// The color to use when painting the cursor.
  final Color color;

  /// The color to use when painting the background cursor aligned with the text
  /// while rendering the floating cursor.
  final Color backgroundColor;

  /// How thick the cursor will be.
  ///
  /// The cursor will draw under the text. The cursor width will extend
  /// to the right of the boundary between characters for left-to-right text
  /// and to the left for right-to-left text. This corresponds to extending
  /// downstream relative to the selected position. Negative values may be used
  /// to reverse this behavior.
  final double width;

  /// How tall the cursor will be.
  ///
  /// By default, the cursor height is set to the preferred line height of the
  /// text.
  final double? height;

  /// How rounded the corners of the cursor should be.
  ///
  /// By default, the cursor has no radius.
  final Radius? radius;

  /// The offset that is used, in pixels, when painting the cursor on screen.
  ///
  /// By default, the cursor position should be set to an offset of
  /// (-[cursorWidth] * 0.5, 0.0) on iOS platforms and (0, 0) on Android
  /// platforms. The origin from where the offset is applied to is the arbitrary
  /// location where the cursor ends up being rendered from by default.
  final Offset? offset;

  /// Whether the cursor will animate from fully transparent to fully opaque
  /// during each cursor blink.
  ///
  /// By default, the cursor opacity will animate on iOS platforms and will not
  /// animate on Android platforms.
  final bool opacityAnimates;

  /// If the cursor should be painted on top of the text or underneath it.
  ///
  /// By default, the cursor should be painted on top for iOS platforms and
  /// underneath for Android platforms.
  final bool paintAboveText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorStyle &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          backgroundColor == other.backgroundColor &&
          width == other.width &&
          height == other.height &&
          radius == other.radius &&
          offset == other.offset &&
          opacityAnimates == other.opacityAnimates &&
          paintAboveText == other.paintAboveText;

  @override
  int get hashCode =>
      color.hashCode ^
      backgroundColor.hashCode ^
      width.hashCode ^
      height.hashCode ^
      radius.hashCode ^
      offset.hashCode ^
      opacityAnimates.hashCode ^
      paintAboveText.hashCode;
}
