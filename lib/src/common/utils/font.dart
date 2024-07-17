import '../../../flutter_quill.dart';

dynamic getFontSize(dynamic sizeValue) {
  if (sizeValue is String &&
      ['small', 'normal', 'large', 'huge'].contains(sizeValue)) {
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
    throw ArgumentError('Invalid size $sizeValue');
  }
  return fontSize;
}

double? getFontSizeAsDouble(dynamic sizeValue,
    {required DefaultStyles defaultStyles}) {
  if (sizeValue is String &&
      ['small', 'normal', 'large', 'huge'].contains(sizeValue)) {
    return switch (sizeValue) {
      'small' => defaultStyles.sizeSmall?.fontSize,
      'normal' => null,
      'large' => defaultStyles.sizeLarge?.fontSize,
      'huge' => defaultStyles.sizeHuge?.fontSize,
      String() => throw ArgumentError(),
    };
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
    throw ArgumentError('Invalid size $sizeValue');
  }
  return fontSize;
}
