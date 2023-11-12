import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../extensions/quill_provider.dart';

class QuillEditorCheckboxPoint extends StatefulWidget {
  const QuillEditorCheckboxPoint({
    required this.size,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.uiBuilder,
    super.key,
  });

  final double size;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final QuillCheckboxBuilder? uiBuilder;

  @override
  QuillEditorCheckboxPointState createState() =>
      QuillEditorCheckboxPointState();
}

class QuillEditorCheckboxPointState extends State<QuillEditorCheckboxPoint> {
  @override
  Widget build(BuildContext context) {
    final uiBuilder = widget.uiBuilder;
    if (uiBuilder != null) {
      return uiBuilder.build(
        context: context,
        isChecked: widget.value,
        onChanged: widget.onChanged,
      );
    }
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
    final child = Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: EdgeInsetsDirectional.only(end: widget.size / 2),
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
                ? Icon(
                    Icons.check,
                    size: widget.size,
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
      ),
    );
    if (context.requireQuillSharedConfigurations.animationConfigurations
        .checkBoxPointItem) {
      return Animate(
        effects: const [
          SlideEffect(
            duration: Duration(milliseconds: 70),
          ),
          ScaleEffect(
            duration: Duration(milliseconds: 70),
          )
        ],
        child: child,
      );
    }
    return child;
  }
}

abstract class QuillCheckboxBuilder {
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  });
}
