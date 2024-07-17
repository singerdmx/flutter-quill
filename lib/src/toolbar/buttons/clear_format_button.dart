import 'package:flutter/material.dart';

import '../../document/attribute.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/stateless_base_button.dart';
import '../base_toolbar.dart';

class QuillToolbarClearFormatButton extends QuillToolbarBaseButton {
  const QuillToolbarClearFormatButton({
    required super.controller,
    super.options,
    super.key,
  });

  void _sharedOnPressed() {
    final attributes = <Attribute>{};
    for (final style in controller.getAllSelectionStyles()) {
      for (final attr in style.attributes.values) {
        attributes.add(attr);
      }
    }
    for (final attribute in attributes) {
      controller.formatSelection(Attribute.clone(attribute, null));
    }
  }

  @override
  Widget buildButton(BuildContext context) {
    return QuillToolbarIconButton(
      tooltip: tooltip(context),
      icon: Icon(
        iconData(context),
        size: iconSize(context) * iconButtonFactor(context),
      ),
      isSelected: false,
      onPressed: _sharedOnPressed,
      afterPressed: afterButtonPressed(context),
      iconTheme: iconTheme(context),
    );
  }

  @override
  Widget? buildCustomChildBuilder(BuildContext context) {
    return options?.childBuilder?.call(
      options,
      QuillToolbarClearFormatButtonExtraOptions(
        controller: controller,
        context: context,
        onPressed: () {
          _sharedOnPressed();
          afterButtonPressed(context)?.call();
        },
      ),
    );
  }

  @override
  IconData Function(BuildContext context) get getDefaultIconData =>
      (context) => Icons.format_clear;

  @override
  String Function(BuildContext context) get getDefaultTooltip =>
      (context) => context.loc.clearFormat;
}
