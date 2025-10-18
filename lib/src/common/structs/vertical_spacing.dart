import 'package:flutter/foundation.dart' show immutable;

@immutable
class VerticalSpacing {
  const VerticalSpacing(
    this.top,
    this.bottom,
  );

  final double top;
  final double bottom;

  static const zero = VerticalSpacing(0, 0);

  VerticalSpacing copyWith({
    double? top,
    double? bottom,
  }) {
    return VerticalSpacing(
      top ?? this.top,
      bottom ?? this.bottom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerticalSpacing && top == other.top && bottom == other.bottom;

  @override
  int get hashCode => Object.hash(top, bottom);
}
