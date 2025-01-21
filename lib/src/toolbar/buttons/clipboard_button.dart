@experimental
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../common/utils/widgets.dart';
import '../../editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';
import '../simple_toolbar.dart';

@experimental
enum ClipboardAction { cut, copy, paste }

@experimental
class ClipboardMonitor {
  bool _canPaste = false;
  bool get canPaste => _canPaste;
  Timer? _timer;

  bool _isCheckingClipboard = false;

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
    if (_isCheckingClipboard) {
      return;
    }

    _isCheckingClipboard = true;

    final clipboardService = ClipboardServiceProvider.instance;

    if (await clipboardService.hasClipboardContent) {
      _canPaste = true;

      listener();
    }

    _isCheckingClipboard = false;
  }
}

@experimental
class QuillToolbarClipboardButton extends QuillToolbarToggleStyleBaseButton {
  const QuillToolbarClipboardButton({
    required super.controller,
    required this.clipboardAction,
    QuillToolbarClipboardButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : _options = options,
        super(options: options ?? const QuillToolbarClipboardButtonOptions());

  final QuillToolbarClipboardButtonOptions? _options;

  final ClipboardAction clipboardAction;

  @override
  State<StatefulWidget> createState() => QuillToolbarClipboardButtonState();
}

class QuillToolbarClipboardButtonState
    extends QuillToolbarToggleStyleBaseButtonState<
        QuillToolbarClipboardButton> {
  final ClipboardMonitor _monitor = ClipboardMonitor();

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
                (widget._options?.enableClipboardPaste ?? _monitor.canPaste));
    }
  }

  void _listenClipboardStatus() => didChangeEditingValue();

  @override
  void didUpdateWidget(QuillToolbarClipboardButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Default didUpdateWidget handler, otherwise simple flag change didn't stop the monitor.
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(didChangeEditingValue);
      removeExtraListener(oldWidget);
      controller.addListener(didChangeEditingValue);
      addExtraListener();
      currentValue = currentStateValue;
    }
    // The controller didn't change, but enableClipboardPaste did.
    else if (widget.clipboardAction == ClipboardAction.paste) {
      final isTimerActive = _monitor._timer?.isActive ?? false;

      // Enable clipboard monitoring if not active and should be monitored.
      if (_shouldUseClipboardMonitor && !isTimerActive) {
        _monitor.monitorClipboard(true, _listenClipboardStatus);
      }
      // Disable clipboard monitoring if active and should not be monitored.
      else if (!_shouldUseClipboardMonitor && isTimerActive) {
        _monitor.monitorClipboard(false, _listenClipboardStatus);
      }

      currentValue = currentStateValue;
    }
  }

  @override
  void addExtraListener() {
    if (_shouldUseClipboardMonitor) {
      _monitor.monitorClipboard(true, _listenClipboardStatus);
    }
  }

  @override
  void removeExtraListener(covariant QuillToolbarClipboardButton oldWidget) {
    if (_shouldUseClipboardMonitor) {
      _monitor.monitorClipboard(false, _listenClipboardStatus);
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

  bool get _shouldUseClipboardMonitor {
    return widget.clipboardAction == ClipboardAction.paste &&
        (widget._options?.enableClipboardPaste == null);
  }

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
    final childBuilder = this.childBuilder;
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
