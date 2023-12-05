import 'package:flutter/widgets.dart' show BuildContext, MediaQuery;

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

enum _CssUnit {
  px('px'),
  percentage('%'),
  viewportWidth('vw'),
  viewportHeight('vh'),
  em('em'),
  rem('rem'),
  invalid('invalid');

  const _CssUnit(this.cssName);

  final String cssName;
}

double? parseCssPropertyAsDouble(
  String value, {
  required BuildContext context,
}) {
  if (value.trim().isEmpty) {
    return null;
  }

  // Try to parse it in case it's a valid double already
  var doubleValue = double.tryParse(value);

  if (doubleValue != null) {
    return doubleValue;
  }

  // If not then if it's a css numberic value then we will try to parse it
  final unit = _CssUnit.values
      .where((element) => value.endsWith(element.cssName))
      .firstOrNull;
  if (unit == null) {
    return null;
  }
  value = value.replaceFirst(unit.cssName, '');
  doubleValue = double.tryParse(value);
  if (doubleValue != null) {
    switch (unit) {
      case _CssUnit.px:
        // Do nothing
        break;
      case _CssUnit.percentage:
        // Not supported yet
        doubleValue = null;
        break;
      case _CssUnit.viewportWidth:
        doubleValue = (doubleValue / 100) * MediaQuery.sizeOf(context).width;
        break;
      case _CssUnit.viewportHeight:
        doubleValue = (doubleValue / 100) * MediaQuery.sizeOf(context).height;
        break;
      case _CssUnit.em:
        doubleValue = MediaQuery.textScalerOf(context).scale(doubleValue);
        break;
      case _CssUnit.rem:
        // Not fully supported yet
        doubleValue = MediaQuery.textScalerOf(context).scale(doubleValue);
        break;
      case _CssUnit.invalid:
        // Ignore
        doubleValue = null;
        break;
    }
  }
  return doubleValue;
}
