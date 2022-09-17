import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class HistoryButton extends StatefulWidget {
  const HistoryButton({
    required this.icon,
    required this.controller,
    required this.undo,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final bool undo;
  final QuillController controller;
  final QuillIconTheme? iconTheme;
  final VoidCallback? afterButtonPressed;

  @override
  _HistoryButtonState createState() => _HistoryButtonState();
}

class _HistoryButtonState extends State<HistoryButton> {
  Color? _iconColor;
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    _setIconColor();

    final fillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    widget.controller.changes.listen((event) async {
      _setIconColor();
    });
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      icon: Icon(widget.icon, size: widget.iconSize, color: _iconColor),
      fillColor: fillColor,
      borderRadius: widget.iconTheme?.borderRadius ?? 2,
      onPressed: _changeHistory,
      afterPressed: widget.afterButtonPressed,
    );
  }

  void _setIconColor() {
    if (!mounted) return;

    if (widget.undo) {
      setState(() {
        _iconColor = widget.controller.hasUndo
            ? widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color
            : widget.iconTheme?.disabledIconColor ?? theme.disabledColor;
      });
    } else {
      setState(() {
        _iconColor = widget.controller.hasRedo
            ? widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color
            : widget.iconTheme?.disabledIconColor ?? theme.disabledColor;
      });
    }
  }

  void _changeHistory() {
    if (widget.undo) {
      if (widget.controller.hasUndo) {
        widget.controller.undo();
      }
    } else {
      if (widget.controller.hasRedo) {
        widget.controller.redo();
      }
    }

    _setIconColor();
  }
}
