import 'package:flutter/material.dart';

import '../../../../models/documents/attribute.dart';
import '../../../quill/quill_controller.dart';
import '../../base_toolbar.dart';

enum _AlignmentOptions {
  left(attribute: Attribute.leftAlignment),
  center(attribute: Attribute.centerAlignment),
  right(attribute: Attribute.rightAlignment),
  justifyMinWidth(attribute: Attribute.justifyAlignment);

  const _AlignmentOptions({required this.attribute});

  final Attribute attribute;
}

class QuillToolbarSelectAlignmentButtons extends StatelessWidget {
  const QuillToolbarSelectAlignmentButtons({
    required this.controller,
    this.options = const QuillToolbarSelectAlignmentButtonOptions(),
    this.showLeftAlignment,
    this.showCenterAlignment,
    this.showRightAlignment,
    this.showJustifyAlignment,
    this.padding,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectAlignmentButtonOptions options;

  final bool? showLeftAlignment;
  final bool? showCenterAlignment;
  final bool? showRightAlignment;
  final bool? showJustifyAlignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _AlignmentOptions.values
          .map((e) => QuillToolbarToggleStyleButton(
                controller: controller,
                attribute: e.attribute,
                options: QuillToolbarToggleStyleButtonOptions(
                  iconData: options.iconData,
                  iconSize: options.iconSize,
                  iconButtonFactor: options.iconButtonFactor,
                  afterButtonPressed: options.afterButtonPressed,
                  iconTheme: options.iconTheme,
                  tooltip: options.tooltip,
                ),
              ))
          .toList(),
    );
  }
}
