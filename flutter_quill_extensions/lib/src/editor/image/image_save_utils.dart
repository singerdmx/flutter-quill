@internal
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/internal.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'image_load_utils.dart';

const defaultImageFileExtension = 'png';

// The [imageSourcePath] could be file, asset path or HTTP image URL.
String extractImageFileExtensionFromImageSource(String? imageSourcePath) {
  if (imageSourcePath == null || imageSourcePath.isEmpty) {
    return defaultImageFileExtension;
  }

  if (!imageSourcePath.contains('.')) {
    return defaultImageFileExtension;
  }

  return p.extension(imageSourcePath).replaceFirst('.', '');
}

// The [imageSourcePath] could be file, asset path or HTTP image URL.
String? extractImageNameFromImageSource(String? imageSourcePath) {
  if (imageSourcePath == null || imageSourcePath.isEmpty) {
    return null;
  }
  final uri = Uri.parse(imageSourcePath);
  final pathWithoutQuery = uri.path;

  final imageName = p.basenameWithoutExtension(pathWithoutQuery);
  if (imageName.isEmpty) {
    return null;
  }
  return imageName;
}

class SaveImageResult {
  const SaveImageResult({
    required this.imageFilePath,
    required this.isGallerySave,
  });

  /// Returns `null` on web platforms, if [isGallerySave] is `true`
  /// or in case the user cancels the save operation on desktop platforms.
  final String? imageFilePath;

  final bool isGallerySave;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! SaveImageResult) return false;
    return other.imageFilePath == imageFilePath &&
        other.isGallerySave == isGallerySave;
  }

  @override
  int get hashCode => Object.hash(imageFilePath, isGallerySave);

  @override
  String toString() =>
      'SaveImageResult(imageFilePath: $imageFilePath, isGallerySave: $isGallerySave)';
}

const String defaultImageFileNamePrefix = 'IMG';

String getDefaultImageFileName({required bool isGallerySave}) {
  if (kIsWeb) {
    // The browser handles name conflicts.
    return defaultImageFileNamePrefix;
  }
  if (isGallerySave) {
    // The gallery app handles name conflicts.
    return defaultImageFileNamePrefix;
  }
  if (defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    // Windows and macOS system native save dialog prompts the user to confirm file overwrite.
    return defaultImageFileNamePrefix;
  }
  final uniqueFileName =
      '${defaultImageFileNamePrefix}_${DateTime.now().toIso8601String()}';
  if (defaultTargetPlatform == TargetPlatform.linux) {
    // IMPORTANT: On Linux, it depends on the desktop environment
    // and name conflicts may not be handled. Always provide a unique image file name.
    return uniqueFileName;
  }

  return uniqueFileName;
}

Future<bool> shouldSaveToGallery({required bool prefersGallerySave}) async {
  final supportsGallerySave = await QuillNativeProvider.instance
      .isSupported(QuillNativeBridgeFeature.saveImageToGallery);
  if (!supportsGallerySave) {
    return false;
  }
  final supportsImageSave = await QuillNativeProvider.instance
      .isSupported(QuillNativeBridgeFeature.saveImage);
  if (!supportsImageSave) {
    return true;
  }

  return supportsGallerySave && prefersGallerySave;
}

/// Thrown when the gallery image save operation is denied
/// due to insufficient or denied permissions.
class GalleryImageSaveAccessDeniedException implements Exception {
  GalleryImageSaveAccessDeniedException([this.message]);

  final String? message;

  @override
  String toString() =>
      message ??
      'Permission to save the image to the gallery was denied or insufficient.';
}

class ImageSaver {
  ImageSaver._();

  static ImageSaver _instance = ImageSaver._();

  static ImageSaver get instance => _instance;

  /// Allows overriding the instance for testing
  @visibleForTesting
  static set instance(ImageSaver newInstance) => _instance = newInstance;

