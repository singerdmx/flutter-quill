import 'package:flutter/cupertino.dart';

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
