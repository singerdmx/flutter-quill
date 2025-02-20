import 'dart:async';
import 'package:flutter/widgets.dart';
import 'styles/cursor_style.dart';

/// Controls the cursor of an editable widget.
///
/// This class is a [ChangeNotifier] and allows to listen for updates on the
/// cursor [style].
class CursorCont extends ChangeNotifier {
  CursorCont({
    required this.show,
    required CursorStyle style,
    required TickerProvider tickerProvider,
  })  : _style = style,
        blink = ValueNotifier(false),
        color = ValueNotifier(style.color) {
    _blinkOpacityController =
        AnimationController(vsync: tickerProvider, duration: _fadeDuration);
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
