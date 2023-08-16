import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/style.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../translations/toolbar.i18n.dart';
import '../../utils/font.dart';
import '../../utils/widgets.dart';
import '../controller.dart';

class QuillFontSizeButton extends StatefulWidget {
  const QuillFontSizeButton({
    required this.rawItemsMap,
    required this.attribute,
    required this.controller,
    this.onSelected,
    @Deprecated('It is not required because of `rawItemsMap`') this.items,
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
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
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
  final String? initialValue;
  final TextOverflow labelOverflow;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;

  @override
  _QuillFontSizeButtonState createState() => _QuillFontSizeButtonState();
}

class _QuillFontSizeButtonState extends State<QuillFontSizeButton> {
  late String _defaultDisplayText;
  late String _currentValue;
  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _currentValue = _defaultDisplayText = widget.initialValue ?? 'Size'.i18n;
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QuillFontSizeButton oldWidget) {
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

  String? _getKeyName(dynamic value) {
    for (final entry in widget.rawItemsMap.entries) {
      if (getFontSize(entry.value) == getFontSize(value)) {
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
      child: UtilityWidgets.maybeTooltip(
        message: widget.tooltip,
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
        for (final MapEntry<String, String> fontSize
            in widget.rawItemsMap.entries)
          PopupMenuItem<String>(
            key: ValueKey(fontSize.key),
            value: fontSize.value,
            height: widget.itemHeight ?? kMinInteractiveDimension,
            padding: widget.itemPadding,
            child: Text(
              fontSize.key.toString(),
              style: TextStyle(
                color: fontSize.value == '0' ? widget.defaultItemColor : null,
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
              'size', newValue == '0' ? null : getFontSize(newValue)));
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
            child: Text(_currentValue,
                overflow: widget.labelOverflow,
                style: widget.style ??
                    TextStyle(
                        fontSize: widget.iconSize / 1.15,
                        color: widget.iconTheme?.iconUnselectedColor ??
                            theme.iconTheme.color)),
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
