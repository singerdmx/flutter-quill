double getFontSize(dynamic sizeValue) {
  if (sizeValue.value is double) {
    return sizeValue;
  }

  if (sizeValue is int) {
    return sizeValue.toDouble();
  }

  double? fontSize;
  if (sizeValue is String) {
    fontSize = double.tryParse(sizeValue);
    if (fontSize == null) {
      throw 'Invalid size $sizeValue';
    }
  }
  return fontSize!;
}
