import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../base_toolbar.dart';
import '../simple_toolbar_provider.dart';
import '../theme/quill_icon_theme.dart';

class QuillToolbarCustomButton extends StatelessWidget {
  const QuillToolbarCustomButton({
    required this.controller,
    this.options = const QuillToolbarCustomButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCustomButtonOptions options;

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context)?.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context)?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? baseButtonExtraOptions(BuildContext context) {
    return context.quillToolbarBaseButtonOptions;
  }

  String? _tooltip(BuildContext context) {
    return options.tooltip ?? baseButtonExtraOptions(context)?.tooltip;
  }

  void _onPressed(BuildContext context) {
    options.onPressed?.call();
    _afterButtonPressed(context)?.call();
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context)?.childBuilder;
    final afterButtonPressed = _afterButtonPressed(context);

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarCustomButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _onPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: options.icon ?? const SizedBox.shrink(),
      isSelected: false,
      tooltip: tooltip,
      onPressed: () => _onPressed(context),
      afterPressed: afterButtonPressed,
      iconTheme: iconTheme,
    );
  }
}
