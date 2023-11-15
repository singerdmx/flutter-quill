import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../models/config/toolbar/buttons/formula.dart';

class QuillToolbarFormulaButton extends StatelessWidget {
  const QuillToolbarFormulaButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarFormulaButtonOptions options;

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

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context).iconData ??
        Icons.functions;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Insert formula';
    // ('Insert formula'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarFormulaButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          fillColor: iconFillColor,
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: iconTheme,
          tooltip: tooltip,
        ),
        QuillToolbarFormulaButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(iconData, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(index, length, BlockEmbed.formula(''), null);
  }
}
