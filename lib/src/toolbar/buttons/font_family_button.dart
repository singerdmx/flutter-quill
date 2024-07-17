import 'package:flutter/material.dart';

import '../../../extensions.dart';
import '../../document/attribute.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';
import '../base_toolbar.dart';
import '../simple_toolbar_provider.dart';

class QuillToolbarFontFamilyButton extends QuillToolbarBaseButton<
    QuillToolbarFontFamilyButtonOptions,
    QuillToolbarFontFamilyButtonExtraOptions> {
  QuillToolbarFontFamilyButton({
    required super.controller,
    @Deprecated('Please use the default display text from the options')
    this.defaultDisplayText,
    super.options = const QuillToolbarFontFamilyButtonOptions(),
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? (true)),
        assert(
          options.initialValue == null || options.initialValue!.isNotEmpty,
        );

  final String? defaultDisplayText;

  @override
  QuillToolbarFontFamilyButtonState createState() =>
      QuillToolbarFontFamilyButtonState();
}

class QuillToolbarFontFamilyButtonState extends QuillToolbarBaseButtonState<
    QuillToolbarFontFamilyButton,
    QuillToolbarFontFamilyButtonOptions,
    QuillToolbarFontFamilyButtonExtraOptions,
    String> {
  @override
  String get currentStateValue {
    final attribute =
        controller.getSelectionStyle().attributes[options.attribute.key];
    return attribute == null
        ? _defaultDisplayText
        : (_getKeyName(attribute.value) ?? _defaultDisplayText);
  }

  String get _defaultDisplayText {
    return options.initialValue ??
        widget.options.defaultDisplayText ??
        widget.defaultDisplayText ??
        context.loc.font;
  }

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

  @override
  String get defaultTooltip => context.loc.fontFamily;

  @override
  IconData get defaultIconData => Icons.font_download_outlined;

  void _onPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    afterButtonPressed?.call();
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
          currentValue: currentValue,
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
              ? '$effectiveTooltip: $currentValue'
              : '${context.loc.font}: $currentValue';
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
                    currentValue = keyName ?? _defaultDisplayText;
                  } else {
                    currentValue = _defaultDisplayText;
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
              iconTheme: iconTheme,
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
              currentValue,
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
          Icon(
            Icons.arrow_drop_down,
            size: iconSize * iconButtonFactor,
            // color: iconTheme?.iconUnselectedFillColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }
}
