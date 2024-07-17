import 'package:flutter/material.dart';

import '../../../controller/quill_controller.dart';
import '../../../editor_toolbar_shared/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../../l10n/widgets/localizations.dart';
import '../../base_toolbar.dart';
import '../../simple_toolbar_provider.dart';
import '../../theme/quill_dialog_theme.dart';
import '../../theme/quill_icon_theme.dart';

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

  // TODO: Extract the common duplicated methods

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context)?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor = baseButtonExtraOptions(context)?.iconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context)?.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context)?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? baseButtonExtraOptions(BuildContext context) {
    return context.quillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context)?.iconData ??
        Icons.search;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context)?.tooltip ??
        (context.loc.search);
  }

  Color _dialogBarrierColor(BuildContext context) {
    return options.dialogBarrierColor ?? Colors.transparent;
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
        options.childBuilder ?? baseButtonExtraOptions(context)?.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
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

    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
      ),
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      afterPressed: afterButtonPressed,
      iconTheme: iconTheme,
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
          searchBarAlignment: options.searchBarAlignment,
        ),
      ),
    );
  }
}
