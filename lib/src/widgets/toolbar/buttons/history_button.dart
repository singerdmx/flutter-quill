import 'package:flutter/material.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

class QuillToolbarHistoryButton extends StatefulWidget {
  const QuillToolbarHistoryButton({
    required this.controller,
    required this.isUndo,
    this.options = const QuillToolbarHistoryButtonOptions(),
    super.key,
  });

  /// If this true then it will be the undo button
  /// otherwise it will be redo
  final bool isUndo;

  final QuillToolbarHistoryButtonOptions options;
  final QuillController controller;

  @override
  QuillToolbarHistoryButtonState createState() =>
      QuillToolbarHistoryButtonState();
}

class QuillToolbarHistoryButtonState extends State<QuillToolbarHistoryButton> {
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
    final baseButtonConfigurations = context.quillToolbarBaseButtonOptions;
    final tooltip = options.tooltip ??
        baseButtonConfigurations?.tooltip ??
        (widget.isUndo ? context.loc.undo : context.loc.redo);
    final iconData = options.iconData ??
        baseButtonConfigurations?.iconData ??
        (widget.isUndo ? Icons.undo_outlined : Icons.redo_outlined);
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations?.childBuilder;
    final iconSize = options.iconSize ??
        baseButtonConfigurations?.iconSize ??
        kDefaultIconSize;
    final iconButtonFactor = options.iconButtonFactor ??
        baseButtonConfigurations?.iconButtonFactor ??
        kDefaultIconButtonFactor;
    final iconTheme = options.iconTheme ?? baseButtonConfigurations?.iconTheme;

    final afterButtonPressed = options.afterButtonPressed ??
        baseButtonConfigurations?.afterButtonPressed;

    if (childBuilder != null) {
      return childBuilder(
        options,
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
    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
      ),
      isSelected: false,
      iconTheme: iconTheme,
      onPressed: _canPressed ? _updateHistory : null,
      afterPressed: afterButtonPressed,
    );
  }

  void _updateCanPressedWithSetState() {
    if (!mounted) return;

    setState(_updateCanPressed);
  }

  void _updateCanPressed() {
    if (widget.isUndo) {
      _canPressed = controller.hasUndo;
      return;
    }
    _canPressed = controller.hasRedo;
  }

  void _updateHistory() {
    if (widget.isUndo) {
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
