import 'package:flutter/material.dart';

import '../../../models/config/toolbar/buttons/indent.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../translations/toolbar.i18n.dart';
import '../../../utils/extensions/build_context.dart';
import '../../controller.dart';
import '../base_toolbar.dart'
    show
        QuillToolbarBaseButtonOptions,
        QuillToolbarIconButton,
        kIconButtonFactor;

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
    return widget.controller;
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

  void _sharedOnPressed() {
    widget.controller.indentSelection(widget.isIncrease);
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarIndentButtonOptions(
          afterButtonPressed: afterButtonPressed,
          iconData: iconData,
          iconSize: iconSize,
          iconTheme: iconTheme,
          tooltip: tooltip,
        ),
        QuillToolbarIndentButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _sharedOnPressed();
            afterButtonPressed?.call();
          },
        ),
      );
    }
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
      onPressed: _sharedOnPressed,
      afterPressed: afterButtonPressed,
    );
  }
}
