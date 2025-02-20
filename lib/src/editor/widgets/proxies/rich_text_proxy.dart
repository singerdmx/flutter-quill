import 'package:flutter/widgets.dart';

import 'render_paragraph_proxy.dart';

class RichTextProxy extends SingleChildRenderObjectWidget {
  /// Child argument should be an instance of RichText widget.
  const RichTextProxy({
    required RichText super.child,
    required this.textStyle,
    required this.textAlign,
    required this.textDirection,
    required this.locale,
    required this.strutStyle,
    required this.textScaler,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    super.key,
  });

  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final Locale locale;
  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  RenderParagraphProxy createRenderObject(BuildContext context) {
    return RenderParagraphProxy(
      null,
      textStyle,
      textAlign,
      textDirection,
      textScaler,
      strutStyle,
      locale,
      textWidthBasis,
      textHeightBehavior,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParagraphProxy renderObject) {
    renderObject
      ..textStyle = textStyle
      ..textAlign = textAlign
      ..textDirection = textDirection
      ..textScaler = textScaler
      ..locale = locale
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior;
  }
}
