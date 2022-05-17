dynamic getFontSize(dynamic sizeValue) {
  if (sizeValue is String && ['small', 'large', 'huge'].contains(sizeValue)) {
    return sizeValue;
  }

  if (sizeValue is double) {
    return sizeValue;
  }

  if (sizeValue is int) {
    return sizeValue.toDouble();
  }

  assert(sizeValue is String);
  final fontSize = double.tryParse(sizeValue);
  if (fontSize == null) {
    throw 'Invalid size $sizeValue';
  }
  return fontSize;
}
