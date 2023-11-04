// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/config/toolbar/buttons/image.dart';
import '../embed_types.dart';
import 'utils/image_video_utils.dart';

class QuillToolbarImageButton extends StatelessWidget {
  const QuillToolbarImageButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;

  final QuillToolbarImageButtonOptions options;

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
        Icons.image;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Insert image';
    // ('Insert Image'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarImageButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          iconSize: iconSize,
          dialogTheme: options.dialogTheme,
          filePickImpl: options.filePickImpl,
          webImagePickImpl: options.webImagePickImpl,
          fillColor: options.fillColor,
          iconTheme: options.iconTheme,
          linkRegExp: options.linkRegExp,
          mediaPickSettingSelector: options.mediaPickSettingSelector,
          onImagePickCallback: options.onImagePickCallback,
          tooltip: options.tooltip,
        ),
        QuillToolbarImageButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconSize,
        color: iconColor,
      ),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final onImagePickCallbackRef = options.onImagePickCallback;
    if (onImagePickCallbackRef == null) {
      await _typeLink(context);
      return;
    }
    final selector = options.mediaPickSettingSelector ??
        ImageVideoUtils.selectMediaPickSetting;
    final source = await selector(context);
    if (source == null) {
      return;
    }
    switch (source) {
      case MediaPickSetting.gallery:
        _pickImage(context);
        break;
      case MediaPickSetting.link:
        await _typeLink(context);
        break;
      case MediaPickSetting.camera:
        await ImageVideoUtils.handleImageButtonTap(
          context,
          controller,
          ImageSource.camera,
          onImagePickCallbackRef,
          filePickImpl: options.filePickImpl,
          webImagePickImpl: options.webImagePickImpl,
        );
        break;
      case MediaPickSetting.video:
        throw ArgumentError(
          'Sorry but this is the Image button and not the video one',
        );
    }
  }

  void _pickImage(BuildContext context) => ImageVideoUtils.handleImageButtonTap(
        context,
        controller,
        ImageSource.gallery,
        options.onImagePickCallback ??
            (throw ArgumentError(
              'onImagePickCallback should not be null',
            )),
        filePickImpl: options.filePickImpl,
        webImagePickImpl: options.webImagePickImpl,
      );

  Future<void> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => LinkDialog(
        dialogTheme: options.dialogTheme,
        linkRegExp: options.linkRegExp,
      ),
    );
    _linkSubmitted(value);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;

      controller.replaceText(index, length, BlockEmbed.image(value), null);
    }
  }
}
