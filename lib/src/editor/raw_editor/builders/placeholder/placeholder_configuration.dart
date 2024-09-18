import 'package:flutter/material.dart' show TextStyle, immutable;
import '../../../../document/attribute.dart';

typedef PlaceholderConfigurationBuilder = PlaceholderConfiguration? Function(
    Attribute, TextStyle);

@immutable

/// Represents the configurations that builds how will
/// be displayed the placeholder text
class PlaceholderConfiguration {
  const PlaceholderConfiguration({
    required this.placeholderText,
    required this.style,
  });

  final String placeholderText;
  final TextStyle style;
}
