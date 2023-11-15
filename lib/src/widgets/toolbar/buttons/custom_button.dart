import 'package:flutter/material.dart';

import '../../../extensions/quill_provider.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

class QuillToolbarCustomButton extends StatelessWidget {
  const QuillToolbarCustomButton({
    required this.options,
    required this.controller,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCustomButtonOptions options;

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor =
        baseButtonExtraOptions(context).globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context).afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
  }

  QuillToolbarBaseButtonOptions baseButtonExtraOptions(BuildContext context) {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  String? _tooltip(BuildContext context) {
    return options.tooltip ?? baseButtonExtraOptions(context).tooltip;
  }

  void _onPressed(BuildContext context) {
    options.onPressed?.call();
    _afterButtonPressed(context)?.call();
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;
    final afterButtonPressed = _afterButtonPressed(context);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarCustomButtonOptions(
          iconButtonFactor: iconButtonFactor,
          iconSize: iconSize,
          afterButtonPressed: afterButtonPressed,
          controller: controller,
          iconTheme: iconTheme,
          tooltip: tooltip,
          icon: options.icon,
        ),
        QuillToolbarCustomButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _onPressed(context),
        ),
      );
    }

    final theme = Theme.of(context);
    return QuillToolbarIconButton(
      size: iconSize * iconButtonFactor,
      icon: options.icon,
      tooltip: tooltip,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressed(context),
      afterPressed: afterButtonPressed,
      fillColor: iconTheme?.iconUnselectedFillColor ?? theme.canvasColor,
    );
  }
}
