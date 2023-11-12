import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/config/quill_configurations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/font.dart';
import '../../controller.dart';

class QuillToolbarFontSizeButton extends StatefulWidget {
  QuillToolbarFontSizeButton({
    required this.options,
    required this.controller,
    required this.defaultDisplayText,
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? true),
        assert(options.initialValue == null ||
            (options.initialValue?.isNotEmpty ?? true));

  final QuillToolbarFontSizeButtonOptions options;

  final String defaultDisplayText;

  /// Since we can't get the state from the instace of the widget for comparing
  /// in [didUpdateWidget] then we will have to store reference here
  final QuillController controller;

  @override
  QuillToolbarFontSizeButtonState createState() =>
      QuillToolbarFontSizeButtonState();
}

class QuillToolbarFontSizeButtonState
    extends State<QuillToolbarFontSizeButton> {
  String _currentValue = '';

  QuillToolbarFontSizeButtonOptions get options {
    return widget.options;
  }

  Map<String, String> get rawItemsMap {
    final fontSizes = options.rawItemsMap ??
        context.requireQuillToolbarConfigurations.fontSizesValues ??
        {
          context.loc.small: 'small',
          context.loc.large: 'large',
          context.loc.huge: 'huge',
          context.loc.clear: '0'
        };
    return fontSizes;
  }

  String get _defaultDisplayText {
    return options.initialValue ?? widget.defaultDisplayText;
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

  @override
  void didUpdateWidget(covariant QuillToolbarFontSizeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller == oldWidget.controller) {
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

  String? _getKeyName(dynamic value) {
    for (final entry in rawItemsMap.entries) {
      if (getFontSize(entry.value) == getFontSize(value)) {
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

  double get iconButtonFactor {
    final baseIconFactor =
        context.requireQuillToolbarBaseButtonOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
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
        context.loc.fontSize;
  }

  void _onPressed() {
    _showMenu();
    afterButtonPressed?.call();
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
          tooltip: tooltip,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: iconTheme,
          afterButtonPressed: afterButtonPressed,
          controller: controller,
        ),
        QuillToolbarFontSizeButtonExtraOptions(
          controller: controller,
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
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
      child: UtilityWidgets.maybeTooltip(
        message: tooltip,
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
        for (final MapEntry<String, String> fontSize in rawItemsMap.entries)
          PopupMenuItem<String>(
            key: ValueKey(fontSize.key),
            value: fontSize.value,
            height: options.itemHeight ?? kMinInteractiveDimension,
            padding: options.itemPadding,
            child: Text(
              fontSize.key.toString(),
              style: TextStyle(
                color: fontSize.value == '0' ? options.defaultItemColor : null,
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
        controller.formatSelection(Attribute.fromKeyValue(
            'size', newValue == '0' ? null : getFontSize(newValue)));
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
