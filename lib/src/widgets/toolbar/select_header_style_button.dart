import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/style.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../toolbar.dart';

class SelectHeaderStyleButton extends StatefulWidget {
  const SelectHeaderStyleButton({
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.attributes = const [
      Attribute.header,
      Attribute.h1,
      Attribute.h2,
      Attribute.h3,
    ],
    this.afterButtonPressed,
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final List<Attribute> attributes;
  final VoidCallback? afterButtonPressed;

  @override
  _SelectHeaderStyleButtonState createState() =>
      _SelectHeaderStyleButtonState();
}

class _SelectHeaderStyleButtonState extends State<SelectHeaderStyleButton> {
  Attribute? _selectedAttribute;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  final _valueToText = <Attribute, String>{
    Attribute.header: 'N',
    Attribute.h1: 'H1',
    Attribute.h2: 'H2',
    Attribute.h3: 'H3',
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.attributes.every((element) => _valueToText.keys.contains(element)),
      'All attributes must be one of them: header, h1, h2 or h3',
    );

    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: widget.iconSize * 0.7,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.attributes.map((attribute) {
        final isSelected = _selectedAttribute == attribute;
        return Padding(
          // ignore: prefer_const_constructors
          padding: EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: widget.iconSize * kIconButtonFactor,
              height: widget.iconSize * kIconButtonFactor,
            ),
            child: RawMaterialButton(
              hoverElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      widget.iconTheme?.borderRadius ?? 2)),
              fillColor: isSelected
                  ? (widget.iconTheme?.iconSelectedFillColor ??
                      Theme.of(context).primaryColor)
                  : (widget.iconTheme?.iconUnselectedFillColor ??
                      theme.canvasColor),
              onPressed: () {
                final _attribute = _selectedAttribute == attribute
                    ? Attribute.header
                    : attribute;
                widget.controller.formatSelection(_attribute);
                widget.afterButtonPressed?.call();
              },
              child: Text(
                _valueToText[attribute] ?? '',
                style: style.copyWith(
                  color: isSelected
                      ? (widget.iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (widget.iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
  }

  Attribute<dynamic> _getHeaderValue() {
    final attr = widget.controller.toolbarButtonToggler[Attribute.header.key];
    if (attr != null) {
      // checkbox tapping causes controller.selection to go to offset 0
      widget.controller.toolbarButtonToggler.remove(Attribute.header.key);
      return attr;
    }
    return _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
  }

  @override
  void didUpdateWidget(covariant SelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _selectedAttribute = _getHeaderValue();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }
}
