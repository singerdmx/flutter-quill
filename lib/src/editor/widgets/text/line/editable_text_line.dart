import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../common/structs/horizontal_spacing.dart';
import '../../../../common/structs/vertical_spacing.dart';
import '../../../../document/nodes/line.dart';
import '../../cursor.dart';
import '../../styles/default_styles.dart';
import 'render_editable_line.dart';

@internal
class EditableTextLine extends RenderObjectWidget {
  const EditableTextLine(
      this.line,
      this.leading,
      this.body,
      this.horizontalSpacing,
      this.verticalSpacing,
      this.textDirection,
      this.textSelection,
      this.color,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.devicePixelRatio,
      this.cursorCont,
      this.inlineCodeStyle,
      {super.key});

  final Line line;
  final Widget? leading;
  final Widget body;
  final HorizontalSpacing horizontalSpacing;
  final VerticalSpacing verticalSpacing;
  final TextDirection textDirection;
  final TextSelection textSelection;
  final Color color;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final double devicePixelRatio;
  final CursorCont cursorCont;
  final InlineCodeStyle inlineCodeStyle;

  @override
  RenderObjectElement createElement() {
    return TextLineElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderEditableTextLine(
        line,
        textDirection,
        textSelection,
        enableInteractiveSelection,
        hasFocus,
        devicePixelRatio,
        _getPadding(),
        color,
        cursorCont,
        inlineCodeStyle);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditableTextLine renderObject) {
    renderObject
      ..setLine(line)
      ..setPadding(_getPadding())
      ..setTextDirection(textDirection)
      ..setTextSelection(textSelection)
      ..setColor(color)
      ..setEnableInteractiveSelection(enableInteractiveSelection)
      ..hasFocus = hasFocus
      ..setDevicePixelRatio(devicePixelRatio)
      ..setCursorCont(cursorCont)
      ..setInlineCodeStyle(inlineCodeStyle);
  }

  EdgeInsetsGeometry _getPadding() {
    return EdgeInsetsDirectional.only(
        start: horizontalSpacing.left,
        end: horizontalSpacing.right,
        top: verticalSpacing.top,
        bottom: verticalSpacing.bottom);
  }
}