  /// Saves an image to the user's device based on the platform:
  ///
  /// - **Web**: Downloads the image using the browser's download functionality.
  /// - **Desktop**: Prompts the user to choose a location for the image using
  /// native save dialog, defaulting to the user's `Pictures` directory. Or
  /// saves the image to the gallery in case [prefersGallerySave] is `true` and
  // TODO(quill_native_bridge): Update this doc comment once saveImageToGallery()
  //  is supported on Windows too (will be applicable like macOS). See https://pub.dev/packages/quill_native_bridge#-features
  /// the gallery is supported (currently only macOS is applicable).
  /// - **Mobile**: Saves the image to the gallery, requesting permission if needed.
  ///
  /// The [imageUrl] could be file or network image URL and is used to extract
  /// image file extension and the image name.
  ///
  /// The [imageProvider] is used to load the image bytes from using [ImageLoader].
  ///
  /// Returns `null` on failure.
  ///
  /// Throws [GalleryImageSaveAccessDeniedException] in case permission was denied or insuffeicnet.
  Future<SaveImageResult?> saveImage({
    required String imageUrl,
    required ImageProvider imageProvider,
    required bool prefersGallerySave,
  }) async {
    assert(() {
      if (imageUrl.isEmpty) {
        throw ArgumentError.value(imageUrl, 'imageUrl', 'cannot be empty');
      }
      return true;
    }());

    final imageFileExtension =
        extractImageFileExtensionFromImageSource(imageUrl);
    final imageName = extractImageNameFromImageSource(imageUrl);

    final imageBytes = await ImageLoader.instance
        .loadImageBytesFromImageProvider(imageProvider: imageProvider);
    if (imageBytes == null || imageBytes.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      await QuillNativeProvider.instance.saveImage(
        imageBytes,
        options: ImageSaveOptions(
            name: imageName ?? getDefaultImageFileName(isGallerySave: false),
            fileExtension: imageFileExtension),
      );
      return const SaveImageResult(
        imageFilePath: null,
        isGallerySave: false,
      );
    }

    if (await shouldSaveToGallery(prefersGallerySave: prefersGallerySave)) {
      try {
        await QuillNativeProvider.instance.saveImageToGallery(
          imageBytes,
          options: GalleryImageSaveOptions(
            name: imageName ?? getDefaultImageFileName(isGallerySave: true),
            fileExtension: imageFileExtension,
            // Specifying the album name requires read-write permission
            // on iOS and macOS on all versions. Pass null to request add-only on
            // supported versions (previous versions still use read-write).
            albumName: null,
          ),
        );

        return const SaveImageResult(
          imageFilePath: null,
          isGallerySave: true,
        );
      } on PlatformException catch (e) {
        // TODO(save-image): Part of https://github.com/FlutterQuill/quill-native-bridge/issues/2

        // Permission request is required only on iOS, macOS and Android API 28 and earlier.
        if (e.code == 'PERMISSION_DENIED') {
          // macOS imposes security restrictions when running the app
          // on sources other than Xcode or the macOS terminal, such as Android Studio or VS Code.
          // This is not an issue in production. Throwing [GalleryImageSaveAccessDeniedException] will indicate
          // that the user denied the permission, even though it will always deny the permission even if granted.
          // Make sure we don't handle that error (it has details) during development to avoid confusion.
          // For more details, see https://github.com/flutter/flutter/issues/134191#issuecomment-2506248266
          // and https://pub.dev/packages/quill_native_bridge#-saving-images-to-the-gallery

          final possiblePermissionIssueDuringDevelopmentOnMacOS =
              kDebugMode && defaultTargetPlatform == TargetPlatform.macOS;
          if (possiblePermissionIssueDuringDevelopmentOnMacOS) {
            rethrow;
          }

          throw GalleryImageSaveAccessDeniedException(e.toString());
        }
        rethrow;
      }
    }

    if (await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.saveImage)) {
      assert(!isMobileApp,
          'Mobile platforms support saving images to the gallery only');

      final result = await QuillNativeProvider.instance.saveImage(
        imageBytes,
        options: ImageSaveOptions(
          name: imageName ?? getDefaultImageFileName(isGallerySave: false),
          fileExtension: imageFileExtension,
        ),
      );
      return SaveImageResult(
        imageFilePath: result.filePath,
        isGallerySave: false,
      );
    }

    throw StateError('Image save is not handled on $defaultTargetPlatform');
  }
}
