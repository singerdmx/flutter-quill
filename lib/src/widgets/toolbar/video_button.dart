import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controller.dart';
import '../toolbar.dart';
import 'image_video_utils.dart';
import 'quill_icon_button.dart';

class VideoButton extends StatelessWidget {
  const VideoButton({
    required this.icon,
    required this.controller,
    required this.onVideoPickCallback,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.filePickImpl,
    this.webVideoPickImpl,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final OnVideoPickCallback onVideoPickCallback;

  final WebVideoPickImpl? webVideoPickImpl;

  final FilePickImpl? filePickImpl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: theme.iconTheme.color),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: () => ImageVideoUtils.handleVideoButtonTap(
          context, controller, ImageSource.gallery, onVideoPickCallback,
          filePickImpl: filePickImpl, webVideoPickImpl: webVideoPickImpl),
    );
  }
}
