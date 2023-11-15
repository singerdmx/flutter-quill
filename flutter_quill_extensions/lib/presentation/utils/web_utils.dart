import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart' show Attribute, Node;

/// Prefer the width, and height from the css style attribute if exits
/// it can be `auto` or `100px` so it's specific to HTML && CSS
/// if not, we will use the one from attributes which is usually just an double
(
  String height,
  String width,
  String margin,
  String alignment,
) getWebElementAttributes(
  Node node,
) {
  var height = 'auto';
  var width = 'auto';
  // TODO: Add support for margin and alignment
  const margin = 'auto';
  const alignment = 'center';

  // return (height, width, margin, alignment);

  final cssStyle = node.style.attributes['style'];

  // Usually double value
  final heightValue = node.style.attributes[Attribute.height.key]?.value;
  final widthValue = node.style.attributes[Attribute.width.key]?.value;

  if (cssStyle != null) {
    final attrs = base.parseKeyValuePairs(cssStyle.value.toString(), {
      Attribute.width.key,
      Attribute.height.key,
      'margin',
      'alignment',
    });
    final cssHeightValue = attrs[Attribute.height.key];
    if (cssHeightValue != null) {
      height = cssHeightValue;
    } else {
      height = '${heightValue}px';
    }
    final cssWidthValue = attrs[Attribute.width.key];
    if (cssWidthValue != null) {
      width = cssWidthValue;
    } else if (widthValue != null) {
      width = '${widthValue}px';
    }

    return (height, width, margin, alignment);
  }

  if (heightValue != null) {
    height = '${heightValue}px';
  }
  if (widthValue != null) {
    width = '${widthValue}px';
  }

  return (height, width, margin, alignment);
}
