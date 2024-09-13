import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils/cast.dart';
import '../../common/utils/platform.dart';
import '../../controller/quill_controller.dart';
import '../../document/attribute.dart';
import '../../document/document.dart';
import '../../document/nodes/block.dart';
import '../../document/nodes/leaf.dart' as leaf;
import '../../document/nodes/line.dart';
import 'default_single_activator_actions.dart';
import 'keyboard_listener.dart';

class QuillKeyboardServiceWidget extends StatelessWidget {
  const QuillKeyboardServiceWidget({
    required this.actions,
    required this.constraints,
    required this.focusNode,
    required this.child,
    required this.controller,
    required this.readOnly,
    required this.enableAlwaysIndentOnTab,
    required this.enableMdConversion,
    this.customShortcuts,
    this.customActions,
    super.key,
  });

  final bool readOnly;
  final bool enableAlwaysIndentOnTab;
  final bool enableMdConversion;
  final QuillController controller;
  final Map<ShortcutActivator, Intent>? customShortcuts;
  final Map<Type, Action<Intent>>? customActions;
  final Map<Type, Action<Intent>> actions;
  final BoxConstraints constraints;
  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDesktopMacOS = isMacOS;
    return Shortcuts(
      /// Merge with widget.configurations.customShortcuts
      /// first to allow user's defined shortcuts to take
      /// priority when activation triggers are the same
      shortcuts: mergeMaps<ShortcutActivator, Intent>({...?customShortcuts},
          {...defaultSinlgeActivatorActions(isDesktopMacOS)}),
      child: Actions(
        actions: mergeMaps<Type, Action<Intent>>(actions, {
          ...?customActions,
        }),
        child: Focus(
          focusNode: focusNode,
          onKeyEvent: _onKeyEvent,
          child: QuillKeyboardListener(
            child: Container(
              constraints: constraints,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(node, KeyEvent event) {
    // Don't handle key if there is a meta key pressed.
    if (HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    // Handle indenting blocks when pressing the tab key.
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      return _handleTabKey(event);
    }

    // Don't handle key if there is an active selection.
    if (controller.selection.baseOffset != controller.selection.extentOffset) {
      return KeyEventResult.ignored;
    }

    // Handle inserting lists when space is pressed following
    // a list initiating phrase.
    if (event.logicalKey == LogicalKeyboardKey.space) {
      return _handleSpaceKey(event);
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSpaceKey(KeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);
    if (child.node == null) {
      return KeyEventResult.ignored;
    }

    final line = child.node as Line?;
    if (line == null) {
      return KeyEventResult.ignored;
    }

    final text = castOrNull<leaf.QuillText>(line.first);
    if (text == null) {
      return KeyEventResult.ignored;
    }

    const olKeyPhrase = '1.';
    const ulKeyPhrase = '-';

    if (text.value == olKeyPhrase && enableMdConversion) {
      _updateSelectionForKeyPhrase(olKeyPhrase, Attribute.ol);
    } else if (text.value == ulKeyPhrase && enableMdConversion) {
      _updateSelectionForKeyPhrase(ulKeyPhrase, Attribute.ul);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _handleTabKey(KeyEvent event) {
    final child =
        controller.document.queryChild(controller.selection.baseOffset);

    KeyEventResult insertTabCharacter() {
      if (readOnly) {
        return KeyEventResult.ignored;
      }
      if (enableAlwaysIndentOnTab) {
        controller.indentSelection(!HardwareKeyboard.instance.isShiftPressed);
      } else {
        controller.replaceText(controller.selection.baseOffset, 0, '\t', null);
        _moveCursor(1);
      }
      return KeyEventResult.handled;
    }

    if (controller.selection.baseOffset != controller.selection.extentOffset) {
      if (child.node == null || child.node!.parent == null) {
        return KeyEventResult.handled;
      }
      final parentBlock = child.node!.parent!;
      if (parentBlock.style.containsKey(Attribute.ol.key) ||
          parentBlock.style.containsKey(Attribute.ul.key) ||
          parentBlock.style.containsKey(Attribute.checked.key)) {
        controller.indentSelection(!HardwareKeyboard.instance.isShiftPressed);
      }
      return KeyEventResult.handled;
    }

    if (child.node == null) {
      return insertTabCharacter();
    }

    final node = child.node!;

    final parent = node.parent;
    if (parent == null || parent is! Block) {
      return insertTabCharacter();
    }

    if (node is! Line || (node.isNotEmpty && node.first is! leaf.QuillText)) {
      return insertTabCharacter();
    }

    final parentBlock = parent;
    if (parentBlock.style.containsKey(Attribute.ol.key) ||
        parentBlock.style.containsKey(Attribute.ul.key) ||
        parentBlock.style.containsKey(Attribute.checked.key)) {
      if (node.isNotEmpty &&
          (node.first as leaf.QuillText).value.isNotEmpty &&
          controller.selection.base.offset > node.documentOffset) {
        return insertTabCharacter();
      }
      controller.indentSelection(!HardwareKeyboard.instance.isShiftPressed);
      return KeyEventResult.handled;
    }

    if (node.isNotEmpty && (node.first as leaf.QuillText).value.isNotEmpty) {
      return insertTabCharacter();
    }

    return insertTabCharacter();
  }

  void _moveCursor(int chars) {
    final selection = controller.selection;
    controller.updateSelection(
        controller.selection.copyWith(
            baseOffset: selection.baseOffset + chars,
            extentOffset: selection.baseOffset + chars),
        ChangeSource.local);
  }

  void _updateSelectionForKeyPhrase(String phrase, Attribute attribute) {
    controller.replaceText(controller.selection.baseOffset - phrase.length,
        phrase.length, '\n', null);
    _moveCursor(-phrase.length);
    controller
      ..formatSelection(attribute)
      // Remove the added newline.
      ..replaceText(controller.selection.baseOffset + 1, 1, '', null);
    //
    final style =
        controller.document.collectStyle(controller.selection.baseOffset, 0);
    if (style.isNotEmpty) {
      for (final attr in style.values) {
        controller.formatSelection(attr);
      }
      controller.formatSelection(attribute);
    }
  }
}
