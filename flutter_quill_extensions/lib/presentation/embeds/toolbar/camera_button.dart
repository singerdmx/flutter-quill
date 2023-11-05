// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/config/toolbar/buttons/camera.dart';

class QuillToolbarCameraButton extends StatelessWidget {
  const QuillToolbarCameraButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCameraButtonOptions options;

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
        Icons.photo_camera;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Camera'.i18n;
    // ('Camera'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(
      context,
      controller,
    );
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    if (childBuilder != null) {
      childBuilder(
        QuillToolbarCameraButtonOptions(
          onImagePickCallback: options.onImagePickCallback,
          onVideoPickCallback: options.onVideoPickCallback,
          afterButtonPressed: _afterButtonPressed(context),
          cameraPickSettingSelector: options.cameraPickSettingSelector,
          filePickImpl: options.filePickImpl,
          iconData: options.iconData,
          fillColor: options.fillColor,
          iconSize: options.iconSize,
          iconTheme: options.iconTheme,
          tooltip: options.tooltip,
          webImagePickImpl: options.webImagePickImpl,
          webVideoPickImpl: options.webVideoPickImpl,
        ),
        QuillToolbarCameraButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

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

  Future<void> _onPressedHandler(
    BuildContext context,
    QuillController controller,
  ) async {
    if (onVideoPickCallback == null && onImagePickCallback == null) {
      throw ArgumentError(
        'onImagePickCallback and onVideoPickCallback are both null',
      );
    }
    final selector = options.cameraPickSettingSelector ??
        (context) => showDialog<MediaPickSetting>(
              context: context,
              builder: (ctx) => AlertDialog(
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onImagePickCallback != null)
                      TextButton.icon(
                        icon: const Icon(
                          Icons.camera,
                          color: Colors.orangeAccent,
                        ),
                        label: Text('Camera'.i18n),
                        onPressed: () =>
                            Navigator.pop(ctx, MediaPickSetting.camera),
                      ),
                    if (onVideoPickCallback != null)
                      TextButton.icon(
                        icon: const Icon(
                          Icons.video_call,
                          color: Colors.cyanAccent,
                        ),
                        label: Text('Video'.i18n),
                        onPressed: () =>
                            Navigator.pop(ctx, MediaPickSetting.video),
                      )
                  ],
                ),
              ),
            );

    final source = await selector(context);
    if (source == null) {
      return;
    }
    switch (source) {
      case MediaPickSetting.camera:
        await ImageVideoUtils.handleImageButtonTap(
          context,
          controller,
          ImageSource.camera,
          onImagePickCallback!,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl,
        );
        break;
      case MediaPickSetting.video:
        await ImageVideoUtils.handleVideoButtonTap(
          context,
          controller,
          ImageSource.camera,
          onVideoPickCallback!,
          filePickImpl: filePickImpl,
          webVideoPickImpl: options.webVideoPickImpl,
        );
        break;
      case MediaPickSetting.gallery:
        throw ArgumentError(
          'Invalid MediaSetting for the camera button.\n'
          'gallery is not related to camera button',
        );
      case MediaPickSetting.link:
        throw ArgumentError(
          'Invalid MediaSetting for the camera button.\n'
          'link is not related to camera button',
        );
    }
  }
}
