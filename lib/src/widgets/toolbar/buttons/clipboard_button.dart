import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../../flutter_quill.dart';
import '../../../l10n/extensions/localizations.dart';
import '../base_button/base_value_button.dart';

enum ClipboardAction { cut, copy, paste }

class ClipboardMonitor {
  final ClipboardStatusNotifier _clipboardStatus = ClipboardStatusNotifier();

  Timer? _timer;

  void monitorClipboard(bool add, void Function() listener) {
    if (kIsWeb) return;
    if (add) {
      _clipboardStatus.addListener(listener);
      _timer = Timer.periodic(
          const Duration(seconds: 1), (timer) => _clipboardStatus.update());
    } else {
      _timer?.cancel();
      _clipboardStatus.removeListener(listener);
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
        return !controller.readOnly &&
            (kIsWeb ||
                widget._monitor._clipboardStatus.value ==
                    ClipboardStatus.pasteable);
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

  IconData get _icon => switch (widget.clipboardAction) {
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
            _icon,
            size: iconSize * iconButtonFactor,
          ),
          isSelected: false,
          onPressed: currentValue ? _onPressed : null,
          afterPressed: afterButtonPressed,
          iconTheme: iconTheme,
        ));
  }
}
