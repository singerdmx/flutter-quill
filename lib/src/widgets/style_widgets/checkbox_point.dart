import 'package:flutter/material.dart';

class CheckboxPoint extends StatefulWidget {
  const CheckboxPoint({
    required this.size,
    required this.value,
    required this.enabled,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final double size;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  _CheckboxPointState createState() => _CheckboxPointState();
}

class _CheckboxPointState extends State<CheckboxPoint> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = widget.value
        ? (widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.5))
        : theme.colorScheme.surface;
    final borderColor = widget.value
        ? (widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0))
        : (widget.enabled
            ? theme.colorScheme.onSurface.withOpacity(0.5)
            : theme.colorScheme.onSurface.withOpacity(0.3));
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Material(
          color: fillColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: InkWell(
            onTap:
                widget.enabled ? () => widget.onChanged(!widget.value) : null,
            child: widget.value
                ? Icon(Icons.check,
                    size: widget.size, color: theme.colorScheme.onPrimary)
                : null,
          ),
        ),
      ),
    );
  }
}
