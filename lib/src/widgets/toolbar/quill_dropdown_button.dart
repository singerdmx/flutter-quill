import 'package:flutter/material.dart';
import '../../models/themes/quill_icon_theme.dart';

class QuillDropdownButton<T> extends StatefulWidget {
  const QuillDropdownButton({
    required this.initialValue,
    required this.items,
    required this.rawitemsmap,
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
  final T initialValue;
  final List<PopupMenuEntry<T>> items;
  final Map<String, int> rawitemsmap;
  final ValueChanged<T> onSelected;
  final QuillIconTheme? iconTheme;

  @override
  _QuillDropdownButtonState<T> createState() => _QuillDropdownButtonState<T>();
}

// ignore: deprecated_member_use_from_same_package
class _QuillDropdownButtonState<T> extends State<QuillDropdownButton<T>> {
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _currentValue =
        widget.rawitemsmap.keys.elementAt(widget.initialValue as int);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: (widget.iconSize * 1.81)),
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
      // widget.elevation ?? popupMenuTheme.elevation,
      initialValue: widget.initialValue,
      items: widget.items,
      position: position,
      shape: popupMenuTheme.shape,
      // widget.shape ?? popupMenuTheme.shape,
      color: popupMenuTheme.color, // widget.color ?? popupMenuTheme.color,
      // captureInheritedThemes: widget.captureInheritedThemes,
    ).then((newValue) {
      if (!mounted) return null;
      if (newValue == null) {
        // if (widget.onCanceled != null) widget.onCanceled();
        return null;
      }
      setState(() {
        _currentValue = widget.rawitemsmap.entries
            .firstWhere((element) => element.value == newValue,
                orElse: () => widget.rawitemsmap.entries.first)
            .key;
        widget.onSelected(newValue);
      });
    });
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10,0,0,0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currentValue.toString(), style: TextStyle(fontSize: widget.iconSize / 1.15, color: widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color)),
          SizedBox(width: widget.iconSize / 3.83),
          Icon(Icons.arrow_drop_down, size: widget.iconSize / 1.15, color: widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color)
        ],
      ),
    );
  }
}
