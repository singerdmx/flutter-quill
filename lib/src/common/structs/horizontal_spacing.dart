import 'package:flutter/foundation.dart' show immutable;

@immutable
class HorizontalSpacing {
  const HorizontalSpacing(
    this.left,
    this.right,
  );

  final double left;
  final double right;

  static const zero = HorizontalSpacing(0, 0);

  HorizontalSpacing copyWith({
    double? left,
    double? right,
  }) {
    return HorizontalSpacing(
      left ?? this.left,
      right ?? this.right,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorizontalSpacing && left == other.left && right == other.right;

  @override
  int get hashCode => Object.hash(left, right);
}
