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
      // Show dialog to choose Photo or Video
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                contentPadding: const EdgeInsets.all(0),
                backgroundColor: Colors.transparent,
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextButton.icon(
                    icon: const Icon(Icons.photo, color: Colors.cyanAccent),
                    label: const Text('Photo'),
                    onPressed: () {
                      ImageVideoUtils.handleImageButtonTap(context, controller,
                          ImageSource.camera, onImagePickCallback,
                          filePickImpl: filePickImpl,
                          webImagePickImpl: webImagePickImpl);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.movie_creation,
                        color: Colors.orangeAccent),
                    label: const Text('Video'),
                    onPressed: () {
                      ImageVideoUtils.handleVideoButtonTap(context, controller,
                          ImageSource.camera, onVideoPickCallback,
                          filePickImpl: filePickImpl,
                          webVideoPickImpl: webVideoPickImpl);
                    },
                  )
                ]));
          });
    }

    if (onImagePickCallback != null) {
      return ImageVideoUtils.handleImageButtonTap(
          context, controller, ImageSource.camera, onImagePickCallback,
          filePickImpl: filePickImpl, webImagePickImpl: webImagePickImpl);
    }

    assert(onVideoPickCallback != null, 'onVideoPickCallback must not be null');
    return ImageVideoUtils.handleVideoButtonTap(
        context, controller, ImageSource.camera, onVideoPickCallback!,
        filePickImpl: filePickImpl, webVideoPickImpl: webVideoPickImpl);
  }
}
