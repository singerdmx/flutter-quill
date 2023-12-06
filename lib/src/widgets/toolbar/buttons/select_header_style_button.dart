import 'package:flutter/material.dart';

import '../../../../translations.dart';
import '../../../models/config/toolbar/buttons/select_header_style_configurations.dart';
import '../../../models/documents/attribute.dart';
import '../../others/controller.dart';

enum _HeaderStyleOptions {
  normal,
  headingOne,
  headingTwo,
  headingThree,
}

class QuillToolbarSelectHeaderStyleButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleButton({
    required this.controller,
    this.options = const QuillToolbarSelectHeaderStyleButtonsOptions(),
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
  var _selectedItem = _HeaderStyleOptions.normal;
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

  String _label(_HeaderStyleOptions value) {
    final label = switch (value) {
      _HeaderStyleOptions.normal => context.loc.normal,
      _HeaderStyleOptions.headingOne => context.loc.heading1,
      _HeaderStyleOptions.headingTwo => context.loc.heading2,
      _HeaderStyleOptions.headingThree => context.loc.heading3,
    };
    return label;
  }

  Attribute<dynamic>? getAttributeByOptionsItem(_HeaderStyleOptions option) {
    return switch (option) {
      _HeaderStyleOptions.normal => Attribute.header,
      _HeaderStyleOptions.headingOne => Attribute.h1,
      _HeaderStyleOptions.headingTwo => Attribute.h2,
      _HeaderStyleOptions.headingThree => Attribute.h3,
    };
  }

  _HeaderStyleOptions _getOptionsItemByAttribute(
      Attribute<dynamic>? attribute) {
    return switch (attribute) {
      Attribute.h1 => _HeaderStyleOptions.headingOne,
      Attribute.h2 => _HeaderStyleOptions.headingTwo,
      Attribute.h2 => _HeaderStyleOptions.headingThree,
      Attribute() => _HeaderStyleOptions.normal,
      null => _HeaderStyleOptions.normal,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<_HeaderStyleOptions>(
      value: _selectedItem,
      items: _HeaderStyleOptions.values
          .map(
            (e) => DropdownMenuItem<_HeaderStyleOptions>(
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
