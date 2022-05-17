import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/style.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../utils/font.dart';
import '../controller.dart';

class QuillFontSizeButton<T> extends StatefulWidget {
  const QuillFontSizeButton({
    required this.items,
    required this.rawItemsMap,
    required this.attribute,
    required this.controller,
    required this.onSelected,
    this.iconSize = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final double iconSize;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final List<PopupMenuEntry<T>> items;
  final Map<String, String> rawItemsMap;
  final ValueChanged<T> onSelected;
  final QuillIconTheme? iconTheme;
  final Attribute attribute;
  final QuillController controller;

  @override
  _QuillFontSizeButtonState<T> createState() => _QuillFontSizeButtonState<T>();
}

class _QuillFontSizeButtonState<T> extends State<QuillFontSizeButton<T>> {
  static const defaultDisplayText = 'Size';
  String _currentValue = defaultDisplayText;
  Style get _selectionStyle => widget.controller.getSelectionStyle();

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
  void didUpdateWidget(covariant QuillFontSizeButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
    }
  }

  void _didChangeEditingValue() {
    setState(() => _currentValue = _getKeyName(_selectionStyle.attributes));
  }

  String _getKeyName(Map<String, Attribute> attrs) {
    if (widget.attribute.key != Attribute.size.key) {
      return defaultDisplayText;
    }
    final attribute = attrs[widget.attribute.key];

    if (attribute == null) {
      return defaultDisplayText;
    }
    return widget.rawItemsMap.entries
        .firstWhere(
            (element) =>
                getFontSize(element.value) == getFontSize(attribute.value),
            orElse: () => widget.rawItemsMap.entries.first)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: widget.iconSize * 1.81),
      child: RawMaterialButton(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(widget.iconTheme?.borderRadius ?? 2)),
        fillColor: widget.fillColor,
        elevation: 0,
        hoverElevation: widget.hoverElevation,
        highlightElevation: widget.hoverElevation,
        onPressed: _showMenu,
        child: _buildContent(context),
      ),
    );
  }

  void _showMenu() {
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<T>(
      context: context,
      elevation: 4,
      items: widget.items,
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    ).then((newValue) {
      if (!mounted) return null;
      if (newValue == null) {
        return null;
      }
      setState(() {
        _currentValue = widget.rawItemsMap.entries
            .firstWhere((element) => element.value == newValue,
                orElse: () => widget.rawItemsMap.entries.first)
            .key;
        widget.onSelected(newValue);
      });
    });
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currentValue.toString(),
              style: TextStyle(
                  fontSize: widget.iconSize / 1.15,
                  color: widget.iconTheme?.iconUnselectedColor ??
                      theme.iconTheme.color)),
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
