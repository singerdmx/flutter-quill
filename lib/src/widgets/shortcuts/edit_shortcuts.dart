/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-19 14:26:22
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-19 17:05:52
 * @FilePath: \flutter-quill\lib\src\widgets\shortcuts\edit_shortcuts.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../flutter_quill.dart';

typedef EditKeyboardAction = dynamic Function();

enum EditKeyboardKey {
  onEnter,
  onOverstriking,
  onRecover,
}

abstract class EditShortcuts extends Widget {
  const EditShortcuts({Key? key}) : super(key: key);

  Map<EditKeyboardKey, EditKeyboardAction> get shortcutHandlers;
}

class GridEditShortcuts extends StatelessWidget {
  final Widget child;
  final QuillController controller;

  LogicalKeyboardKey controlKey =
      Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

  GridEditShortcuts({
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // Ctrl + B
        LogicalKeySet(
          controlKey,
          LogicalKeyboardKey.keyB,
        ): const OverstrikingIntent(),
        // Ctrl + Z
        LogicalKeySet(
          controlKey,
          LogicalKeyboardKey.keyZ,
        ): const RecoverIntent(),
        // Ctrl + Alt + Z
        LogicalKeySet(
          controlKey,
          LogicalKeyboardKey.alt,
          LogicalKeyboardKey.keyZ,
        ): const UnRecoverIntent(),
      },
      child: Actions(
        actions: {
          OverstrikingIntent: OverstrikingAction(controller: controller),
          RecoverIntent: RecoverAction(controller: controller),
          UnRecoverIntent: UnRecoverAction(controller: controller),
        },
        child: child,
      ),
    );
  }
}

// 加粗
class OverstrikingIntent extends Intent {
  const OverstrikingIntent();
}

class OverstrikingAction extends Action<OverstrikingIntent> {
  OverstrikingAction({required this.controller});

  final QuillController controller;
  @override
  void invoke(covariant OverstrikingIntent intent) {
    if (controller.getSelectionStyle().attributes.keys.contains('bold')) {
      controller.formatSelection(Attribute.clone(Attribute.bold, null));
    } else {
      controller.formatSelection(Attribute.bold);
    }
  }
}

// 恢复
class RecoverIntent extends Intent {
  const RecoverIntent();
}

class RecoverAction extends Action<RecoverIntent> {
  RecoverAction({required this.controller});

  final QuillController controller;

  @override
  void invoke(covariant RecoverIntent intent) {
    if (controller.hasUndo) {
      controller.undo();
    }
  }
}

// 恢复反操作
class UnRecoverIntent extends Intent {
  const UnRecoverIntent();
}

class UnRecoverAction extends Action<UnRecoverIntent> {
  UnRecoverAction({required this.controller});

  final QuillController controller;

  @override
  void invoke(covariant UnRecoverIntent intent) {
    if (controller.hasRedo) {
      controller.redo();
    }
  }
}
