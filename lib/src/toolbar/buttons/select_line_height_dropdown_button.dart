import 'package:flutter/material.dart';

import '../../../translations.dart';
import '../../document/attribute.dart';
import '../base_button/base_value_button.dart';
import '../base_toolbar.dart';
import '../config/buttons/select_line_height_style_dropdown_button_configurations.dart';
import '../simple_toolbar_provider.dart';
import '../theme/quill_icon_theme.dart';

typedef QuillToolbarSelectLineHeightStyleDropdownBaseButton
    = QuillToolbarBaseButton<
        QuillToolbarSelectLineHeightStyleDropdownButtonOptions,
        QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions>;

typedef QuillToolbarSelectLineHeightStyleDropdownBaseButtonsState<
        W extends QuillToolbarSelectLineHeightStyleDropdownButton>
    = QuillToolbarCommonButtonState<
        W,
        QuillToolbarSelectLineHeightStyleDropdownButtonOptions,
        QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions>;

class QuillToolbarSelectLineHeightStyleDropdownButton
    extends QuillToolbarSelectLineHeightStyleDropdownBaseButton {
  const QuillToolbarSelectLineHeightStyleDropdownButton({
    required super.controller,
    super.options =
        const QuillToolbarSelectLineHeightStyleDropdownButtonOptions(),
    super.key,
  });

  @override
  QuillToolbarSelectLineHeightStyleDropdownBaseButtonsState createState() =>
      _QuillToolbarSelectLineHeightStyleDropdownButtonState();
}

class _QuillToolbarSelectLineHeightStyleDropdownButtonState
    extends QuillToolbarSelectLineHeightStyleDropdownBaseButtonsState {
  @override
  String get defaultTooltip => context.loc.lineheight;

  @override
  IconData get defaultIconData => Icons.question_mark_outlined;

  Attribute<dynamic> _selectedItem = Attribute.lineHeight;

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
      covariant QuillToolbarSelectLineHeightStyleDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    widget.controller
      ..removeListener(_didChangeEditingValue)
      ..addListener(_didChangeEditingValue);
  }

  void _didChangeEditingValue() {
    final newSelectedItem = _getLineHeightValue();
    if (newSelectedItem == _selectedItem) {
      return;
    }
    setState(() {
      _selectedItem = newSelectedItem;
    });
  }

  Attribute<dynamic> _getLineHeightValue() {
    final attr =
        widget.controller.toolbarButtonToggler[Attribute.lineHeight.key];
    if (attr != null) {
      widget.controller.toolbarButtonToggler.remove(Attribute.lineHeight.key);
      return attr;
    }
    return widget.controller
            .getSelectionStyle()
            .attributes[Attribute.lineHeight.key] ??
        Attribute.lineHeight;
  }

  String _label(Attribute<dynamic> attribute) {
    var label = LineHeightAttribute.lineHeightNormal.value.toString();
    if (attribute.value != null) {
      label = attribute.value.toString();
    }
    return label;
  }

  List<Attribute<dynamic>> get lineHeightAttributes {
    return widget.options.attributes ??
        [
          LineHeightAttribute.lineHeightNormal,
          LineHeightAttribute.lineHeightTight,
          LineHeightAttribute.lineHeightOneAndHalf,
          LineHeightAttribute.lineHeightDouble,
        ];
  }

  void _onPressed(Attribute<dynamic> e) {
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
        widget.options,
        QuillToolbarSelectLineHeightStyleDropdownButtonExtraOptions(
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
        menuChildren: lineHeightAttributes
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            return _QuillToolbarLineHeightIcon(
              iconTheme: iconTheme,
              tooltip: tooltip,
              onPressed: _onDropdownButtonPressed,
              child: child,
            );
          },
        ));
  }

  void _onDropdownButtonPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    afterButtonPressed?.call();
  }
}

class _QuillToolbarLineHeightIcon extends StatelessWidget {
  const _QuillToolbarLineHeightIcon({
    required this.tooltip,
    required this.iconTheme,
    required this.onPressed,
    required this.child,
  });

  final Row child;
  final void Function() onPressed;
  final QuillIconTheme? iconTheme;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return QuillToolbarIconButton(
      icon: child,
      isSelected: false,
      iconTheme: iconTheme,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
