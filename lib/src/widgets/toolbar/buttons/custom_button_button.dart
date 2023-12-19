import 'package:flutter/material.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

class QuillToolbarCustomButton extends StatelessWidget {
  const QuillToolbarCustomButton({
    required this.controller,
    this.options = const QuillToolbarCustomButtonOptions(),
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

    return QuillToolbarIconButton(
      icon: options.icon ?? const SizedBox.shrink(),
      tooltip: tooltip,
      onPressed: () => _onPressed(context),
      afterPressed: afterButtonPressed,
    );
  }
}
