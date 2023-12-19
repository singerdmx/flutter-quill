import 'package:flutter/material.dart';

import '../../../../../translations.dart';
import '../../../../extensions/quill_configurations_ext.dart';
import '../../../../models/documents/attribute.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../quill/quill_controller.dart';
import '../../base_toolbar.dart';

class QuillToolbarSelectHeaderStyleDropdownButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleDropdownButton({
    required this.controller,
    this.options = const QuillToolbarSelectHeaderStyleDropdownButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectHeaderStyleDropdownButtonOptions options;

  @override
  State<QuillToolbarSelectHeaderStyleDropdownButton> createState() =>
      _QuillToolbarSelectHeaderStyleDropdownButtonState();
}

class _QuillToolbarSelectHeaderStyleDropdownButtonState
    extends State<QuillToolbarSelectHeaderStyleDropdownButton> {
  Attribute<dynamic> _selectedItem = Attribute.header;

  final _menuController = MenuController();
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
      covariant QuillToolbarSelectHeaderStyleDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    widget.controller
      ..removeListener(_didChangeEditingValue)
      ..addListener(_didChangeEditingValue);
  }

  void _didChangeEditingValue() {
    final newSelectedItem = _getHeaderValue();
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

  String _label(Attribute<dynamic> value) {
    final label = switch (value) {
      Attribute.h1 => context.loc.heading1,
      Attribute.h2 => context.loc.heading2,
      Attribute.h3 => context.loc.heading3,
      Attribute.h4 => context.loc.heading4,
      Attribute.h5 => context.loc.heading5,
      Attribute.h6 => context.loc.heading6,
      Attribute.header => context.loc.normal,
      Attribute<dynamic>() => throw ArgumentError(),
    };
    return label;
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

  List<Attribute<int?>> get headerAttributes {
    return widget.options.attributes ??
        [
          Attribute.h1,
          Attribute.h2,
          Attribute.h3,
          Attribute.h4,
          Attribute.h5,
          Attribute.h6,
          Attribute.header,
        ];
  }

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions {
    return context.quillToolbarBaseButtonOptions;
  }

  VoidCallback? get afterButtonPressed {
    return widget.options.afterButtonPressed ??
        baseButtonExtraOptions?.afterButtonPressed;
  }

  void _onPressed(Attribute<int?> e) {
    setState(() => _selectedItem = e);
    widget.controller.formatSelection(_selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations = context.quillToolbarBaseButtonOptions;
    final childBuilder =
        widget.options.childBuilder ?? baseButtonConfigurations?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        widget.options.copyWith(
          iconSize: iconSize,
          iconTheme: iconTheme,
          afterButtonPressed: afterButtonPressed,
        ),
        QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions(
          currentValue: _selectedItem,
          context: context,
          controller: widget.controller,
          onPressed: () {
            throw UnimplementedError('Not implemented yet.');
          },
        ),
      );
    }

    return MenuAnchor(
      controller: _menuController,
      menuChildren: headerAttributes
          .map(
            (e) => MenuItemButton(
              onPressed: () {
                _onPressed(e);
              },
              child: Text(_label(e)),
            ),
          )
          .toList(),
      child: Builder(
        builder: (context) {
          final isMaterial3 = Theme.of(context).useMaterial3;
          final child = Row(
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
          );
          if (!isMaterial3) {
            return RawMaterialButton(
              onPressed: _onDropdownButtonPressed,
              child: child,
            );
          }
          return IconButton(
            onPressed: _onDropdownButtonPressed,
            icon: child,
          );
        },
      ),
    );
  }

  void _onDropdownButtonPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }
    _menuController.open();
  }
}
