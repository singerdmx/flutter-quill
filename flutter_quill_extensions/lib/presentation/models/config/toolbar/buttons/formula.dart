import 'package:flutter/widgets.dart' show Color;
import 'package:flutter_quill/flutter_quill.dart';

class QuillToolbarFormulaButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarFormulaButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarFormulaButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarFormulaButtonOptions, QuillToolbarFormulaButtonExtraOptions> {
  const QuillToolbarFormulaButtonOptions({
    super.tooltip,
    super.iconData,
    super.iconTheme,
    super.afterButtonPressed,
    super.childBuilder,
    this.fillColor,
    this.iconSize,
    this.iconButtonFactor,
  });

  final Color? fillColor;

  final double? iconSize;
  final double? iconButtonFactor;
}
