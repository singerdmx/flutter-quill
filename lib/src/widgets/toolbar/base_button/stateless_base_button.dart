import 'package:flutter/material.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

/// The [T] is the options for the button, usually should refresnce itself
/// it's used in [childBuilder] so the developer can custmize this when using it
/// The [I] is extra options for the button, usually for it's state
abstract class QuillToolbarBaseButton<T, I> extends StatelessWidget {
  const QuillToolbarBaseButton({
    required this.controller,
    super.key,
    this.options,
  });

  final QuillToolbarBaseButtonOptions<T, I>? options;

  final QuillController controller;

  double iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context)?.iconSize;
    final iconSize = options?.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double iconButtonFactor(BuildContext context) {
    final baseIconFactor = baseButtonExtraOptions(context)?.iconButtonFactor;
    final iconButtonFactor = options?.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? afterButtonPressed(BuildContext context) {
    return options?.afterButtonPressed ??
        baseButtonExtraOptions(context)?.afterButtonPressed;
  }

  QuillIconTheme? iconTheme(BuildContext context) {
    return options?.iconTheme ?? baseButtonExtraOptions(context)?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? baseButtonExtraOptions(BuildContext context) {
    return context.quillToolbarBaseButtonOptions;
  }

  IconData iconData(BuildContext context) {
    return options?.iconData ??
        baseButtonExtraOptions(context)?.iconData ??
        getDefaultIconData(context);
  }

  String tooltip(BuildContext context) {
    return options?.tooltip ??
        baseButtonExtraOptions(context)?.tooltip ??
        getDefaultIconSize(context);
  }

  abstract final IconData Function(BuildContext context) getDefaultIconData;
  abstract final String Function(BuildContext context) getDefaultIconSize;

  Widget buildButton(BuildContext context);
  Widget? buildCustomChildBuilder(
    BuildContext context,
  );

  @override
  Widget build(BuildContext context) {
    final childBuilder = options?.childBuilder;
    if (childBuilder != null) {
      return buildCustomChildBuilder(context) ?? const SizedBox.shrink();
    }
    return buildButton(context);
  }
}
