import 'package:flutter/material.dart' show TextStyle, immutable;
import '../../../../document/attribute.dart';

typedef PlaceholderConfigurationBuilder = PlaceholderArguments? Function(
    Attribute, TextStyle);

@immutable
/// Represents the arguments that builds the text that will
/// be displayed
class PlaceholderArguments {
  const PlaceholderArguments({
    required this.placeholderText,
    required this.style,
  });

  final String placeholderText;
  final TextStyle style;
}
