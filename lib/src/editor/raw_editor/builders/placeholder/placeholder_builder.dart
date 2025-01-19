@internal
library;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../../document/attribute.dart' show Attribute, AttributeScope;
import '../../../../document/nodes/line.dart';
import 'placeholder_configuration.dart';

// The black list of the keys that can not be used or permitted by the builder.
final List<String> _blackList = List.unmodifiable(<String>[
  Attribute.align.key,
  Attribute.direction.key,
  Attribute.lineHeight.key,
  Attribute.indent.key,
  ...Attribute.inlineKeys,
  ...Attribute.ignoreKeys,
]);

/// A utility class for managing placeholder rendering logic in a document editor.
///
/// The `PlaceholderBuilder` is responsible for determining when a placeholder
/// should be displayed in an empty node and for constructing the corresponding
/// visual representation.
///
/// - [configuration]: An instance of [PlaceholderConfig] containing placeholder
///   rendering rules and attribute customizations.
@experimental
@immutable
class PlaceholderBuilder {
  const PlaceholderBuilder({
    required this.configuration,
  });

  final PlaceholderConfig configuration;

  Map<String, PlaceholderComponentBuilder> get builders =>
      configuration.builders;
  Set<String>? get customBlockAttributesKeys =>
      configuration.customBlockAttributesKeys;

  /// Determines whether a given [Line] node should display a placeholder.
  ///
  /// This method checks if the node is empty and contains a block-level attribute
  /// matching a builder key or custom attribute, excluding keys in the blacklist.
  ///
  /// Returns a tuple:
  /// - [bool]: Whether a placeholder should be shown.
  /// - [String]: The key of the matching attribute, if applicable.
  @experimental
  (bool, String) shouldShowPlaceholder(Line node) {
    if (builders.isEmpty) return (false, '');
    var shouldShow = false;
    var key = '';
    for (final exclusiveKey in <dynamic>{
      ...Attribute.exclusiveBlockKeys,
      ...?customBlockAttributesKeys
    }) {
      if (node.style.containsKey(exclusiveKey) &&
          node.style.attributes[exclusiveKey]?.scope == AttributeScope.block &&
          !_blackList.contains(exclusiveKey)) {
        shouldShow = true;
        key = exclusiveKey;
        break;
      }
    }
    // we return if should show placeholders and the key of the attr that matches to get it directly
    // avoiding an unnecessary traverse into the attributes of the node
    return (node.isEmpty && shouldShow, key);
  }

  /// Constructs a [WidgetSpan] for rendering a placeholder in an empty line.
  ///
  /// This method creates a visual representation of the placeholder based on
  /// the block attribute and style configurations provided. Use [shouldShowPlaceholder]
  /// before invoking this method to ensure the placeholder is needed.
  @experimental
  WidgetSpan? build({
    required Attribute blockAttribute,
    required TextStyle lineStyle,
    required TextAlign align,
    TextDirection? textDirection,
    StrutStyle? strutStyle,
    TextScaler? textScaler,
  }) {
    if (builders.isEmpty) return null;
    final configuration =
        builders[blockAttribute.key]?.call(blockAttribute, lineStyle);
    // we don't need to add a placeholder that is null or contains a empty text
    if (configuration == null || configuration.text.trim().isEmpty) {
      return null;
    }
    final textWidget = Text(
      configuration.text,
      style: configuration.style,
      textDirection: textDirection,
      softWrap: true,
      strutStyle: strutStyle,
      textAlign: align,
      textScaler: textScaler,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    // Use a [Row] with [Expanded] for placeholders in lines without explicit alignment.
    // This ensures the placeholder spans the full width, avoiding unexpected alignment issues.
    return WidgetSpan(
      style: lineStyle,
      child: align == TextAlign.end || align == TextAlign.center
          ? textWidget
          : Row(
              children: [
                Expanded(
                  child: textWidget,
                ),
              ],
            ),
    );
  }
}
