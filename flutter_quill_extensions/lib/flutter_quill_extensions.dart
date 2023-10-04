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
  /// Returns a list of embed builders for QuillEditor.
  ///
  /// **Note:** This method is not intended for web usage.
  /// For web-specific embeds, use [webBuilders].
  ///
  /// [onVideoInit] is called when a video is initialized.
  ///
  /// [onImageRemovedCallback] is called when an image
  ///  is removed from the editor. This can be used to
  /// delete the image from storage, for example:
  ///
  /// ```dart
  /// (imageFile) async {
  ///   final fileExists = await imageFile.exists();
  ///   if (fileExists) {
  ///     await imageFile.delete();
  ///   }
  /// },
  /// ```
  ///
  /// [shouldRemoveImageCallback] is called when the user
  /// attempts to remove an image
  /// from the editor. It allows you to control whether the image
  /// should be removed
  /// based on your custom logic.
  ///
  /// Example of [shouldRemoveImageCallback] customization:
  /// ```dart
  /// shouldRemoveImageFromEditor: (imageFile) async {
  ///   // Show a confirmation dialog before removing the image
  ///   final isShouldRemove = await showYesCancelDialog(
  ///     context: context,
  ///     options: const YesOrCancelDialogOptions(
  ///       title: 'Deleting an image',
  ///       message: 'Are you sure you want to delete this image
  ///       from the editor?',
  ///     ),
  ///   );
  ///
  ///   // Return `true` to allow image removal if the user confirms, otherwise `false`
  ///   return isShouldRemove;
  /// }
  /// ```
  static List<EmbedBuilder> builders({
    void Function(GlobalKey videoContainerKey)? onVideoInit,
    ImageEmbedBuilderOnRemovedCallback? onImageRemovedCallback,
    ImageEmbedBuilderWillRemoveCallback? shouldRemoveImageCallback,
  }) =>
      [
        ImageEmbedBuilder(
          onImageRemovedCallback: onImageRemovedCallback,
          shouldRemoveImageCallback: shouldRemoveImageCallback,
        ),
        VideoEmbedBuilder(onVideoInit: onVideoInit),
        FormulaEmbedBuilder(),
      ];

  /// Returns a list of embed builders specifically designed for web support.
  ///
  /// [ImageEmbedBuilderWeb] is the embed builder for handling
  ///  images on the web.
  ///
  static List<EmbedBuilder> webBuilders() => [
        ImageEmbedBuilderWeb(),
      ];

  /// Returns a list of embed button builders to customize the toolbar buttons.
  ///
  /// [showImageButton] determines whether the image button should be displayed.
  /// [showVideoButton] determines whether the video button should be displayed.
  /// [showCameraButton] determines whether the camera button should
  ///  be displayed.
  /// [showFormulaButton] determines whether the formula button
  ///  should be displayed.
  ///
  /// [imageButtonTooltip] specifies the tooltip text for the image button.
  /// [videoButtonTooltip] specifies the tooltip text for the video button.
  /// [cameraButtonTooltip] specifies the tooltip text for the camera button.
  /// [formulaButtonTooltip] specifies the tooltip text for the formula button.
  ///
  /// [onImagePickCallback] is a callback function called when an
  ///  image is picked.
  /// [onVideoPickCallback] is a callback function called when a
  /// video is picked.
  ///
  /// [mediaPickSettingSelector] allows customizing media pick settings.
  /// [cameraPickSettingSelector] allows customizing camera pick settings.
  ///
  /// Example of customizing media pick settings for the image button:
  /// ```dart
  /// mediaPickSettingSelector: (context) async {
  ///   final mediaPickSetting = await showModalBottomSheet<MediaPickSetting>(
  ///     showDragHandle: true,
  ///     context: context,
  ///     constraints: const BoxConstraints(maxWidth: 640),
  ///     builder: (context) => const SelectImageSourceDialog(),
  ///   );
  ///   if (mediaPickSetting == null) {
  ///     return null;
  ///   }
  ///   return mediaPickSetting;
  /// }
  /// ```
  ///
  /// [filePickImpl] is an implementation for picking files.
  /// [webImagePickImpl] is an implementation for picking web images.
  /// [webVideoPickImpl] is an implementation for picking web videos.
  ///
  /// [imageLinkRegExp] is a regular expression to identify image links.
  /// [videoLinkRegExp] is a regular expression to identify video links.
  ///
  /// The returned list contains embed button builders for the Quill toolbar.
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
