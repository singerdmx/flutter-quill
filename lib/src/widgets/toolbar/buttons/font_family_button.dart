import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

class QuillToolbarFontFamilyButton extends StatefulWidget {
  QuillToolbarFontFamilyButton({
    required this.controller,
    @Deprecated('Please use the default display text from the options')
    this.defaultDisplayText,
    this.options = const QuillToolbarFontFamilyButtonOptions(),
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? (true)),
        assert(
          options.initialValue == null || options.initialValue!.isNotEmpty,
        );

  final QuillToolbarFontFamilyButtonOptions options;

  final String? defaultDisplayText;

  /// Since we can't get the state from the instace of the widget for comparing
  /// in [didUpdateWidget] then we will have to store reference here
  final QuillController controller;

  @override
  QuillToolbarFontFamilyButtonState createState() =>
      QuillToolbarFontFamilyButtonState();
}

class QuillToolbarFontFamilyButtonState
    extends State<QuillToolbarFontFamilyButton> {
  var _currentValue = '';

  QuillToolbarFontFamilyButtonOptions get options {
    return widget.options;
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentValue = _defaultDisplayText;
  }

  String get _defaultDisplayText {
    return options.initialValue ??
        widget.options.defaultDisplayText ??
        widget.defaultDisplayText ??
        context.loc.font;
  }

  // @override
  // void didUpdateWidget(covariant QuillToolbarFontFamilyButton oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.controller == controller) {
  //     return;
  //   }
  //   controller
  //     ..removeListener(_didChangeEditingValue)
  //     ..addListener(_didChangeEditingValue);
  // }

  // void _didChangeEditingValue() {
  //   final attribute = _selectionStyle.attributes[options.attribute.key];
  //   if (attribute == null) {
  //     setState(() => _currentValue = _defaultDisplayText);
  //     return;
  //   }
  //   final keyName = _getKeyName(attribute.value);
  //   setState(() => _currentValue = keyName ?? _defaultDisplayText);
  // }

  Map<String, String> get rawItemsMap {
    final rawItemsMap =
        context.quillSimpleToolbarConfigurations?.fontFamilyValues ??
            options.rawItemsMap ??
            {
              'Sans Serif': 'sans-serif',
              'Serif': 'serif',
              'Monospace': 'monospace',
              'Ibarra Real Nova': 'ibarra-real-nova',
              'SquarePeg': 'square-peg',
              'Nunito': 'nunito',
              'Pacifico': 'pacifico',
              'Roboto Mono': 'roboto-mono',
              context.loc.clear: 'Clear'
            };
    return rawItemsMap;
  }

  String? _getKeyName(String value) {
    for (final entry in rawItemsMap.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null;
  }

  QuillController get controller {
    return widget.controller;
  }

  double get iconSize {
    final baseFontSize = context.quillToolbarBaseButtonOptions?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        context.quillToolbarBaseButtonOptions?.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ??
        context.quillToolbarBaseButtonOptions?.iconTheme;
  }

  String get tooltip {
    return options.tooltip ??
        context.quillToolbarBaseButtonOptions?.tooltip ??
        context.loc.fontFamily;
  }

  void _onPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    options.afterButtonPressed?.call();
  }

  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations = context.quillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarFontFamilyButtonExtraOptions(
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
          controller: controller,
          context: context,
          onPressed: _onPressed,
        ),
      );
    }
    return UtilityWidgets.maybeWidget(
      enabled: tooltip.isNotEmpty || options.overrideTooltipByFontFamily,
      wrapper: (child) {
        var effectiveTooltip = tooltip;
        if (options.overrideTooltipByFontFamily) {
          effectiveTooltip = effectiveTooltip.isNotEmpty
              ? '$effectiveTooltip: $_currentValue'
              : '${context.loc.font}: $_currentValue';
        }
        return Tooltip(message: effectiveTooltip, child: child);
      },
      child: MenuAnchor(
        controller: _menuController,
        menuChildren: [
          for (final MapEntry<String, String> fontFamily in rawItemsMap.entries)
            MenuItemButton(
              key: ValueKey(fontFamily.key),
              // value: fontFamily.value,
              // height: options.itemHeight ?? kMinInteractiveDimension,
              // padding: options.itemPadding,
              onPressed: () {
                final newValue = fontFamily.value;
                final keyName = _getKeyName(newValue);
                setState(() {
                  if (keyName != 'Clear') {
                    _currentValue = keyName ?? _defaultDisplayText;
                  } else {
                    _currentValue = _defaultDisplayText;
                  }
                  if (keyName != null) {
                    controller.formatSelection(
                      Attribute.fromKeyValue(
                        Attribute.font.key,
                        newValue == 'Clear' ? null : newValue,
                      ),
                    );
                    options.onSelected?.call(newValue);
                  }
                });

                if (fontFamily.value == 'Clear') {
                  controller.selectFontFamily(null);
                  return;
                }
                controller.selectFontFamily(fontFamily);
              },
              child: Text(
                fontFamily.key.toString(),
                style: TextStyle(
                  fontFamily:
                      options.renderFontFamilies ? fontFamily.value : null,
                  color: fontFamily.value == 'Clear'
                      ? options.defaultItemColor
                      : null,
                ),
              ),
            ),
        ],
        child: Builder(
          builder: (context) {
            final isMaterial3 = Theme.of(context).useMaterial3;
            if (!isMaterial3) {
              return RawMaterialButton(
                onPressed: _onPressed,
                child: _buildContent(context),
              );
            }
            return QuillToolbarIconButton(
              isSelected: false,
              iconTheme: iconTheme?.copyWith(
                iconButtonSelectedData: const IconButtonData(
                  visualDensity: VisualDensity.compact,
                ),
                iconButtonUnselectedData: const IconButtonData(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              onPressed: _onPressed,
              icon: _buildContent(context),
            );
          },
        ),
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
              widget.controller.selectedFontFamily?.key ?? _currentValue,
              maxLines: 1,
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                    // color: iconTheme?.iconUnselectedFillColor ??
                    //     theme.iconTheme.color,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize / 1.15,
            // color: iconTheme?.iconUnselectedFillColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }
}
