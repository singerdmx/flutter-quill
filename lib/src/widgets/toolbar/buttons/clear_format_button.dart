import 'package:flutter/material.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

class QuillToolbarClearFormatButton extends StatelessWidget {
  const QuillToolbarClearFormatButton({
    required QuillController controller,
    this.options = const QuillToolbarClearFormatButtonOptions(),
    super.key,
  }) : _controller = controller;

  final QuillController _controller;
  final QuillToolbarClearFormatButtonOptions options;

  QuillController get controller {
    return _controller;
  }

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
        Icons.format_clear;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        (context.loc.clearFormat);
  }

  void _sharedOnPressed() {
    final attrs = <Attribute>{};
    for (final style in controller.getAllSelectionStyles()) {
      for (final attr in style.attributes.values) {
        attrs.add(attr);
      }
    }
    for (final attr in attrs) {
      controller.formatSelection(Attribute.clone(attr, null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;
    final afterButtonPressed = _afterButtonPressed(context);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarClearFormatButtonOptions(
          afterButtonPressed: afterButtonPressed,
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: iconTheme,
          tooltip: tooltip,
        ),
        QuillToolbarClearFormatButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _sharedOnPressed();
            _afterButtonPressed(context)?.call();
          },
        ),
      );
    }

    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;

    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(iconData, size: iconSize * iconButtonFactor, color: iconColor),
      isFilled: false,
      onPressed: _sharedOnPressed,
      afterPressed: afterButtonPressed,
    );
  }
}
