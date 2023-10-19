library flutter_quill_extensions;

import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'embeds/builders.dart';
import 'embeds/embed_types.dart';
import 'embeds/toolbar/camera_button.dart';
import 'embeds/toolbar/formula_button.dart';
import 'embeds/toolbar/image_button.dart';
import 'embeds/toolbar/media_button.dart';
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
  /// This method provides a collection of embed builders to enhance the
  /// functionality
  /// of a QuillEditor. It offers customization options for
  /// handling various types of
  /// embedded content, such as images, videos, and formulas.
  ///
  /// **Note:** This method is not intended for web usage.
  /// For web-specific embeds,
  /// use [webBuilders].
  ///
  /// [onVideoInit] is a callback function that gets triggered when
  ///  a video is initialized.
  /// You can use this to perform actions or setup configurations related
  ///  to video embedding.
  ///
  /// [onImageRemovedCallback] is called when an image is
  ///  removed from the editor.
  /// By default, [onImageRemovedCallback] deletes the
  ///  temporary image file if
  /// the platform is mobile and if it still exists. You
  ///  can customize this behavior
  /// by passing your own function that handles the removal process.
  ///
  /// Example of [onImageRemovedCallback] customization:
  /// ```dart
  /// afterRemoveImageFromEditor: (imageFile) async {
  ///   // Your custom logic here
  ///   // or leave it empty to do nothing
  /// }
  /// ```
  ///
  /// [shouldRemoveImageCallback] is a callback
  ///  function that is invoked when the
  /// user attempts to remove an image from the editor. It allows you to control
  /// whether the image should be removed based on your custom logic.
  ///
  /// Example of [shouldRemoveImageCallback] customization:
  /// ```dart
  /// shouldRemoveImageFromEditor: (imageFile) async {
  ///   // Show a confirmation dialog before removing the image
  ///   final isShouldRemove = await showYesCancelDialog(
  ///     context: context,
  ///     options: const YesOrCancelDialogOptions(
  ///       title: 'Deleting an image',
  ///       message: 'Are you sure you want' ' to delete this
  ///      image from the editor?',
  ///     ),
  ///   );
  ///
  ///   // Return `true` to allow image removal if the user confirms, otherwise
  ///  `false`
  ///   return isShouldRemove;
  /// }
  /// ```
  ///
  /// [imageProviderBuilder] if you want to use custom image provider, please
  /// pass a value to this property
  /// By default we will use [NetworkImage] provider if the image url/path
  /// is using http/https, if not then we will use [FileImage] provider
  /// If you ovveride this make sure to handle the case where if the [imageUrl]
  /// is in the local storage or it does exists in the system file
  /// or use the same way we did it
  ///
  /// Example of [imageProviderBuilder] customization:
  /// ```dart
  /// imageProviderBuilder: (imageUrl) async {
  /// // Example of using cached_network_image package
  /// // Don't forgot to check if that image is local or network one
  /// return CachedNetworkImageProvider(imageUrl);
  /// }
  /// ```
  ///
  /// [imageErrorWidgetBuilder] if you want to show a custom widget based on the
  /// exception that happen while loading the image, if it network image or
  /// local one, and it will get called on all the images even in the photo
  /// preview widget and not just in the quill editor
  /// by default the default error from flutter framework will thrown
  ///
  /// [forceUseMobileOptionMenuForImageClick] is a boolean
  /// flag that, when set to `true`,
  /// enforces the use of the mobile-specific option menu for image clicks in
  /// other platforms like desktop, this option doesn't affect mobile. it will
  /// not affect web
  ///  This option
  /// can be used to override the default behavior based on the platform.
  ///
  /// The method returns a list of [EmbedBuilder] objects that can be used with
  ///  QuillEditor
  /// to enable embedded content features like images, videos, and formulas.
  ///
  /// Example usage:
  /// ```dart
  /// final embedBuilders = QuillEmbedBuilders.builders(
  ///   onVideoInit: (videoContainerKey) {
  ///     // Custom video initialization logic
  ///   },
  ///   // Customize other callback functions as needed
  /// );
  ///
  /// final quillEditor = QuillEditor(
  ///   // Other editor configurations
  ///   embedBuilders: embedBuilders,
  /// );
  /// ```
  static List<EmbedBuilder> builders({
    void Function(GlobalKey videoContainerKey)? onVideoInit,
    ImageEmbedBuilderOnRemovedCallback? onImageRemovedCallback,
    ImageEmbedBuilderWillRemoveCallback? shouldRemoveImageCallback,
    ImageEmbedBuilderProviderBuilder? imageProviderBuilder,
    ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder,
    bool forceUseMobileOptionMenuForImageClick = false,
  }) =>
      [
        ImageEmbedBuilder(
          imageErrorWidgetBuilder: imageErrorWidgetBuilder,
          imageProviderBuilder: imageProviderBuilder,
          forceUseMobileOptionMenu: forceUseMobileOptionMenuForImageClick,
          onImageRemovedCallback: onImageRemovedCallback ??
              (imageFile) async {
                final mobile = isMobile();
                // If the platform is not mobile, return void;
                // Since the mobile OS gives us a copy of the image

                // Note: We should remove the image on Flutter web
                // since the behavior is similar to how it is on mobile,
                // but since this builder is not for web, we will ignore it
                if (!mobile) {
                  return;
                }

                // On mobile OS (Android, iOS), the system will not give us
                // direct access to the image; instead,
                // it will give us the image
                // in the temp directory of the application. So, we want to
                // remove it when we no longer need it.

                // but on desktop we don't want to touch user files
                // especially on macOS, where we can't even delete it without
                // permission

                final isFileExists = await imageFile.exists();
                if (isFileExists) {
                  await imageFile.delete();
                }
              },
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
    bool showImageMediaButton = false,
    bool showFormulaButton = false,
    String? imageButtonTooltip,
    String? videoButtonTooltip,
    String? cameraButtonTooltip,
    String? formulaButtonTooltip,
    OnImagePickCallback? onImagePickCallback,
    OnVideoPickCallback? onVideoPickCallback,
    MediaPickSettingSelector? mediaPickSettingSelector,
    MediaPickSettingSelector? cameraPickSettingSelector,
    MediaPickedCallback? onImageMediaPickedCallback,
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
        if (showImageMediaButton)
          (controller, toolbarIconSize, iconTheme, dialogTheme) => MediaButton(
                controller: controller,
                dialogTheme: dialogTheme,
                iconTheme: iconTheme,
                iconSize: toolbarIconSize,
                onMediaPickedCallback: onImageMediaPickedCallback,
                onImagePickCallback: onImagePickCallback ??
                    (throw ArgumentError.notNull(
                      'onImagePickCallback is required when showCameraButton is'
                      ' true',
                    )),
                onVideoPickCallback: onVideoPickCallback ??
                    (throw ArgumentError.notNull(
                      'onVideoPickCallback is required when showCameraButton is'
                      ' true',
                    )),
                filePickImpl: filePickImpl,
                webImagePickImpl: webImagePickImpl,
                webVideoPickImpl: webVideoPickImpl,
                icon: Icons.perm_media,
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
              ),
      ];
}
