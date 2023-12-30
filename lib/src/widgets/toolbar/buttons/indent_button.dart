import 'package:flutter/material.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/config/toolbar/simple_toolbar_configurations.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart'
    show QuillToolbarBaseButtonOptions, QuillToolbarIconButton;

class QuillToolbarIndentButton extends StatefulWidget {
  const QuillToolbarIndentButton({
    required this.controller,
    required this.isIncrease,
    this.options = const QuillToolbarIndentButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final bool isIncrease;
  final QuillToolbarIndentButtonOptions options;

  @override
  QuillToolbarIndentButtonState createState() =>
      QuillToolbarIndentButtonState();
}

class QuillToolbarIndentButtonState extends State<QuillToolbarIndentButton> {
  QuillToolbarIndentButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return widget.controller;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions?.iconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions?.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions {
    return context.quillToolbarBaseButtonOptions;
  }

  IconData get iconData {
    return options.iconData ??
        baseButtonExtraOptions?.iconData ??
        (widget.isIncrease
            ? Icons.format_indent_increase
            : Icons.format_indent_decrease);
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions?.tooltip ??
        (widget.isIncrease
            ? context.loc.increaseIndent
            : context.loc.decreaseIndent);
  }

  void _sharedOnPressed() {
    widget.controller.indentSelection(widget.isIncrease);
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions?.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarIndentButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _sharedOnPressed();
            afterButtonPressed?.call();
          },
        ),
      );
    }

    // final iconColor = iconTheme?.iconUnselectedFillColor;
    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
        // color: iconColor,
      ),
      isSelected: false,
      onPressed: _sharedOnPressed,
      afterPressed: afterButtonPressed,
      iconTheme: iconTheme,
    );
  }
}
