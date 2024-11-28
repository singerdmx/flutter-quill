import 'package:flutter/material.dart' show TextStyle, immutable;
import '../../../../document/attribute.dart';

typedef PlaceholderComponentBuilder = PlaceholderTextBuilder? Function(
    Attribute, TextStyle);

@immutable
class PlaceholderConfig {
  const PlaceholderConfig({
    required this.builders,
    this.customBlockAttributesKeys,
  });

  factory PlaceholderConfig.base() {
    return const PlaceholderConfig(builders: {});
  }

  /// These attributes are used with the default ones
  /// to let us add placeholder to custom block attributes
  final Set<String>? customBlockAttributesKeys;
  final Map<String, PlaceholderComponentBuilder> builders;

  PlaceholderConfig copyWith({
    Map<String, PlaceholderComponentBuilder>? builders,
    Set<String>? customBlockAttributesKeys,
  }) {
    return PlaceholderConfig(
      builders: builders ?? this.builders,
      customBlockAttributesKeys:
          customBlockAttributesKeys ?? this.customBlockAttributesKeys,
    );
  }
}


/// Represents the text that will be displayed
@immutable
class PlaceholderTextBuilder {
  const PlaceholderTextBuilder({
    required this.placeholderText,
    required this.style,
  });

  final String placeholderText;
  final TextStyle style;
}
