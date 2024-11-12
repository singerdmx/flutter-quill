import 'package:flutter/material.dart';

Color hexToColor(String? hexString) {
  if (hexString == null) {
    return Colors.black;
  }
  final hexRegex = RegExp(r'([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');

  hexString = hexString.replaceAll('#', '');
  if (!hexRegex.hasMatch(hexString)) {
    return Colors.black;
  }

  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString);
  return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF000000);
}

String colorToHex(Color color) {
  return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
}
