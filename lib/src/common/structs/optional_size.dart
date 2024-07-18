import 'package:flutter/foundation.dart' show immutable;

@immutable
class OptionalSize {
  const OptionalSize(
    this.width,
    this.height,
  );

  /// If non-null, requires the child to have exactly this width.
  /// If null, the child is free to choose its own width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  /// If null, the child is free to choose its own height.
  final double? height;

  OptionalSize copyWith({
    double? width,
    double? height,
  }) {
    return OptionalSize(
      width ?? this.width,
      height ?? this.height,
    );
  }
}
