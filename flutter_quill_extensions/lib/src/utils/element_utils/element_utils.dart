import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Alignment, BuildContext;
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' show Attribute, Node;

import 'element_shared_utils.dart';

/// Theses properties are not officialy supported by quill js
/// but they are only used in all platforms other than web
/// and they will be stored in css style property so quill js ignore them
enum ExtraElementProperties {
  deletable,
}

(
  ElementSize elementSize,
  double? margin,
  Alignment alignment,
) getElementAttributes(
  Node node,
  BuildContext context,
) {
  var elementSize = const ElementSize(null, null);
  var elementAlignment = Alignment.center;
  double? elementMargin;

  final heightValue = parseCssPropertyAsDouble(
    node.style.attributes[Attribute.height.key]?.value.toString() ?? '',
    context: context,
  );
  final widthValue = parseCssPropertyAsDouble(
    node.style.attributes[Attribute.width.key]?.value.toString() ?? '',
    context: context,
  );

  if (heightValue != null) {
    elementSize = elementSize.copyWith(
      height: heightValue,
    );
  }
  if (widthValue != null) {
    elementSize = elementSize.copyWith(
      width: widthValue,
    );
  }

  final cssStyle = node.style.attributes['style'];

  if (cssStyle != null) {
    // It css value as string but we will try to support it anyway

    final cssAttrs = parseCssString(cssStyle.value.toString());

    final cssHeightValue = parseCssPropertyAsDouble(
      (cssAttrs[Attribute.height.key]) ?? '',
      context: context,
    );
    final cssWidthValue = parseCssPropertyAsDouble(
      (cssAttrs[Attribute.width.key]) ?? '',
      context: context,
    );

    // cssHeightValue != null && elementSize.height == null
    if (cssHeightValue != null) {
      elementSize = elementSize.copyWith(height: cssHeightValue);
    }
    if (cssWidthValue != null) {
      elementSize = elementSize.copyWith(width: cssWidthValue);
    }

    elementAlignment = getAlignment(cssAttrs['alignment']);

    final margin = double.tryParse('margin');
    if (margin != null) {
      elementMargin = margin;
    }
  }

  return (elementSize, elementMargin, elementAlignment);
}

@immutable
class ElementSize {
  const ElementSize(
    this.width,
    this.height,
  );

  /// If non-null, requires the child to have exactly this width.
  /// If null, the child is free to choose its own width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  /// If null, the child is free to choose its own height.
  final double? height;

  ElementSize copyWith({
    double? width,
    double? height,
  }) {
    return ElementSize(
      width ?? this.width,
      height ?? this.height,
    );
  }
}
