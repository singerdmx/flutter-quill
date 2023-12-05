import 'package:flutter_quill/flutter_quill.dart' show Attribute;

String replaceStyleStringWithSize(
  String cssStyle, {
  required double width,
  required double height,
}) {
  final result = <String, String>{};
  final pairs = cssStyle.split(';');
  for (final pair in pairs) {
    final index = pair.indexOf(':');
    if (index < 0) {
      continue;
    }
    final key = pair.substring(0, index).trim();
    result[key] = pair.substring(index + 1).trim();
  }

  result[Attribute.width.key] = width.toString();
  result[Attribute.height.key] = height.toString();
  final sb = StringBuffer();
  for (final pair in result.entries) {
    sb
      ..write(pair.key)
      ..write(': ')
      ..write(pair.value)
      ..write('; ');
  }
  return sb.toString();
}
