class OffsetValue<T> {
  OffsetValue(this.offset, this.value, [this.length]);
  final int offset;
  final int? length;
  final T value;
}
