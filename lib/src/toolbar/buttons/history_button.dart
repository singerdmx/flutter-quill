import 'package:flutter/material.dart';

import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';
import '../base_toolbar.dart';

typedef QuillToolbarHistoryBaseButton = QuillToolbarBaseButton<
    QuillToolbarHistoryButtonOptions, QuillToolbarHistoryButtonExtraOptions>;

typedef QuillToolbarHistoryBaseButtonState<W extends QuillToolbarHistoryButton>
    = QuillToolbarCommonButtonState<W, QuillToolbarHistoryButtonOptions,
        QuillToolbarHistoryButtonExtraOptions>;

class QuillToolbarHistoryButton extends QuillToolbarHistoryBaseButton {
  const QuillToolbarHistoryButton({
    required super.controller,
    required this.isUndo,
    super.options = const QuillToolbarHistoryButtonOptions(),
    super.key,
  });

  /// If this true then it will be the undo button
  /// otherwise it will be redo
  final bool isUndo;

  @override
  QuillToolbarHistoryButtonState createState() =>
      QuillToolbarHistoryButtonState();
}

class QuillToolbarHistoryButtonState
    extends QuillToolbarHistoryBaseButtonState {
  var _canPressed = false;

  @override
  String get defaultTooltip =>
      widget.isUndo ? context.loc.undo : context.loc.redo;

  @override
  IconData get defaultIconData =>
      (widget.isUndo ? Icons.undo_outlined : Icons.redo_outlined);

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
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions?.childBuilder;

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
      // _updateCanPressed(); // We are already listening for the changes
      return;
    }

    if (controller.hasRedo) {
      controller.redo();
      // _updateCanPressed(); // We are already listening for the changes
    }
  }
}
