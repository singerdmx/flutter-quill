import 'package:flutter/material.dart';

import '../../../controller/quill_controller.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../simple_toolbar.dart';

class QuillToolbarSearchButton extends StatelessWidget {
  const QuillToolbarSearchButton({
    required this.controller,
    this.options = const QuillToolbarSearchButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSearchButtonOptions options;

  @override
  Widget build(BuildContext context) {
    final iconSize = options.iconSize ?? kDefaultIconSize;
    final iconButtonFactor =
        options.iconButtonFactor ?? kDefaultIconButtonFactor;
    final afterButtonPressed = options.afterButtonPressed;

    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarSearchButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _sharedOnPressed(context);
            afterButtonPressed?.call();
          },
        ),
      );
    }

    return QuillToolbarIconButton(
      tooltip: options.tooltip ?? (context.loc.search),
      icon: Icon(
        options.iconData ?? Icons.search,
        size: iconSize * iconButtonFactor,
      ),
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      afterPressed: afterButtonPressed,
      iconTheme: options.iconTheme,
    );
  }

  Future<void> _sharedOnPressed(BuildContext context) async {
    final customCallback = options.customOnPressedCallback;
    if (customCallback != null) {
      await customCallback(
        controller,
      );
      return;
    }
    await showDialog<String>(
      context: context,
      builder: (_) => QuillToolbarSearchDialog(
        controller: controller,
        dialogTheme: options.dialogTheme,
        searchBarAlignment: options.searchBarAlignment,
      ),
    );
  }
}
