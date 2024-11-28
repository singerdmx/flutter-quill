import 'package:flutter/material.dart';

import '../../document/attribute.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/stateless_base_button.dart';
import '../config/buttons/clear_format_options.dart';
import 'quill_icon_button.dart';

class QuillToolbarClearFormatButton extends QuillToolbarBaseButtonStateless {
  const QuillToolbarClearFormatButton({
    required super.controller,
    QuillToolbarClearFormatButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  }) : super(options: options);

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
