import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../controller/quill_controller.dart';
import '../config/simple_toolbar_config.dart';
import '../theme/quill_icon_theme.dart';
import 'base_button_options_resolver.dart';

/// The [T] is the options for the button, usually should refresnce itself
/// it's used in [childBuilder] so the developer can custmize this when using it
/// The [I] is extra options for the button, usually for it's state
@internal
abstract class QuillToolbarBaseButtonStateless<T, I> extends StatelessWidget {
  const QuillToolbarBaseButtonStateless({
    required this.controller,
    super.key,
    this.options,
    this.baseOptions,
  });

  final QuillToolbarBaseButtonOptions<T, I>? options;

  final QuillToolbarBaseButtonOptions? baseOptions;

  QuillToolbarButtonOptionsResolver get _optionsResolver =>
      QuillToolbarButtonOptionsResolver(
        baseOptions: baseOptions,
        specificOptions: options,
      );

  final QuillController controller;

  double iconSize(BuildContext context) {
    return _optionsResolver.iconSize ?? kDefaultIconSize;
  }

  double iconButtonFactor(BuildContext context) {
    return _optionsResolver.iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? afterButtonPressed(BuildContext context) {
    return _optionsResolver.afterButtonPressed;
  }

  QuillIconTheme? iconTheme(BuildContext context) {
    return _optionsResolver.iconTheme;
  }

  IconData iconData(BuildContext context) {
    return _optionsResolver.iconData ?? getDefaultIconData(context);
  }

  String tooltip(BuildContext context) {
    return _optionsResolver.tooltip ?? getDefaultTooltip(context);
  }

  QuillToolbarButtonOptionsChildBuilder get childBuilder =>
      _optionsResolver.childBuilder;

  abstract final IconData Function(BuildContext context) getDefaultIconData;
  abstract final String Function(BuildContext context) getDefaultTooltip;

  Widget buildButton(BuildContext context);
  Widget? buildCustomChildBuilder(
    BuildContext context,
  );

  @override
  Widget build(BuildContext context) {
    final childBuilder = _optionsResolver.childBuilder;
    if (childBuilder != null) {
      return buildCustomChildBuilder(context) ?? const SizedBox.shrink();
    }
    return buildButton(context);
  }
}
