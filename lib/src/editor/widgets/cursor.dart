import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/widgets.dart';

import 'box.dart';

/// Style properties of editing cursor.
class CursorStyle {
  const CursorStyle({
    required this.color,
    required this.backgroundColor,
    this.platform,
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

  /// The platform whose caret geometry should be used.
  ///
  /// If null, [defaultTargetPlatform] is used. High-level editors pass their
  /// effective theme platform so style defaults and geometry cannot diverge
  /// when the theme platform is overridden.
  final TargetPlatform? platform;

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
  /// If null, no additional offset is applied. High-level editors provide
  /// their platform-specific default offset.
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
          platform == other.platform &&
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
      platform.hashCode ^
      width.hashCode ^
      height.hashCode ^
      radius.hashCode ^
      offset.hashCode ^
      opacityAnimates.hashCode ^
      paintAboveText.hashCode;
}

/// Controls the cursor of an editable widget.
///
/// This class is a [ChangeNotifier] and allows to listen for updates on the
/// cursor [style].
class CursorCont extends ChangeNotifier {
  CursorCont({
    required this.show,
    required CursorStyle style,
    required TickerProvider tickerProvider,
  }) : _style = style,
       blink = ValueNotifier(false),
       color = ValueNotifier(style.color) {
    _blinkOpacityController = AnimationController(
      vsync: tickerProvider,
      duration: _fadeDuration,
    );
    _blinkOpacityController.addListener(_onColorTick);
  }

  // The time it takes for the cursor to fade from fully opaque to fully
  // transparent and vice versa. A full cursor blink, from transparent to opaque
  // to transparent, is twice this duration.
  static const Duration _blinkHalfPeriod = Duration(milliseconds: 500);

  // The time the cursor is static in opacity before animating to become
  // transparent.
  static const Duration _blinkWaitForStart = Duration(milliseconds: 150);

  // This value is an eyeball estimation of the time it takes for the iOS cursor
  // to ease in and out.
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  final ValueNotifier<bool> show;
  final ValueNotifier<Color> color;
  final ValueNotifier<bool> blink;

  late final AnimationController _blinkOpacityController;

  Timer? _cursorTimer;
  bool _targetCursorVisibility = false;

  final ValueNotifier<TextPosition?> _floatingCursorTextPosition =
      ValueNotifier(null);

  ValueNotifier<TextPosition?> get floatingCursorTextPosition =>
      _floatingCursorTextPosition;

  void setFloatingCursorTextPosition(TextPosition? position) =>
      _floatingCursorTextPosition.value = position;

  bool get isFloatingCursorActive => floatingCursorTextPosition.value != null;

  CursorStyle _style;
  CursorStyle get style => _style;
  set style(CursorStyle value) {
    if (_style == value) return;
    _style = value;
    notifyListeners();
  }

  /// True when this [CursorCont] instance has been disposed.
  ///
  /// A safety mechanism to prevent the value of a disposed controller from
  /// getting set.
  bool _isDisposed = false;

  @override
  void dispose() {
    _blinkOpacityController.removeListener(_onColorTick);
    stopCursorTimer();

    _isDisposed = true;
    _blinkOpacityController.dispose();
    show.dispose();
    blink.dispose();
    color.dispose();
    assert(_cursorTimer == null);
    super.dispose();
  }

  void _cursorTick(Timer timer) {
    _targetCursorVisibility = !_targetCursorVisibility;
    final targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;
    if (style.opacityAnimates) {
      // If we want to show the cursor, we will animate the opacity to the value
      // of 1.0, and likewise if we want to make it disappear, to 0.0. An easing
      // curve is used for the animation to mimic the aesthetics of the native
      // iOS cursor.
      //
      // These values and curves have been obtained through eyeballing, so are
      // likely not exactly the same as the values for native iOS.
      _blinkOpacityController.animateTo(targetOpacity, curve: Curves.easeOut);
    } else {
      _blinkOpacityController.value = targetOpacity;
    }
  }

  void _waitForStart(Timer timer) {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(_blinkHalfPeriod, _cursorTick);
  }

  void startCursorTimer() {
    if (_isDisposed) {
      return;
    }

    _targetCursorVisibility = true;
    _blinkOpacityController.value = 1.0;

    if (style.opacityAnimates) {
      _cursorTimer = Timer.periodic(_blinkWaitForStart, _waitForStart);
    } else {
      _cursorTimer = Timer.periodic(_blinkHalfPeriod, _cursorTick);
    }
  }

  void stopCursorTimer({bool resetCharTicks = true}) {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _targetCursorVisibility = false;
    _blinkOpacityController.value = 0.0;

    if (style.opacityAnimates) {
      _blinkOpacityController
        ..stop()
        ..value = 0.0;
    }
  }

  void startOrStopCursorTimerIfNeeded(bool hasFocus, TextSelection selection) {
    if (show.value &&
        _cursorTimer == null &&
        hasFocus &&
        selection.isCollapsed) {
      startCursorTimer();
    } else if (_cursorTimer != null && (!hasFocus || !selection.isCollapsed)) {
      stopCursorTimer();
    }
  }

  void _onColorTick() {
    color.value = _style.color.withValues(alpha: _blinkOpacityController.value);
    blink.value = show.value && _blinkOpacityController.value > 0;
  }
}

/// Paints the editing cursor.
class CursorPainter {
  CursorPainter({
    required RenderContentProxyBox? editable,
    required this.style,
    required this.prototype,
    required this.color,
    required this.devicePixelRatio,
  }) : editable = editable ?? (throw ArgumentError.notNull('editable'));

  final RenderContentProxyBox editable;
  final CursorStyle style;
  final Rect prototype;
  final Color color;
  final double devicePixelRatio;

  /// Returns the exact caret rectangle that [paint] draws, in [editable]'s
  /// local coordinate system.
  ///
  /// Keeping caret geometry in one method ensures text input, scrolling and
  /// painting all observe the same rectangle.
  Rect getLocalRectForCaret(TextPosition position, bool lineHasEmbed) {
    var relativeCaretOffset = editable.getOffsetForCaret(position, prototype);
    if (lineHasEmbed && relativeCaretOffset == Offset.zero) {
      relativeCaretOffset = editable.getOffsetForCaret(
        TextPosition(offset: position.offset - 1, affinity: position.affinity),
        prototype,
      );
      // Hardcoded 6 as estimate of the width of a character.
      relativeCaretOffset = Offset(
        relativeCaretOffset.dx + 6,
        relativeCaretOffset.dy,
      );
    }

    var caretRect = prototype.shift(
      relativeCaretOffset + (style.offset ?? Offset.zero),
    );

    if (caretRect.left < 0.0) {
      // Apple cursors have a negative horizontal offset and would otherwise be
      // clipped at the beginning of a line.
      caretRect = caretRect.shift(Offset(-caretRect.left, 0));
    }

    final fullHeight = editable.getFullHeightForCaret(position);
    if (fullHeight != null) {
      switch (style.platform ?? defaultTargetPlatform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          final heightDiff = fullHeight - caretRect.height;
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top + heightDiff / 2,
            caretRect.width,
            caretRect.height,
          );
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          final caretHeight = style.height ?? editable.preferredLineHeight;
          final heightDiff = fullHeight - caretHeight;
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top - 2.0 + heightDiff / 2,
            caretRect.width,
            caretHeight,
          );
      }
    }

    final pixelPerfectOffset = _getPixelPerfectCursorOffset(caretRect);
    return caretRect.shift(pixelPerfectOffset);
  }

  /// Paints cursor on [canvas] at specified [position].
  /// [offset] is global top left (x, y) of text line
  /// [position] is relative (x) in text line
  void paint(
    Canvas canvas,
    Offset offset,
    TextPosition position,
    bool lineHasEmbed,
  ) {
    final localCaretRect = getLocalRectForCaret(position, lineHasEmbed);
    final caretRect = localCaretRect.shift(offset);

    final paint = Paint()..color = color;
    if (style.radius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final caretRRect = RRect.fromRectAndRadius(caretRect, style.radius!);
      canvas.drawRRect(caretRRect, paint);
    }
  }

  Offset _getPixelPerfectCursorOffset(Rect caretRect) {
    final caretPosition = editable.localToGlobal(caretRect.topLeft);
    final pixelMultiple = 1.0 / devicePixelRatio;

    final pixelPerfectOffsetX = caretPosition.dx.isFinite
        ? (caretPosition.dx / pixelMultiple).round() * pixelMultiple -
              caretPosition.dx
        : 0.0;
    final pixelPerfectOffsetY = caretPosition.dy.isFinite
        ? (caretPosition.dy / pixelMultiple).round() * pixelMultiple -
              caretPosition.dy
        : 0.0;

    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }
}
