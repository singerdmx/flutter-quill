import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';

import '../image_embed_types.dart';

/// [QuillEditorImageEmbedConfigurations] for desktop, mobile and
///  other platforms
/// excluding web, it's configurations that is needed for the editor
///
@immutable
class QuillEditorImageEmbedConfigurations {
  const QuillEditorImageEmbedConfigurations({
    ImageEmbedBuilderOnRemovedCallback? onImageRemovedCallback,
    this.shouldRemoveImageCallback,
    this.imageProviderBuilder,
    this.imageErrorWidgetBuilder,
    this.onImageClicked,
  }) : _onImageRemovedCallback = onImageRemovedCallback;

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
  /// Default value if the passed value is null:
  /// [QuillEditorImageEmbedConfigurations.defaultOnImageRemovedCallback]
  ///
  /// so if you want to do nothing make sure to pass a empty callback
  /// instead of passing null as value
  final ImageEmbedBuilderOnRemovedCallback? _onImageRemovedCallback;

  ImageEmbedBuilderOnRemovedCallback get onImageRemovedCallback {
    return _onImageRemovedCallback ??
        QuillEditorImageEmbedConfigurations.defaultOnImageRemovedCallback;
  }

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
  final ImageEmbedBuilderWillRemoveCallback? shouldRemoveImageCallback;

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
  final ImageEmbedBuilderProviderBuilder? imageProviderBuilder;

  /// [imageErrorWidgetBuilder] if you want to show a custom widget based on the
  /// exception that happen while loading the image, if it network image or
  /// local one, and it will get called on all the images even in the photo
  /// preview widget and not just in the quill editor
  /// by default the default error from flutter framework will thrown
  ///
  final ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder;

  /// What should happen when the image is pressed?
  ///
  /// By default will show `ImageOptionsMenu` dialog. If you want to handle what happens
  /// to the image when it's clicked, you can pass a callback to this property.
  final void Function(String imageSource)? onImageClicked;

  static ImageEmbedBuilderOnRemovedCallback get defaultOnImageRemovedCallback {
    return (imageUrl) async {
      if (kIsWeb) {
        return;
      }

      final mobile = isMobileApp;
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
      // especially on macOS, where we can't even delete
      // it without
      // permission

      final dartIoImageFile = File(imageUrl);

      final isFileExists = await dartIoImageFile.exists();
      if (isFileExists) {
        await dartIoImageFile.delete();
      }
    };
  }

  QuillEditorImageEmbedConfigurations copyWith({
    ImageEmbedBuilderOnRemovedCallback? onImageRemovedCallback,
    ImageEmbedBuilderWillRemoveCallback? shouldRemoveImageCallback,
    ImageEmbedBuilderProviderBuilder? imageProviderBuilder,
    ImageEmbedBuilderErrorWidgetBuilder? imageErrorWidgetBuilder,
    bool? forceUseMobileOptionMenuForImageClick,
  }) {
    return QuillEditorImageEmbedConfigurations(
      onImageRemovedCallback: onImageRemovedCallback ?? _onImageRemovedCallback,
      shouldRemoveImageCallback:
          shouldRemoveImageCallback ?? this.shouldRemoveImageCallback,
      imageProviderBuilder: imageProviderBuilder ?? this.imageProviderBuilder,
      imageErrorWidgetBuilder:
          imageErrorWidgetBuilder ?? this.imageErrorWidgetBuilder,
    );
  }
}
