import 'package:flutter/material.dart';

import '../../../controller/quill_controller.dart';
import '../../../document/attribute.dart';

enum _AlignmentOptions {
  left(attribute: Attribute.leftAlignment),
  center(attribute: Attribute.centerAlignment),
  right(attribute: Attribute.rightAlignment),
  justifyMinWidth(attribute: Attribute.justifyAlignment);

  const _AlignmentOptions({required this.attribute});

  final Attribute attribute;
}

/// Dropdown button
class QuillToolbarSelectAlignmentButton extends StatelessWidget {
  const QuillToolbarSelectAlignmentButton(
      {required this.controller, super.key});
  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: _AlignmentOptions.values
          .map(
            (e) => MenuItemButton(
              child: Text(e.name),
              onPressed: () {
                controller.formatSelection(e.attribute);
              },
            ),
          )
          .toList(),
    );
  }
}
