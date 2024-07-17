import 'package:flutter/material.dart';

import '../../controller/quill_controller.dart';
import '../config/simple_toolbar_configurations.dart';
import '../simple_toolbar_provider.dart';
import '../theme/quill_icon_theme.dart';

// TODO: Use this later or remove it

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
        baseButtonExtraOptions(context)?.afterButtonPressed ??
        () => controller.editorFocusNode?.requestFocus();
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
        getDefaultTooltip(context);
  }

  abstract final IconData Function(BuildContext context) getDefaultIconData;
  abstract final String Function(BuildContext context) getDefaultTooltip;

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
