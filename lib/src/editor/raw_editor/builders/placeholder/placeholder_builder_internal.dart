// This file is only for internal use
import 'package:flutter/material.dart'
    show
        Expanded,
        Row,
        Text,
        TextDirection,
        TextStyle,
        TextWidthBasis,
        Widget,
        immutable;
import 'package:meta/meta.dart';
import '../../../../document/attribute.dart' show Attribute, AttributeScope;
import '../../../../document/nodes/line.dart';
import 'placeholder_configuration.dart';

/// This is the black list of the keys that cannot be
/// used or permitted by the builder
// ignore: unnecessary_late
late final List<String> _blackList = List.unmodifiable(<String>[
  Attribute.align.key,
  Attribute.direction.key,
  Attribute.lineHeight.key,
  Attribute.indent.key,
  ...Attribute.inlineKeys,
  ...Attribute.ignoreKeys,
]);

@experimental 
@immutable
class PlaceholderBuilder {
  const PlaceholderBuilder({
    required this.configuration,
  });

  final PlaceholderComponentsConfiguration configuration;

  Map<String, PlaceholderConfigurationBuilder> get builders =>
      configuration.builders;
  Set<String>? get customBlockAttributesKeys =>
      configuration.customBlockAttributesKeys;

  /// Check if this node need to show a placeholder
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

  @experimental
  Widget? build({
    required Attribute blockAttribute,
    required TextStyle lineStyle,
    required TextDirection textDirection,
  }) {
    if (builders.isEmpty) return null;
    final configuration =
        builders[blockAttribute.key]?.call(blockAttribute, lineStyle);
    // we return a row because this widget takes the whole width and makes possible
    // select the block correctly (without this the block line cannot be selected correctly)
    return configuration == null || configuration.placeholderText.trim().isEmpty
        ? null
        : Row(
            children: [
              // expanded let us add text as large as possible without breaks
              // the horizontal view
              Expanded(
                child: Text(
                  configuration.placeholderText,
                  style: configuration.style,
                  textDirection: textDirection,
                  softWrap: true,
                  textWidthBasis: TextWidthBasis.longestLine,
                ),
              ),
            ],
          );
  }
}
