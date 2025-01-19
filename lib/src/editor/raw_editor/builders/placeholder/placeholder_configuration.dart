import 'package:flutter/material.dart' show TextStyle;
import 'package:meta/meta.dart' show experimental, immutable;
import '../../../../document/attribute.dart';

typedef PlaceholderComponentBuilder = PlaceholderTextBuilder? Function(
    Attribute, TextStyle);

/// Configuration class for defining how placeholders are handled in the editor.
///
/// The `PlaceholderConfig` allows customization of placeholder behavior by
/// providing builders for rendering specific components and defining custom
/// attribute keys that should be recognized during the placeholder build process.
///
/// - [builders]: A map associating placeholder keys with their respective
///   component builders, allowing custom rendering logic.
/// - [customBlockAttributesKeys]: A set of additional attribute keys to include
///   in placeholder processing. By default, only predefined keys are considered.
@experimental
@immutable
class PlaceholderConfig {
  const PlaceholderConfig({
    required this.builders,
    this.customBlockAttributesKeys,
  });

  factory PlaceholderConfig.base() {
    return const PlaceholderConfig(builders: {});
  }

  /// Add custom keys here to include them in placeholder builds, as external keys are ignored by default.
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
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;
}
