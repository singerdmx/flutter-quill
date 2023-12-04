import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart' show Attribute, Node;

import '../../extensions/attribute.dart';
import 'element_shared_utils.dart';

/// Theses properties are not officaly supported by quill js
/// but they are only used in all platforms other than web
/// and they will be stored in css style property so quill js ignore them
enum ExtraElementProperties {
  deletable,
}

(
  OptionalSize elementSize,
  double? margin,
  Alignment alignment,
) getElementAttributes(
  Node node,
) {
  var elementSize = const OptionalSize(null, null);
  var elementAlignment = Alignment.center;
  double? elementMargin;

  // Usually double value
  final heightValue = double.tryParse(
      node.style.attributes[Attribute.height.key]?.value.toString() ?? '');
  final widthValue = double.tryParse(
      node.style.attributes[Attribute.width.key]?.value.toString() ?? '');

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

    // TODO: This could be improved much better
    final cssHeightValue = double.tryParse(((base.isMobile(supportWeb: false)
                ? cssAttrs[AttributeExt.mobileHeight.key]
                : cssAttrs[Attribute.height.key]) ??
            '')
        .replaceFirst('px', ''));
    final cssWidthValue = double.tryParse(((!base.isMobile(supportWeb: false)
                ? cssAttrs[Attribute.width.key]
                : cssAttrs[AttributeExt.mobileWidth.key]) ??
            '')
        .replaceFirst('px', ''));

    if (cssHeightValue != null) {
      elementSize = elementSize.copyWith(height: cssHeightValue);
    }
    if (cssWidthValue != null) {
      elementSize = elementSize.copyWith(width: cssWidthValue);
    }

    elementAlignment = base.getAlignment(base.isMobile(supportWeb: false)
        ? cssAttrs[AttributeExt.mobileAlignment.key]
        : cssAttrs['alignment']);
    final margin = (base.isMobile(supportWeb: false)
        ? double.tryParse(AttributeExt.mobileMargin.key)
        : double.tryParse('margin'));
    if (margin != null) {
      elementMargin = margin;
    }
  }

  return (elementSize, elementMargin, elementAlignment);
}

@immutable
class OptionalSize {
  const OptionalSize(
    this.width,
    this.height,
  );

  /// If non-null, requires the child to have exactly this width.
  /// If null, the child is free to choose its own width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  /// If null, the child is free to choose its own height.
  final double? height;

  OptionalSize copyWith({
    double? width,
    double? height,
  }) {
    return OptionalSize(
      width ?? this.width,
      height ?? this.height,
    );
  }
}
