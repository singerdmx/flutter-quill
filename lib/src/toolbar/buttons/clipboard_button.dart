import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../extensions.dart';
import '../../../flutter_quill.dart';
import '../../editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';

enum ClipboardAction { cut, copy, paste }

class ClipboardMonitor {
  bool _canPaste = false;
  bool get canPaste => _canPaste;
  Timer? _timer;

  void monitorClipboard(bool add, void Function() listener) {
    if (kIsWeb) return;
    if (add) {
      _timer = Timer.periodic(
          const Duration(seconds: 1), (timer) => _update(listener));
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _update(void Function() listener) async {
    final clipboardService = ClipboardServiceProvider.instance;
    if (await clipboardService.canPaste()) {
      _canPaste = true;
      listener();
    }
  }
}

class QuillToolbarClipboardButton extends QuillToolbarToggleStyleBaseButton {
  QuillToolbarClipboardButton(
      {required super.controller,
      required this.clipboardAction,
      super.options = const QuillToolbarToggleStyleButtonOptions(),
      super.key});

  final ClipboardAction clipboardAction;

  final ClipboardMonitor _monitor = ClipboardMonitor();

  @override
  State<StatefulWidget> createState() => QuillToolbarClipboardButtonState();
}

class QuillToolbarClipboardButtonState
    extends QuillToolbarToggleStyleBaseButtonState<
        QuillToolbarClipboardButton> {
  @override
  bool get currentStateValue {
    switch (widget.clipboardAction) {
      case ClipboardAction.cut:
        return !controller.readOnly && !controller.selection.isCollapsed;
      case ClipboardAction.copy:
        return !controller.selection.isCollapsed;
      case ClipboardAction.paste:
        return !controller.readOnly && (kIsWeb || widget._monitor.canPaste);
    }
  }

  void _listenClipboardStatus() => didChangeEditingValue();

  @override
  void addExtraListener() {
    if (widget.clipboardAction == ClipboardAction.paste) {
      widget._monitor.monitorClipboard(true, _listenClipboardStatus);
    }
  }

  @override
  void removeExtraListener(covariant QuillToolbarClipboardButton oldWidget) {
    if (widget.clipboardAction == ClipboardAction.paste) {
      oldWidget._monitor.monitorClipboard(false, _listenClipboardStatus);
    }
  }

  @override
  String get defaultTooltip => switch (widget.clipboardAction) {
        ClipboardAction.cut => context.loc.cut,
        ClipboardAction.copy => context.loc.copy,
        ClipboardAction.paste => context.loc.paste,
      };

  @override
  IconData get defaultIconData => switch (widget.clipboardAction) {
        ClipboardAction.cut => Icons.cut_outlined,
        ClipboardAction.copy => Icons.copy_outlined,
        ClipboardAction.paste => Icons.paste_outlined,
      };

  void _onPressed() {
    switch (widget.clipboardAction) {
      case ClipboardAction.cut:
        controller.clipboardSelection(false);
        break;
      case ClipboardAction.copy:
        controller.clipboardSelection(true);
        break;
      case ClipboardAction.paste:
        controller.clipboardPaste();
        break;
    }
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = options.childBuilder ??
        context.quillToolbarBaseButtonOptions?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarToggleStyleButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: _onPressed,
          isToggled: currentValue,
        ),
      );
    }

    return UtilityWidgets.maybeTooltip(
        message: tooltip,
        child: QuillToolbarIconButton(
          icon: Icon(
            iconData,
            size: iconSize * iconButtonFactor,
          ),
          isSelected: false,
          onPressed: currentValue ? _onPressed : null,
          afterPressed: afterButtonPressed,
          iconTheme: iconTheme,
        ));
  }
}
