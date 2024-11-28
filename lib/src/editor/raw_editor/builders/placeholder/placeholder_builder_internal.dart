// This file is only for internal use
import 'package:flutter/material.dart';
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
@internal
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

  /// Check if this node need to show a placeholder
  @experimental
  @internal
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

  /// Build is similar to build method from any widget but
  /// this only has the responsability of create a WidgetSpan to be showed
  /// by the line when the node is empty
  ///
  /// Before use this, we should always use [shouldShowPlaceholder] to avoid
  /// show any placeholder where is not needed
  @experimental
  @internal
  WidgetSpan? build({
    required Attribute blockAttribute,
    required TextStyle lineStyle,
    required TextAlign align,
    TextDirection? textDirection,
    StrutStyle? strutStyle,
  }) {
    if (builders.isEmpty) return null;
    final configuration =
        builders[blockAttribute.key]?.call(blockAttribute, lineStyle);
    // we don't need to add a placeholder that is null or contains a empty text
    if (configuration == null || configuration.placeholderText.trim().isEmpty) {
      return null;
    }
    final textWidget = Text(
      configuration.placeholderText,
      style: configuration.style,
      textDirection: textDirection,
      softWrap: true,
      strutStyle: strutStyle,
      textAlign: align,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    // we use [Row] widget with [Expanded] to take whole the available width
    // when the line has not defined an alignment.
    //
    // this behavior is different when the align is left or justify, because
    // if we align the line to the center (example), row will take the whole
    // width, creating a visual unexpected behavior where the caret being putted
    // at the offset 0 (you can think this like the caret appears at the first char
    // of the line when it is aligned at the left side instead appears at the middle
    // if the line is centered)
    //
    // Note:
    // this code is subject to changes because we need to get a better solution
    // to this implementation
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
