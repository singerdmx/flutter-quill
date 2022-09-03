import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'embed_types.dart';
import 'toolbar/camera_button.dart';
import 'toolbar/formula_button.dart';
import 'toolbar/image_button.dart';
import 'toolbar/video_button.dart';

export 'toolbar/image_button.dart';
export 'toolbar/image_video_utils.dart';
export 'toolbar/video_button.dart';
export 'toolbar/formula_button.dart';
export 'toolbar/camera_button.dart';

class QuillEmbedToolbar implements EmbedToolbar {
  QuillEmbedToolbar({
    this.showImageButton = true,
    this.showVideoButton = true,
    this.showCameraButton = true,
    this.showFormulaButton = false,
    this.onImagePickCallback,
    this.onVideoPickCallback,
    this.mediaPickSettingSelector,
    this.cameraPickSettingSelector,
    this.filePickImpl,
    this.webImagePickImpl,
    this.webVideoPickImpl,
  });

  final bool showImageButton;
  final bool showVideoButton;
  final bool showCameraButton;
  final bool showFormulaButton;

  final OnImagePickCallback? onImagePickCallback;
  final OnVideoPickCallback? onVideoPickCallback;
  final MediaPickSettingSelector? mediaPickSettingSelector;
  final MediaPickSettingSelector? cameraPickSettingSelector;
  final FilePickImpl? filePickImpl;
  final WebImagePickImpl? webImagePickImpl;
  final WebVideoPickImpl? webVideoPickImpl;

  @override
  bool get notEmpty =>
      showImageButton ||
      showVideoButton ||
      (showCameraButton &&
          (onImagePickCallback != null || onVideoPickCallback != null)) ||
      showFormulaButton;

  @override
  Iterable<Widget> build(QuillController controller, double toolbarIconSize,
      QuillIconTheme? iconTheme, QuillDialogTheme? dialogTheme) {
    return [
      if (showImageButton)
        ImageButton(
          icon: Icons.image,
          iconSize: toolbarIconSize,
          controller: controller,
          onImagePickCallback: onImagePickCallback,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl,
          mediaPickSettingSelector: mediaPickSettingSelector,
          iconTheme: iconTheme,
          dialogTheme: dialogTheme,
        ),
      if (showVideoButton)
        VideoButton(
          icon: Icons.movie_creation,
          iconSize: toolbarIconSize,
          controller: controller,
          onVideoPickCallback: onVideoPickCallback,
          filePickImpl: filePickImpl,
          webVideoPickImpl: webImagePickImpl,
          mediaPickSettingSelector: mediaPickSettingSelector,
          iconTheme: iconTheme,
          dialogTheme: dialogTheme,
        ),
      if ((onImagePickCallback != null || onVideoPickCallback != null) &&
          showCameraButton)
        CameraButton(
          icon: Icons.photo_camera,
          iconSize: toolbarIconSize,
          controller: controller,
          onImagePickCallback: onImagePickCallback,
          onVideoPickCallback: onVideoPickCallback,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl,
          webVideoPickImpl: webVideoPickImpl,
          cameraPickSettingSelector: cameraPickSettingSelector,
          iconTheme: iconTheme,
        ),
      if (showFormulaButton)
        FormulaButton(
          icon: Icons.functions,
          iconSize: toolbarIconSize,
          controller: controller,
          onImagePickCallback: onImagePickCallback,
          filePickImpl: filePickImpl,
          webImagePickImpl: webImagePickImpl,
          mediaPickSettingSelector: mediaPickSettingSelector,
          iconTheme: iconTheme,
          dialogTheme: dialogTheme,
        )
    ];
  }
}
