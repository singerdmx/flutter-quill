import 'package:flutter/material.dart';
import '../../../../../flutter_quill.dart';
import '../../../../models/documents/attribute.dart';

class MinimalColorButton extends StatefulWidget {
  const MinimalColorButton({
    required this.controller,
    required this.color,
    required this.child,
    this.callback,
    super.key,
  });

  final QuillController controller;
  final Color color;
  final Widget child;
  final VoidCallback? callback;

  @override
  _MinimalColorButtonState createState() => _MinimalColorButtonState();
}

class _MinimalColorButtonState extends State<MinimalColorButton> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSelectionState);
    _updateSelectionState();
  }

  @override
  void didUpdateWidget(covariant MinimalColorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateSelectionState);
      widget.controller.addListener(_updateSelectionState);
      _updateSelectionState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSelectionState);
    super.dispose();
  }

  void _updateSelectionState() {
    final selectionStyle = widget.controller.getSelectionStyle();
    final selectedColor = widget.color;
    final currentColor = selectionStyle.attributes[Attribute.color.key]?.value;
    setState(() {
      _isSelected = currentColor != null && currentColor == colorToHex(selectedColor);
    });
  }

  void _applyColor() {
    final hex = '#${colorToHex(widget.color)}';
    widget.controller.formatSelection(ColorAttribute(hex));
    if(widget.callback != null) {
      widget.callback!();
    }
    _updateSelectionState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.child,
      color: _isSelected ? widget.color : Colors.grey,
      onPressed: _applyColor,
    );
  }
}
