Map<String, String> parseCssString(String cssString) {
  final result = <String, String>{};
  final declarations = cssString.split(';');

  for (final declaration in declarations) {
    final parts = declaration.split(':');
    if (parts.length == 2) {
      final property = parts[0].trim();
      final value = parts[1].trim();
      result[property] = value;
    }
  }

  return result;
}
