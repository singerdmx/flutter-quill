import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'models/formula_configurations.dart';

class QuillToolbarFormulaButton extends StatelessWidget {
  const QuillToolbarFormulaButton({
    required this.controller,
    this.options = const QuillToolbarFormulaButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarFormulaButtonOptions options;

  double _iconSize(BuildContext context) {
    final iconSize = options.iconSize;
    return iconSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ?? Icons.functions;
  }

  String _tooltip(BuildContext context) {
    // TODO: Add insert formula translation
    return options.tooltip ?? 'Insert formula';
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);

    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);
    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarFormulaButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
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
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
      ),
      tooltip: tooltip,
      onPressed: () => _sharedOnPressed(context),
      isSelected: false,
      iconTheme: iconTheme,
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(index, length, BlockEmbed.formula(''), null);
  }
}
