library flutter_quill_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'embeds/builders.dart';
import 'embeds/embed_types.dart';
import 'embeds/toolbar/camera_button.dart';
import 'embeds/toolbar/formula_button.dart';
import 'embeds/toolbar/image_button.dart';
import 'embeds/toolbar/video_button.dart';

export 'embeds/embed_types.dart';
export 'embeds/toolbar/camera_button.dart';
export 'embeds/toolbar/formula_button.dart';
export 'embeds/toolbar/image_button.dart';
export 'embeds/toolbar/image_video_utils.dart';
export 'embeds/toolbar/media_button.dart';
export 'embeds/toolbar/video_button.dart';
export 'embeds/utils.dart';

class FlutterQuillEmbeds {
  static List<EmbedBuilder> builders({
    void Function(GlobalKey videoContainerKey)? onVideoInit,
  }) =>
      [
        ImageEmbedBuilder(),
        VideoEmbedBuilder(onVideoInit: onVideoInit),
        FormulaEmbedBuilder(),
      ];

  static List<EmbedBuilder> webBuilders() => [
        ImageEmbedBuilderWeb(),
      ];

  static List<EmbedButtonBuilder> buttons({
    bool showImageButton = true,
    bool showVideoButton = true,
    bool showCameraButton = true,
    bool showFormulaButton = false,
    String? imageButtonTooltip,
    String? videoButtonTooltip,
    String? cameraButtonTooltip,
    String? formulaButtonTooltip,
    OnImagePickCallback? onImagePickCallback,
    OnVideoPickCallback? onVideoPickCallback,
    MediaPickSettingSelector? mediaPickSettingSelector,
    MediaPickSettingSelector? cameraPickSettingSelector,
    FilePickImpl? filePickImpl,
    WebImagePickImpl? webImagePickImpl,
    WebVideoPickImpl? webVideoPickImpl,
    RegExp? imageLinkRegExp,
    RegExp? videoLinkRegExp,
  }) =>
      [
        if (showImageButton)
          (controller, toolbarIconSize, iconTheme, dialogTheme) => ImageButton(
                icon: Icons.image,
                iconSize: toolbarIconSize,
                tooltip: imageButtonTooltip,
                controller: controller,
                onImagePickCallback: onImagePickCallback,
                filePickImpl: filePickImpl,
                webImagePickImpl: webImagePickImpl,
                mediaPickSettingSelector: mediaPickSettingSelector,
                iconTheme: iconTheme,
                dialogTheme: dialogTheme,
                linkRegExp: imageLinkRegExp,
              ),
        if (showVideoButton)
          (controller, toolbarIconSize, iconTheme, dialogTheme) => VideoButton(
                icon: Icons.movie_creation,
                iconSize: toolbarIconSize,
                tooltip: videoButtonTooltip,
                controller: controller,
                onVideoPickCallback: onVideoPickCallback,
                filePickImpl: filePickImpl,
                webVideoPickImpl: webImagePickImpl,
                mediaPickSettingSelector: mediaPickSettingSelector,
                iconTheme: iconTheme,
                dialogTheme: dialogTheme,
                linkRegExp: videoLinkRegExp,
          ),
        if ((onImagePickCallback != null || onVideoPickCallback != null) &&
            showCameraButton)
          (controller, toolbarIconSize, iconTheme, dialogTheme) => CameraButton(
                icon: Icons.photo_camera,
                iconSize: toolbarIconSize,
                tooltip: cameraButtonTooltip,
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
          (controller, toolbarIconSize, iconTheme, dialogTheme) =>
              FormulaButton(
                icon: Icons.functions,
                iconSize: toolbarIconSize,
                tooltip: formulaButtonTooltip,
                controller: controller,
                iconTheme: iconTheme,
                dialogTheme: dialogTheme,
              )
      ];
}
