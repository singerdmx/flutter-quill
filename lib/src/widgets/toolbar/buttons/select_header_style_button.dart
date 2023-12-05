import 'package:flutter/material.dart';

import '../../../../translations.dart';
import '../../../models/config/toolbar/buttons/select_header_style.dart';
import '../../../models/documents/attribute.dart';
import '../../others/controller.dart';

enum QuillToolbarSelectHeaderStyleButtonOptions {
  normal,
  headingOne,
  headingTwo,
  headingThree,
}

class QuillToolbarSelectHeaderStyleButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectHeaderStyleButtonsOptions options;

  @override
  State<QuillToolbarSelectHeaderStyleButton> createState() =>
      _QuillToolbarSelectHeaderStyleButtonState();
}

class _QuillToolbarSelectHeaderStyleButtonState
    extends State<QuillToolbarSelectHeaderStyleButton> {
  var _selectedItem = QuillToolbarSelectHeaderStyleButtonOptions.normal;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeEditingValue);
  }

  void _didChangeEditingValue() {
    setState(() {
      _selectedItem = _getOptionsItemByAttribute(_getHeaderValue());
    });
  }

  Attribute<dynamic> _getHeaderValue() {
    final attr = widget.controller.toolbarButtonToggler[Attribute.header.key];
    if (attr != null) {
      // checkbox tapping causes controller.selection to go to offset 0
      widget.controller.toolbarButtonToggler.remove(Attribute.header.key);
      return attr;
    }
    return widget.controller
            .getSelectionStyle()
            .attributes[Attribute.header.key] ??
        Attribute.header;
  }

  String _label(QuillToolbarSelectHeaderStyleButtonOptions value) {
    final label = switch (value) {
      QuillToolbarSelectHeaderStyleButtonOptions.normal => context.loc.normal,
      QuillToolbarSelectHeaderStyleButtonOptions.headingOne =>
        context.loc.heading1,
      QuillToolbarSelectHeaderStyleButtonOptions.headingTwo =>
        context.loc.heading2,
      QuillToolbarSelectHeaderStyleButtonOptions.headingThree =>
        context.loc.heading3,
    };
    return label;
  }

  Attribute<dynamic>? getAttributeByOptionsItem(
      QuillToolbarSelectHeaderStyleButtonOptions option) {
    return switch (option) {
      QuillToolbarSelectHeaderStyleButtonOptions.normal => Attribute.header,
      QuillToolbarSelectHeaderStyleButtonOptions.headingOne => Attribute.h1,
      QuillToolbarSelectHeaderStyleButtonOptions.headingTwo => Attribute.h2,
      QuillToolbarSelectHeaderStyleButtonOptions.headingThree => Attribute.h3,
    };
  }

  QuillToolbarSelectHeaderStyleButtonOptions _getOptionsItemByAttribute(
      Attribute<dynamic>? attribute) {
    return switch (attribute) {
      Attribute.h1 => QuillToolbarSelectHeaderStyleButtonOptions.headingOne,
      Attribute.h2 => QuillToolbarSelectHeaderStyleButtonOptions.headingTwo,
      Attribute.h2 => QuillToolbarSelectHeaderStyleButtonOptions.headingThree,
      Attribute() => QuillToolbarSelectHeaderStyleButtonOptions.normal,
      null => QuillToolbarSelectHeaderStyleButtonOptions.normal,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<QuillToolbarSelectHeaderStyleButtonOptions>(
      value: _selectedItem,
      items: QuillToolbarSelectHeaderStyleButtonOptions.values
          .map(
            (e) => DropdownMenuItem<QuillToolbarSelectHeaderStyleButtonOptions>(
              value: e,
              child: Text(_label(e)),
              onTap: () {
                widget.controller.formatSelection(getAttributeByOptionsItem(e));
              },
            ),
          )
          .toList(),
      onChanged: (newItem) {
        if (newItem == null) {
          return;
        }
        setState(() => _selectedItem = newItem);
      },
    );
  }
}
