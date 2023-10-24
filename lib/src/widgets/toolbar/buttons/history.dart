import 'package:flutter/material.dart';

import '../../../../translations.dart';
import '../../../utils/extensions/build_context.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

class QuillToolbarHistoryButton extends StatefulWidget {
  const QuillToolbarHistoryButton({
    required this.options,
    required this.controller,
    super.key,
  });

  final QuillToolbarHistoryButtonOptions options;
  final QuillController controller;

  @override
  _QuillToolbarHistoryButtonState createState() =>
      _QuillToolbarHistoryButtonState();
}

class _QuillToolbarHistoryButtonState extends State<QuillToolbarHistoryButton> {
  late ThemeData theme;
  var _canPressed = false;

  QuillToolbarHistoryButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return widget.controller;
  }

  @override
  void initState() {
    super.initState();
    _listenForChanges(); // Listen for changes and change it
  }

  void _listenForChanges() {
    _updateCanPressed(); // Set the init state

    // Listen for changes and change it
    controller.changes.listen((event) async {
      _updateCanPressedWithSetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations =
        context.requireQuillToolbarBaseButtonOptions;
    final tooltip = options.tooltip ??
        baseButtonConfigurations.tooltip ??
        (options.isUndo ? 'Undo'.i18n : 'Redo'.i18n);
    final iconData = options.iconData ??
        baseButtonConfigurations.iconData ??
        (options.isUndo ? Icons.undo_outlined : Icons.redo_outlined);
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations.childBuilder;
    final iconSize = options.iconSize ??
        context.requireQuillToolbarBaseButtonOptions.globalIconSize;
    final iconTheme = options.iconTheme ?? baseButtonConfigurations.iconTheme;

    final afterButtonPressed = options.afterButtonPressed ??
        baseButtonConfigurations.afterButtonPressed;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarHistoryButtonOptions(
          isUndo: options.isUndo,
          afterButtonPressed: afterButtonPressed,
          controller: controller,
          iconData: iconData,
          iconSize: iconSize,
          iconTheme: iconTheme,
          tooltip: tooltip,
        ),
        QuillToolbarHistoryButtonExtraOptions(
          onPressed: () {
            _updateHistory();
            afterButtonPressed?.call();
          },
          canPressed: _canPressed,
          controller: controller,
          context: context,
        ),
      );
    }

    theme = Theme.of(context);

    final fillColor = iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillToolbarIconButton(
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      icon: Icon(
        iconData,
        size: iconSize,
        color: _canPressed
            ? iconTheme?.iconUnselectedColor ?? theme.iconTheme.color
            : iconTheme?.disabledIconColor ?? theme.disabledColor,
      ),
      fillColor: fillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: _updateHistory,
      afterPressed: afterButtonPressed,
    );
  }

  void _updateCanPressedWithSetState() {
    if (!mounted) return;

    setState(_updateCanPressed);
  }

  void _updateCanPressed() {
    if (options.isUndo) {
      _canPressed = controller.hasUndo;
      return;
    }
    _canPressed = controller.hasRedo;
  }

  void _updateHistory() {
    if (options.isUndo) {
      if (controller.hasUndo) {
        controller.undo();
      }
      // _updateCanPressed(); // We are already listeneting for the changes
      return;
    }

    if (controller.hasRedo) {
      controller.redo();
      // _updateCanPressed(); // We are already listeneting for the changes
    }
  }
}
