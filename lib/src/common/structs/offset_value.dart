import 'package:flutter/foundation.dart' show immutable;

@immutable
class OffsetValue<T> {
  const OffsetValue(this.offset, this.value, [this.length]);
  final int offset;
  final int? length;
  final T value;
}
