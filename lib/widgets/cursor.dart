import 'package:flutter/widgets.dart';

const Duration _FADE_DURATION = Duration(milliseconds: 250);

class CursorStyle {
  final Color color;
  final Color backgroundColor;
  final double width;
  final double height;
  final Radius radius;
  final Offset offset;
  final bool opacityAnimates;
  final bool paintAboveText;

  const CursorStyle({
    @required this.color,
    @required this.backgroundColor,
    this.width = 1.0,
    this.height,
    this.radius,
    this.offset,
    this.opacityAnimates = false,
    this.paintAboveText = false,
  })  : assert(color != null),
        assert(backgroundColor != null),
        assert(opacityAnimates != null),
        assert(paintAboveText != null);

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

class CursorCont extends ChangeNotifier {

  final ValueNotifier<bool> show;
  final ValueNotifier<bool> _blink;
  final ValueNotifier<Color> _color;
  AnimationController _blinkOpacityCont;
  CursorStyle _style;

  CursorCont({
    @required ValueNotifier<bool> show,
    @required CursorStyle style,
    @required TickerProvider tickerProvider,
  })  : assert(show != null),
        assert(style != null),
        assert(tickerProvider != null),
        show = show ?? ValueNotifier<bool>(false),
        _style = style,
        _blink = ValueNotifier(false),
        _color = ValueNotifier(style.color) {
    _blinkOpacityCont =
        AnimationController(vsync: tickerProvider, duration: _FADE_DURATION);
    _blinkOpacityCont.addListener(_onColorTick);
  }

  void _onColorTick() {
    _color.value = _style.color.withOpacity(_blinkOpacityCont.value);
    _blink.value = show.value && _blinkOpacityCont.value > 0;
  }
}
