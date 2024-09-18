// This file is only for internal use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show Expanded, Row, Text, TextDirection, TextStyle, TextWidthBasis, Widget;
import '../../../../document/attribute.dart' show Attribute;
import '../../../../document/nodes/line.dart';
import 'placeholder_configuration.dart';

@immutable
class PlaceholderBuilder {
  const PlaceholderBuilder({
    required this.builders,
  });

  final Map<String, PlaceholderConfigurationBuilder> builders;

  /// Check if this node need to show a placeholder
  (bool, String) shouldShowPlaceholder(Line node) {
    if (builders.isEmpty) return (false, '');
    var shouldShow = false;
    var key = '';
    // by now, we limit the available keys to show placeholder
    // to 'header', 'list', 'code-block' and 'blockquote'
    //
    //TODO: we should take a look to let users add custom attributes
    // keys to let them show placeholder on their own blocks
    for (final exclusiveKey in Attribute.exclusiveBlockKeys) {
      if (node.style.containsKey(exclusiveKey)) {
        shouldShow = true;
        key = exclusiveKey;
        break;
      }
    }
    // we return if should show placeholders and the key of the attr that matches to get it directly
    // avoiding an unnecessary traverse into the attributes of the node
    return (node.isEmpty && shouldShow, key);
  }

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
    return configuration == null
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
