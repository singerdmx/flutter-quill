import 'package:flutter/material.dart';

import '../../../../extensions/quill_configurations_ext.dart';
import '../../../../l10n/extensions/localizations.dart';
import '../../../../l10n/widgets/localizations.dart';
import '../../../../models/themes/quill_dialog_theme.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../quill/quill_controller.dart';
import '../../base_toolbar.dart';

class QuillToolbarSearchButton extends StatelessWidget {
  const QuillToolbarSearchButton({
    required QuillController controller,
    this.options = const QuillToolbarSearchButtonOptions(),
    super.key,
  }) : _controller = controller;

  final QuillController _controller;
  final QuillToolbarSearchButtonOptions options;

  QuillController get controller {
    return _controller;
  }

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor =
        baseButtonExtraOptions(context).globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context).afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
  }

  QuillToolbarBaseButtonOptions baseButtonExtraOptions(BuildContext context) {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context).iconData ??
        Icons.search;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        (context.loc.search);
  }

  Color _dialogBarrierColor(BuildContext context) {
    return options.dialogBarrierColor ??
        context.quillSharedConfigurations?.dialogBarrierColor ??
        Colors.black54;
  }

  QuillDialogTheme? _dialogTheme(BuildContext context) {
    return options.dialogTheme ??
        context.quillSharedConfigurations?.dialogTheme;
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconData = _iconData(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final afterButtonPressed = _afterButtonPressed(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarSearchButtonOptions(
          afterButtonPressed: afterButtonPressed,
          dialogBarrierColor: _dialogBarrierColor(context),
          dialogTheme: _dialogTheme(context),
          fillColor: options.fillColor,
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          tooltip: tooltip,
          iconTheme: iconTheme,
        ),
        QuillToolbarSearchButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _sharedOnPressed(context);
            afterButtonPressed?.call();
          },
        ),
      );
    }

    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;

    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
        color: iconColor,
      ),
      isFilled: false,
      onPressed: () => _sharedOnPressed(context),
      afterPressed: afterButtonPressed,
    );
  }

  Future<void> _sharedOnPressed(BuildContext context) async {
    final customCallback = options.customOnPressedCallback;
    if (customCallback != null) {
      await customCallback(
        controller,
      );
      return;
    }
    await showDialog<String>(
      barrierColor: _dialogBarrierColor(context),
      context: context,
      builder: (_) => FlutterQuillLocalizationsWidget(
        child: QuillToolbarSearchDialog(
          controller: controller,
          dialogTheme: _dialogTheme(context),
          text: '',
        ),
      ),
    );
  }
}
