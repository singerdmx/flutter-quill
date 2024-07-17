import 'package:meta/meta.dart' show immutable;

@immutable
class VerticalSpacing {
  const VerticalSpacing(
    this.top,
    this.bottom,
  );

  final double top;
  final double bottom;
}
