import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../../translations.dart';
import '../../../utils/extensions/build_context.dart';
import '../../../utils/extensions/quill_controller.dart';
import '../../controller.dart';
import '../toolbar.dart';

class QuillToolbarHistoryButton extends StatefulWidget {
  const QuillToolbarHistoryButton({
    required this.options,
    super.key,
  });

  final QuillToolbarHistoryButtonOptions options;

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
    return options.controller.notNull(context);
  }

  @override
  void initState() {
    super.initState();
    _listenForChanges(); // Listen for changes and change it
  }

  Future<void> _listenForChanges() async {
    if (isFlutterTest()) {
      // We don't need to listen for changes in the tests
      return;
    }
    await Future.delayed(Duration.zero); // Wait for the widget to built
    _updateCanPressed(); // Set the init state

    // Listen for changes and change it
    controller.changes.listen((event) async {
      _updateCanPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

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

    final fillColor = iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;

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

  void _updateCanPressed() {
    if (!mounted) return;

    setState(() {
      if (options.isUndo) {
        _canPressed = controller.hasUndo;
        return;
      }
      _canPressed = controller.hasRedo;
    });
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
