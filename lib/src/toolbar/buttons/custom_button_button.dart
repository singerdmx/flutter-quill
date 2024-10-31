import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../base_button/base_button_options_resolver.dart';
import '../config/base_button_options.dart';
import '../config/buttons/custom_button_options.dart';
import 'quill_icon_button.dart';

class QuillToolbarCustomButton extends StatelessWidget {
  const QuillToolbarCustomButton({
    required this.controller,
    this.options = const QuillToolbarCustomButtonOptions(),

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    this.baseOptions,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCustomButtonOptions options;
  final QuillToolbarBaseButtonOptions? baseOptions;

  void _onPressed(BuildContext context) => options.onPressed?.call();

  QuillToolbarButtonOptionsResolver get _optionsResolver =>
      QuillToolbarButtonOptionsResolver(
        baseOptions: baseOptions,
        specificOptions: options,
      );

  @override
  Widget build(BuildContext context) {
    final childBuilder = _optionsResolver.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarCustomButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () {
            _onPressed(context);
            _optionsResolver.afterButtonPressed?.call();
          },
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: options.icon ?? const SizedBox.shrink(),
      isSelected: false,
      tooltip: _optionsResolver.tooltip,
      onPressed: () => _onPressed(context),
      afterPressed: _optionsResolver.afterButtonPressed,
      iconTheme: _optionsResolver.iconTheme,
    );
  }
}
