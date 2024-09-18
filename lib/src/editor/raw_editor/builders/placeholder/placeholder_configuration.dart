import 'package:flutter/material.dart' show TextStyle, immutable;
import '../../../../document/attribute.dart';

typedef PlaceholderConfigurationBuilder = PlaceholderArguments? Function(
    Attribute, TextStyle);

@immutable
class PlaceholderComponentsConfiguration {
  const PlaceholderComponentsConfiguration({
    required this.builders,
    this.customBlockAttributesKeys,
  });

  factory PlaceholderComponentsConfiguration.base() {
    return const PlaceholderComponentsConfiguration(builders: {});
  }

  /// These attributes are used with the default ones
  /// to let us add placeholder to custom block attributes
  final Set<String>? customBlockAttributesKeys;
  final Map<String, PlaceholderConfigurationBuilder> builders;

  PlaceholderComponentsConfiguration copyWith({
    Map<String, PlaceholderConfigurationBuilder>? builders,
    Set<String>? customBlockAttributesKeys,
  }) {
    return PlaceholderComponentsConfiguration(
      builders: builders ?? this.builders,
      customBlockAttributesKeys:
          customBlockAttributesKeys ?? this.customBlockAttributesKeys,
    );
  }
}

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
