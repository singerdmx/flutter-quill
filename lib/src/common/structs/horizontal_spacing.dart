import 'package:flutter/foundation.dart' show immutable;

@immutable
class HorizontalSpacing {
  const HorizontalSpacing(
    this.left,
    this.right,
  );

  final double left;
  final double right;
}
