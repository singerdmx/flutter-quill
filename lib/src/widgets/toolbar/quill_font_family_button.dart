import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/style.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../translations/toolbar.i18n.dart';
import '../../utils/widgets.dart';
import '../controller.dart';

class QuillFontFamilyButton extends StatefulWidget {
  const QuillFontFamilyButton({
    required this.rawItemsMap,
    required this.attribute,
    required this.controller,
    @Deprecated('It is not required because of `rawItemsMap`') this.items,
    this.onSelected,
    this.iconSize = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.iconTheme,
    this.afterButtonPressed,
    this.tooltip,
    this.padding,
    this.style,
    this.width,
    this.renderFontFamilies = true,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.overrideTooltipByFontFamily = false,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
    Key? key,
  })  : assert(rawItemsMap.length > 0),
        assert(initialValue == null || initialValue.length > 0),
        super(key: key);

  final double iconSize;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  @Deprecated('It is not required because of `rawItemsMap`')
  final List<PopupMenuEntry<String>>? items;
  final Map<String, String> rawItemsMap;
  final ValueChanged<String>? onSelected;
  final QuillIconTheme? iconTheme;
  final Attribute attribute;
  final QuillController controller;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final bool renderFontFamilies;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final bool overrideTooltipByFontFamily;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;

  @override
  _QuillFontFamilyButtonState createState() => _QuillFontFamilyButtonState();
}

class _QuillFontFamilyButtonState extends State<QuillFontFamilyButton> {
  late String _defaultDisplayText;
  late String _currentValue;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _currentValue = _defaultDisplayText = widget.initialValue ?? 'Font'.i18n;
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QuillFontFamilyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
    }
  }

  void _didChangeEditingValue() {
    final attribute = _selectionStyle.attributes[widget.attribute.key];
    if (attribute == null) {
      setState(() => _currentValue = _defaultDisplayText);
      return;
    }
    final keyName = _getKeyName(attribute.value);
    setState(() => _currentValue = keyName ?? _defaultDisplayText);
  }

  String? _getKeyName(String value) {
    for (final entry in widget.rawItemsMap.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: widget.iconSize * 1.81,
        width: widget.width,
      ),
      child: UtilityWidgets.maybeWidget(
        enabled: (widget.tooltip ?? '').isNotEmpty ||
            widget.overrideTooltipByFontFamily,
        wrapper: (child) {
          var effectiveTooltip = widget.tooltip ?? '';
          if (widget.overrideTooltipByFontFamily) {
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
                  BorderRadius.circular(widget.iconTheme?.borderRadius ?? 2)),
          fillColor: widget.fillColor,
          elevation: 0,
          hoverElevation: widget.hoverElevation,
          highlightElevation: widget.hoverElevation,
          onPressed: () {
            _showMenu();
            widget.afterButtonPressed?.call();
          },
          child: _buildContent(context),
        ),
      ),
    );
  }

  void _showMenu() {
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
    showMenu<String>(
      context: context,
      elevation: 4,
      items: [
        for (final MapEntry<String, String> fontFamily
            in widget.rawItemsMap.entries)
          PopupMenuItem<String>(
            key: ValueKey(fontFamily.key),
            value: fontFamily.value,
            height: widget.itemHeight ?? kMinInteractiveDimension,
            padding: widget.itemPadding,
            child: Text(
              fontFamily.key.toString(),
              style: TextStyle(
                fontFamily: widget.renderFontFamilies ? fontFamily.value : null,
                color: fontFamily.value == 'Clear'
                    ? widget.defaultItemColor
                    : null,
              ),
            ),
          ),
      ],
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    ).then((newValue) {
      if (!mounted) return;
      if (newValue == null) {
        return;
      }
      final keyName = _getKeyName(newValue);
      setState(() {
        _currentValue = keyName ?? _defaultDisplayText;
        if (keyName != null) {
          widget.controller.formatSelection(Attribute.fromKeyValue(
              'font', newValue == 'Clear' ? null : newValue));
          widget.onSelected?.call(newValue);
        }
      });
    });
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final hasFinalWidth = widget.width != null;
    return Padding(
      padding: widget.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
              overflow: widget.labelOverflow,
              style: widget.style ??
                  TextStyle(
                      fontSize: widget.iconSize / 1.15,
                      color: widget.iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.arrow_drop_down,
              size: widget.iconSize / 1.15,
              color: widget.iconTheme?.iconUnselectedColor ??
                  theme.iconTheme.color)
        ],
      ),
    );
  }
}
