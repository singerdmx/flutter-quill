import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../config/buttons/custom_button_configurations.dart';
import 'quill_icon_button.dart';

class QuillToolbarCustomButton extends StatelessWidget {
  const QuillToolbarCustomButton({
    required this.controller,
    this.options = const QuillToolbarCustomButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCustomButtonOptions options;

  void _onPressed(BuildContext context) {
    options.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarCustomButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () {
            _onPressed(context);
            options.afterButtonPressed?.call();
          },
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: options.icon ?? const SizedBox.shrink(),
      isSelected: false,
      tooltip: options.tooltip,
      onPressed: () => _onPressed(context),
      afterPressed: options.afterButtonPressed,
      iconTheme: options.iconTheme,
    );
  }
}
