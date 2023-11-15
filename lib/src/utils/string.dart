import 'package:flutter/cupertino.dart';

import '../models/documents/attribute.dart';

Map<String, String> parseKeyValuePairs(String s, Set<String> targetKeys) {
  final result = <String, String>{};
  final pairs = s.split(';');
  for (final pair in pairs) {
    final index = pair.indexOf(':');
    if (index < 0) {
      continue;
    }
    final key = pair.substring(0, index).trim();
    if (targetKeys.contains(key)) {
      result[key] = pair.substring(index + 1).trim();
    }
  }

  return result;
}

@Deprecated('This function is no longer used in flutter_quill')
String replaceStyleStringWithSize(
  String cssStyle, {
  required double width,
  required double height,
  required bool isMobile,
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

  if (isMobile) {
    result['mobileWidth'] = width.toString();
    result['mobileHeight'] = height.toString();
  } else {
    result[Attribute.width.key] = width.toString();
    result[Attribute.height.key] = height.toString();
  }
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

/// Get flutter [Alignment] value by [cssAlignment]
Alignment getAlignment(String? cssAlignment) {
  const defaultAlignment = Alignment.center;
  if (cssAlignment == null) {
    return defaultAlignment;
  }

  final index = [
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'center',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight'
  ].indexOf(cssAlignment);
  if (index < 0) {
    return defaultAlignment;
  }

  return [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight
  ][index];
}
