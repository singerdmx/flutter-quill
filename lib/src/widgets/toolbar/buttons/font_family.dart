import 'package:flutter/material.dart';

import '../../../models/config/toolbar/buttons/font_family.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../translations/toolbar.i18n.dart';
import '../../../utils/extensions/build_context.dart';
import '../../../utils/extensions/quill_controller.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';

class QuillToolbarFontFamilyButton extends StatefulWidget {
  QuillToolbarFontFamilyButton({
    required this.options,
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? (true)),
        assert(
          options.initialValue == null || options.initialValue!.isNotEmpty,
        );

  final QuillToolbarFontFamilyButtonOptions options;

  @override
  _QuillToolbarFontFamilyButtonState createState() =>
      _QuillToolbarFontFamilyButtonState();
}

class _QuillToolbarFontFamilyButtonState
    extends State<QuillToolbarFontFamilyButton> {
  late String _defaultDisplayText;
  String _currentValue = '';

  QuillToolbarFontFamilyButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return options.controller.notNull(context);
  }

  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    await Future.delayed(Duration.zero);
    setState(() {
      _currentValue = _defaultDisplayText = options.initialValue ?? 'Font'.i18n;
    });
    controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QuillToolbarFontFamilyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller != controller) {
      controller
        ..removeListener(_didChangeEditingValue)
        ..addListener(_didChangeEditingValue);
    }
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
          'Clear'.i18n: 'Clear'
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

  double get iconSize {
    final iconSize = options.iconSize;
    return iconSize ?? 40;
    // final baseFontSize =
    //     context.requireQuillToolbarBaseButtonOptions.globalIconSize;
    // if (baseFontSize != iconSize) {
    //   return 40;
    // }
    // return iconSize ?? baseFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations =
        context.requireQuillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarFontFamilyButtonExtraOptions(
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: iconSize * 1.81,
        width: options.width,
      ),
      child: UtilityWidgets.maybeWidget(
        enabled: (options.tooltip ?? '').isNotEmpty ||
            options.overrideTooltipByFontFamily,
        wrapper: (child) {
          var effectiveTooltip = options.tooltip ?? '';
          if (options.overrideTooltipByFontFamily) {
            effectiveTooltip = effectiveTooltip.isNotEmpty
                ? '$effectiveTooltip: $_currentValue'
                : '${'Font'.i18n}: $_currentValue';
          }
          return Tooltip(message: effectiveTooltip, child: child);
        },
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(options.iconTheme?.borderRadius ?? 2),
          ),
          fillColor: options.fillColor,
          elevation: 0,
          hoverElevation: options.hoverElevation,
          highlightElevation: options.hoverElevation,
          onPressed: () {
            _showMenu();
            options.afterButtonPressed?.call();
          },
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
    if (!mounted) return;
    if (newValue == null) {
      return;
    }
    final keyName = _getKeyName(newValue);
    setState(() {
      _currentValue = keyName ?? _defaultDisplayText;
      if (keyName != null) {
        controller.formatSelection(
          Attribute.fromKeyValue('font', newValue == 'Clear' ? null : newValue),
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
                    color: options.iconTheme?.iconUnselectedColor ??
                        theme.iconTheme.color,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize / 1.15,
            color:
                options.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }
}
