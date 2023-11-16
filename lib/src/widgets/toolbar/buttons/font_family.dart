import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/config/toolbar/buttons/font_family.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';

class QuillToolbarFontFamilyButton extends StatefulWidget {
  QuillToolbarFontFamilyButton({
    required this.options,
    required this.controller,
    required this.defaultDispalyText,
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? (true)),
        assert(
          options.initialValue == null || options.initialValue!.isNotEmpty,
        );

  final QuillToolbarFontFamilyButtonOptions options;

  final String defaultDispalyText;

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

  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {
    _currentValue = _defaultDisplayText;
    controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  String get _defaultDisplayText {
    return options.initialValue ?? widget.defaultDispalyText;
  }

  @override
  void didUpdateWidget(covariant QuillToolbarFontFamilyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == controller) {
      return;
    }
    controller
      ..removeListener(_didChangeEditingValue)
      ..addListener(_didChangeEditingValue);
  }

  void _didChangeEditingValue() {
    final attribute = _selectionStyle.attributes[options.attribute.key];
    if (attribute == null) {
      setState(() => _currentValue = _defaultDisplayText);
      return;
    }
    final keyName = _getKeyName(attribute.value);
    setState(() => _currentValue = keyName ?? _defaultDisplayText);
  }

  Map<String, String> get rawItemsMap {
    // context.requireQuillToolbarConfigurations.buttonOptions;
    final rawItemsMap = options.rawItemsMap ??
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
    final baseFontSize =
        context.requireQuillToolbarBaseButtonOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        context.requireQuillToolbarBaseButtonOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ??
        context.requireQuillToolbarBaseButtonOptions.iconTheme;
  }

  String get tooltip {
    return options.tooltip ??
        context.requireQuillToolbarBaseButtonOptions.tooltip ??
        context.loc.fontFamily;
  }

  void _onPressed() {
    _showMenu();
    options.afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations =
        context.requireQuillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options.copyWith(
          iconSize: iconSize,
          rawItemsMap: rawItemsMap,
          iconTheme: iconTheme,
          tooltip: tooltip,
          afterButtonPressed: afterButtonPressed,
        ),
        QuillToolbarFontFamilyButtonExtraOptions(
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
          controller: controller,
          context: context,
          onPressed: _onPressed,
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: iconSize * 1.81,
        width: options.width,
      ),
      child: UtilityWidgets.maybeWidget(
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
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(iconTheme?.borderRadius ?? 2),
          ),
          fillColor: options.fillColor,
          elevation: 0,
          hoverElevation: options.hoverElevation,
          highlightElevation: options.hoverElevation,
          onPressed: _onPressed,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Future<void> _showMenu() async {
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final newValue = await showMenu<String>(
      context: context,
      elevation: 4,
      items: [
        for (final MapEntry<String, String> fontFamily in rawItemsMap.entries)
          PopupMenuItem<String>(
            key: ValueKey(fontFamily.key),
            value: fontFamily.value,
            height: options.itemHeight ?? kMinInteractiveDimension,
            padding: options.itemPadding,
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
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    );
    if (!mounted) {
      return;
    }
    if (newValue == null) {
      return;
    }
    final keyName = _getKeyName(newValue);
    setState(() {
      _currentValue = keyName ?? _defaultDisplayText;
      if (keyName != null) {
        controller.formatSelection(
          Attribute.fromKeyValue(
            'font',
            newValue == 'Clear' ? null : newValue,
          ),
        );
        options.onSelected?.call(newValue);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
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
              _currentValue,
              maxLines: 1,
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                    color:
                        iconTheme?.iconUnselectedColor ?? theme.iconTheme.color,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize / 1.15,
            color: iconTheme?.iconUnselectedColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }
}
