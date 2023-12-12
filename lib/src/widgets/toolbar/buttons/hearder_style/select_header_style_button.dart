import 'package:flutter/material.dart';

import '../../../../../translations.dart';
import '../../../../extensions/quill_configurations_ext.dart';
import '../../../../models/documents/attribute.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../quill/quill_controller.dart';
import '../../base_toolbar.dart';

enum _HeaderStyleOptions {
  normal,
  headingOne,
  headingTwo,
  headingThree,
}

class QuillToolbarSelectHeaderStyleButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleButton({
    required this.controller,
    this.options = const QuillToolbarSelectHeaderStyleButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectHeaderStyleButtonOptions options;

  @override
  State<QuillToolbarSelectHeaderStyleButton> createState() =>
      _QuillToolbarSelectHeaderStyleButtonState();
}

class _QuillToolbarSelectHeaderStyleButtonState
    extends State<QuillToolbarSelectHeaderStyleButton> {
  var _selectedItem = _HeaderStyleOptions.normal;
  final _controller = MenuController();
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(
      covariant QuillToolbarSelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    widget.controller
      ..removeListener(_didChangeEditingValue)
      ..addListener(_didChangeEditingValue);
  }

  void _didChangeEditingValue() {
    final newSelectedItem = _getOptionsItemByAttribute(_getHeaderValue());
    if (newSelectedItem == _selectedItem) {
      return;
    }
    setState(() {
      _selectedItem = newSelectedItem;
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

  double get iconSize {
    final baseFontSize = context.quillToolbarBaseButtonOptions?.globalIconSize;
    final iconSize = widget.options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final baseIconFactor =
        context.quillToolbarBaseButtonOptions?.globalIconButtonFactor;
    final iconButtonFactor = widget.options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kIconButtonFactor;
  }

  QuillIconTheme? get iconTheme {
    return widget.options.iconTheme ??
        context.quillToolbarBaseButtonOptions?.iconTheme;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      menuChildren: _HeaderStyleOptions.values
          .map(
            (e) => MenuItemButton(
              child: Text(_label(e)),
              onPressed: () {
                widget.controller.formatSelection(getAttributeByOptionsItem(e));
                setState(() => _selectedItem = e);
              },
            ),
          )
          .toList(),
      child: IconButton(
        onPressed: () {
          if (_controller.isOpen) {
            _controller.close();
            return;
          }
          _controller.open();
        },
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(_selectedItem),
              style: widget.options.textStyle ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                  ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: iconSize * iconButtonFactor,
            ),
          ],
        ),
      ),
    );
  }
}
