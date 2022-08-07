import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../toolbar.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.onImagePickCallback,
    this.onVideoPickCallback,
    this.filePickImpl,
    this.webImagePickImpl,
    this.webVideoPickImpl,
    this.cameraPickSettingSelector,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnImagePickCallback? onImagePickCallback;

  final OnVideoPickCallback? onVideoPickCallback;

  final WebImagePickImpl? webImagePickImpl;

  final WebVideoPickImpl? webVideoPickImpl;

  final FilePickImpl? filePickImpl;

  final CameraPickSettingSelector? cameraPickSettingSelector;

  final QuillIconTheme? iconTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context, controller,
          onImagePickCallback: onImagePickCallback,
          onVideoPickCallback: onVideoPickCallback,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl),
    );
  }

  Future<void> _onPressedHandler(
      BuildContext context, QuillController controller,
      {OnImagePickCallback? onImagePickCallback,
      OnVideoPickCallback? onVideoPickCallback,
      FilePickImpl? filePickImpl,
      WebImagePickImpl? webImagePickImpl}) async {
    if (onImagePickCallback != null && onVideoPickCallback != null) {

      final selector =
          cameraPickSettingSelector ?? CameraVideoUtils.selectMediaPickSetting;

      final source = await selector(context);
      if (source != null) {
        switch (source) {
          case CameraPickSetting.Camera:
            CameraVideoUtils.handleCameraButtonTap(context, controller,
                ImageSource.camera, onImagePickCallback,
                filePickImpl: filePickImpl,
                webImagePickImpl: webImagePickImpl);
            break;
          case CameraPickSetting.Video:
            CameraVideoUtils.handleVideoButtonTap(context, controller,
                ImageSource.camera, onVideoPickCallback,
                filePickImpl: filePickImpl,
                webVideoPickImpl: webVideoPickImpl);
            break;
          default:
            throw ArgumentError('Invalid MediaSetting');
        }
      }
    }
  }
}