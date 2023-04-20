import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/translations.dart';
import 'package:image_picker/image_picker.dart';

import '../embed_types.dart';
import 'image_video_utils.dart';

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
    this.tooltip,
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

  final MediaPickSettingSelector? cameraPickSettingSelector;

  final QuillIconTheme? iconTheme;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _handleCameraButtonTap(context, controller,
          onImagePickCallback: onImagePickCallback,
          onVideoPickCallback: onVideoPickCallback,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl),
    );
  }

  Future<void> _handleCameraButtonTap(
      BuildContext context, QuillController controller,
      {OnImagePickCallback? onImagePickCallback,
      OnVideoPickCallback? onVideoPickCallback,
      FilePickImpl? filePickImpl,
      WebImagePickImpl? webImagePickImpl}) async {
    if (onImagePickCallback != null && onVideoPickCallback != null) {
      final selector = cameraPickSettingSelector ??
          (context) => showDialog<MediaPickSetting>(
                context: context,
                builder: (ctx) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.camera,
                          color: Colors.orangeAccent,
                        ),
                        label: Text('Camera'.i18n),
                        onPressed: () =>
                            Navigator.pop(ctx, MediaPickSetting.Camera),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.video_call,
                          color: Colors.cyanAccent,
                        ),
                        label: Text('Video'.i18n),
                        onPressed: () =>
                            Navigator.pop(ctx, MediaPickSetting.Video),
                      )
                    ],
                  ),
                ),
              );

      final source = await selector(context);
      if (source != null) {
        switch (source) {
          case MediaPickSetting.Camera:
            await ImageVideoUtils.handleImageButtonTap(
                context, controller, ImageSource.camera, onImagePickCallback,
                filePickImpl: filePickImpl, webImagePickImpl: webImagePickImpl);
            break;
          case MediaPickSetting.Video:
            await ImageVideoUtils.handleVideoButtonTap(
                context, controller, ImageSource.camera, onVideoPickCallback,
                filePickImpl: filePickImpl, webVideoPickImpl: webVideoPickImpl);
            break;
          default:
            throw ArgumentError('Invalid MediaSetting');
        }
      }
    }
  }
}
