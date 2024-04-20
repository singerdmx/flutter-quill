import 'package:flutter/material.dart';

import '../../../../extensions.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../utils/font.dart';
import '../base_button/stateful_base_button_ex.dart';
import '../base_toolbar.dart';

class QuillToolbarFontSizeButton extends QuillToolbarStatefulBaseButton<
    QuillToolbarFontSizeButtonOptions, QuillToolbarFontSizeButtonExtraOptions> {
  QuillToolbarFontSizeButton({
    required super.controller,
    @Deprecated('Please use the default display text from the options')
    this.defaultDisplayText,
    super.options = const QuillToolbarFontSizeButtonOptions(),
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? true),
        assert(options.initialValue == null ||
            (options.initialValue?.isNotEmpty ?? true));

  final String? defaultDisplayText;

  @override
  QuillToolbarFontSizeButtonState createState() =>
      QuillToolbarFontSizeButtonState();
}

class QuillToolbarFontSizeButtonState extends QuillToolbarBaseButtonState<
    QuillToolbarFontSizeButton,
    QuillToolbarFontSizeButtonOptions,
    QuillToolbarFontSizeButtonExtraOptions> {
  final _menuController = MenuController();
  String _currentValue = '';

  Map<String, String> get rawItemsMap {
    final fontSizes = options.rawItemsMap ??
        context.quillSimpleToolbarConfigurations?.fontSizesValues ??
        {
          context.loc.small: 'small',
          context.loc.large: 'large',
          context.loc.huge: 'huge',
          context.loc.clear: '0'
        };
    return fontSizes;
  }

  String? getLabel(String? currentValue) {
    return switch (currentValue) {
      'small' => context.loc.small,
      'large' => context.loc.large,
      'huge' => context.loc.huge,
      String() => currentValue,
      null => null,
    };
  }

  String get _defaultDisplayText {
    return options.initialValue ??
        widget.options.defaultDisplayText ??
        widget.defaultDisplayText ??
        context.loc.fontSize;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentValue = _defaultDisplayText;
  }

  @override
  void didChangeEditingValue() {
    final attribute =
        controller.getSelectionStyle().attributes[options.attribute.key];
    if (attribute == null) {
      setState(() => _currentValue = _defaultDisplayText);
      return;
    }
    final keyName = _getKeyName(attribute.value);
    setState(() => _currentValue = keyName ?? _defaultDisplayText);
  }

  String? _getKeyName(dynamic value) {
    for (final entry in rawItemsMap.entries) {
      if (getFontSize(entry.value) == getFontSize(value)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  String get defaultTooltip => context.loc.fontSize;

  void _onDropdownButtonPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations = context.quillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarFontSizeButtonExtraOptions(
          controller: controller,
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
          context: context,
          onPressed: _onDropdownButtonPressed,
        ),
      );
    }
    return MenuAnchor(
      controller: _menuController,
      menuChildren: rawItemsMap.entries.map((fontSize) {
        return MenuItemButton(
          key: ValueKey(fontSize.key),
          onPressed: () {
            final newValue = fontSize.value;

            final keyName = _getKeyName(newValue);
            setState(() {
              if (keyName != context.loc.clear) {
                _currentValue = keyName ?? _defaultDisplayText;
              } else {
                _currentValue = _defaultDisplayText;
              }
              if (keyName != null) {
                controller.formatSelection(
                  Attribute.fromKeyValue(
                    Attribute.size.key,
                    newValue == '0' ? null : getFontSize(newValue),
                  ),
                );
                options.onSelected?.call(newValue);
              }
            });

            if (fontSize.value == '0') {
              controller.selectFontSize(null);
              return;
            }
            controller.selectFontSize(fontSize);
          },
          child: Text(
            fontSize.key.toString(),
            style: TextStyle(
              color: fontSize.value == '0' ? options.defaultItemColor : null,
            ),
          ),
        );
      }).toList(),
      child: Builder(
        builder: (context) {
          final isMaterial3 = Theme.of(context).useMaterial3;
          if (!isMaterial3) {
            return RawMaterialButton(
              onPressed: _onDropdownButtonPressed,
              child: _buildContent(context),
            );
          }
          return QuillToolbarIconButton(
            tooltip: tooltip,
            isSelected: false,
            iconTheme: iconTheme,
            onPressed: _onDropdownButtonPressed,
            icon: _buildContent(context),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasFinalWidth = options.width != null;
    return Padding(
      padding: options.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisSize: !hasFinalWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UtilityWidgets.maybeWidget(
            enabled: hasFinalWidth,
            wrapper: (child) => Expanded(child: child),
            child: Text(
              getLabel(_currentValue) ?? '',
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                  ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize * iconButtonFactor,
          )
        ],
      ),
    );
  }
}
