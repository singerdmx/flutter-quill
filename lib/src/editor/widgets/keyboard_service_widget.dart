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
import '../raw_editor/config/events/character_shortcuts_events.dart';
import '../raw_editor/config/events/space_shortcut_events.dart';
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
    required this.characterEvents,
    required this.spaceEvents,
    this.customShortcuts,
    this.customActions,
    super.key,
  });

  final bool readOnly;
  final bool enableAlwaysIndentOnTab;
  final QuillController controller;
  final List<CharacterShortcutEvent> characterEvents;
  final List<SpaceShortcutEvent> spaceEvents;
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

    final isTab = event.logicalKey == LogicalKeyboardKey.tab;
    final isSpace = event.logicalKey == LogicalKeyboardKey.space;
    final containsSelection =
        controller.selection.baseOffset != controller.selection.extentOffset;
    if (!isTab && !isSpace && event.character != '\n' && !containsSelection) {
      for (final charEvents in characterEvents) {
        if (event.character != null &&
            event.character == charEvents.character) {
          final executed = charEvents.execute(controller);
          if (executed) {
            return KeyEventResult.handled;
          }
        }
      }
    }

    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    // Handle indenting blocks when pressing the tab key.
    if (isTab) {
      return _handleTabKey(event);
    }

    // Don't handle key if there is an active selection.
    if (containsSelection) {
      return KeyEventResult.ignored;
    }

    // Handle inserting lists when space is pressed following
    // a list initiating phrase.
    if (isSpace) {
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

    if (spaceEvents.isNotEmpty) {
      for (final spaceEvent in spaceEvents) {
        if (spaceEvent.character == text.value) {
          final executed = spaceEvent.execute(text, controller);
          if (executed) return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    } else if (spaceEvents.isEmpty) {
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
        final selection = controller.selection;
        controller.updateSelection(
          controller.selection.copyWith(
            baseOffset: selection.baseOffset + 1,
            extentOffset: selection.baseOffset + 1,
          ),
          ChangeSource.local,
        );
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
}
