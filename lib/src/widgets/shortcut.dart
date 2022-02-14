import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/documents/attribute.dart';
import 'raw_editor.dart';

class QuillShortcuts extends Shortcuts {
  QuillShortcuts({required Widget child, Key? key})
      : super(
          key: key,
          shortcuts: _shortcuts,
          child: child,
        );

  static Map<ShortcutActivator, Intent> get _shortcuts {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _defaultShortcuts;
      case TargetPlatform.fuchsia:
        return _defaultShortcuts;
      case TargetPlatform.iOS:
        return _macShortcuts;
      case TargetPlatform.linux:
        return _defaultShortcuts;
      case TargetPlatform.macOS:
        return _macShortcuts;
      case TargetPlatform.windows:
        return _defaultShortcuts;
    }
  }

  static const Map<ShortcutActivator, Intent> _defaultShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.keyB, control: true):
        ToggleBoldStyleIntent(),
    SingleActivator(LogicalKeyboardKey.keyI, control: true):
        ToggleItalicStyleIntent(),
    SingleActivator(LogicalKeyboardKey.keyU, control: true):
        ToggleUnderlineStyleIntent(),
  };

  static final Map<ShortcutActivator, Intent> _macShortcuts =
      <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.keyB, meta: true):
        const ToggleBoldStyleIntent(),
    const SingleActivator(LogicalKeyboardKey.keyI, meta: true):
        const ToggleItalicStyleIntent(),
    const SingleActivator(LogicalKeyboardKey.keyU, meta: true):
        const ToggleUnderlineStyleIntent(),
  };
}

class ToggleBoldStyleIntent extends Intent {
  const ToggleBoldStyleIntent();
}

class ToggleItalicStyleIntent extends Intent {
  const ToggleItalicStyleIntent();
}

class ToggleUnderlineStyleIntent extends Intent {
  const ToggleUnderlineStyleIntent();
}

class QuillActions extends Actions {
  QuillActions({
    required Widget child,
    Key? key,
  }) : super(
          key: key,
          actions: _shortcutsActions,
          child: child,
        );

  static final Map<Type, Action<Intent>> _shortcutsActions =
      <Type, Action<Intent>>{
    ToggleBoldStyleIntent: _ToggleInlineStyleAction(Attribute.bold),
    ToggleItalicStyleIntent: _ToggleInlineStyleAction(Attribute.italic),
    ToggleUnderlineStyleIntent: _ToggleInlineStyleAction(Attribute.underline),
  };
}

class _ToggleInlineStyleAction extends ContextAction<Intent> {
  _ToggleInlineStyleAction(this.attribute);

  final Attribute attribute;

  @override
  Object? invoke(Intent intent, [BuildContext? context]) {
    final editorState = context!.findAncestorStateOfType<RawEditorState>()!;
    final style = editorState.controller.getSelectionStyle();
    final actualAttr = style.containsKey(attribute.key)
        ? Attribute.clone(attribute, null)
        : attribute;
    editorState.controller.formatSelection(actualAttr);
    return null;
  }
}
