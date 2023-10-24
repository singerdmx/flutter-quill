import 'package:flutter/material.dart';

import '../../../../../translations.dart';
import '../../../../models/themes/quill_dialog_theme.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../../utils/extensions/build_context.dart';
import '../../../controller.dart';
import '../../base_toolbar.dart';

class QuillToolbarSearchButton extends StatelessWidget {
  const QuillToolbarSearchButton({
    required QuillController controller,
    required this.options,
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
        ('Search'.i18n);
  }

  Color _dialogBarrierColor(BuildContext context) {
    return options.dialogBarrierColor ??
        context.requireQuillSharedConfigurations.dialogBarrierColor;
  }

  QuillDialogTheme? _dialogTheme(BuildContext context) {
    return options.dialogTheme ??
        context.requireQuillSharedConfigurations.dialogTheme;
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconData = _iconData(context);
    final iconSize = _iconSize(context);
    final afterButtonPressed = _afterButtonPressed(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarSearchButtonOptions(
          afterButtonPressed: afterButtonPressed,
          controller: controller,
          dialogBarrierColor: _dialogBarrierColor(context),
          dialogTheme: _dialogTheme(context),
          fillColor: options.fillColor,
          iconData: _iconData(context),
          iconSize: _iconSize(context),
          tooltip: _tooltip(context),
          iconTheme: _iconTheme(context),
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
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize,
        color: iconColor,
      ),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
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
      builder: (_) => QuillToolbarSearchDialog(
        controller: controller,
        dialogTheme: _dialogTheme(context),
        text: '',
      ),
    );
  }

  // Those functions ((findText, moveToPosition)) are not ready yet.
  // but consider moving them to a better place
  // List<int> _findText({
  //   required int index,
  //   required String text,
  //   required QuillController controller,
  //   required List<int> offsets,
  //   required bool wholeWord,
  //   required bool caseSensitive,
  //   bool moveToPosition = true,
  // }) {
  //   if (text.isEmpty) {
  //     return List.empty();
  //   }
  //   final newOffsets = controller.document.search(
  //     text,
  //     caseSensitive: caseSensitive,
  //     wholeWord: wholeWord,
  //   );
  //   index = 0; // TODO: This might need to be updated...
  //   if (offsets.isNotEmpty && moveToPosition) {
  //     _moveToPosition(
  //       index: index,
  //       text: text,
  //       controller: controller,
  //       offsets: offsets,
  //     );
  //   }
  //   return newOffsets;
  // }

  // void _moveToPosition({
  //   required int index,
  //   required String text,
  //   required QuillController controller,
  //   required List<int> offsets,
  // }) {
  //   controller.updateSelection(
  //     TextSelection(
  //       baseOffset: offsets[index],
  //       extentOffset: offsets[index] + text.length,
  //     ),
  //     ChangeSource.LOCAL,
  //   );
  // }
}
