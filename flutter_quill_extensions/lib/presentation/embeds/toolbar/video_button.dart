// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/config/toolbar/buttons/video.dart';
import '../embed_types.dart';
import 'utils/image_video_utils.dart';

class QuillToolbarVideoButton extends StatelessWidget {
  const QuillToolbarVideoButton({
    required this.options,
    required this.controller,
    super.key,
  });

  final QuillController controller;

  final QuillToolbarVideoButtonOptions options;

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
        Icons.movie_creation;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Insert video';
    // ('Insert video'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarVideoButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          dialogTheme: options.dialogTheme,
          filePickImpl: options.filePickImpl,
          fillColor: iconFillColor,
          iconSize: options.iconSize,
          linkRegExp: options.linkRegExp,
          tooltip: options.tooltip,
          mediaPickSettingSelector: options.mediaPickSettingSelector,
          iconTheme: options.iconTheme,
          onVideoPickCallback: options.onVideoPickCallback,
          webVideoPickImpl: options.webVideoPickImpl,
        ),
        QuillToolbarVideoButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(iconData, size: iconSize, color: iconColor),
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
    if (options.onVideoPickCallback != null) {
      final selector = options.mediaPickSettingSelector ??
          ImageVideoUtils.selectMediaPickSetting;
      final source = await selector(context);
      if (source != null) {
        if (source == MediaPickSetting.gallery) {
          _pickVideo(context);
        } else {
          await _typeLink(context);
        }
      }
    } else {
      await _typeLink(context);
    }
  }

  void _pickVideo(BuildContext context) => ImageVideoUtils.handleVideoButtonTap(
        context,
        controller,
        ImageSource.gallery,
        options.onVideoPickCallback!,
        filePickImpl: options.filePickImpl,
        webVideoPickImpl: options.webVideoPickImpl,
      );

  Future<void> _typeLink(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => LinkDialog(
        dialogTheme: options.dialogTheme,
      ),
    );
    _linkSubmitted(value);
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty) {
      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;

      controller.replaceText(index, length, BlockEmbed.video(value), null);
    }
  }
}
