import 'package:flutter/material.dart';

import '../../../models/config/toolbar/buttons/indent.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../translations/toolbar.i18n.dart';
import '../../../utils/extensions/build_context.dart';
import '../../controller.dart';
import '../toolbar.dart';

class QuillToolbarIndentButton extends StatefulWidget {
  const QuillToolbarIndentButton({
    required this.controller,
    required this.isIncrease,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final bool isIncrease;
  final QuillToolbarIndentButtonOptions options;

  @override
  _QuillToolbarIndentButtonState createState() =>
      _QuillToolbarIndentButtonState();
}

class _QuillToolbarIndentButtonState extends State<QuillToolbarIndentButton> {
  QuillToolbarIndentButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return options.controller ?? widget.controller;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions.iconTheme;
  }

  QuillToolbarBaseButtonOptions get baseButtonExtraOptions {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  IconData get iconData {
    return options.iconData ??
        baseButtonExtraOptions.iconData ??
        (widget.isIncrease
            ? Icons.format_indent_increase
            : Icons.format_indent_decrease);
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        (widget.isIncrease ? 'Increase indent'.i18n : 'Decrease indent'.i18n);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillToolbarIconButton(
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      icon: Icon(iconData, size: iconSize, color: iconColor),
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () {
        widget.controller.indentSelection(widget.isIncrease);
      },
      afterPressed: afterButtonPressed,
    );
  }
}
