@internal
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/internal.dart';
import 'package:meta/meta.dart';

import '../../common/utils/file_path_utils.dart';
import 'image_load_utils.dart';

const defaultImageFileExtension = 'png';

String extractImageFileExtensionFromFileName(String? imageFileName) {
  if (imageFileName == null || imageFileName.isEmpty) {
    return defaultImageFileExtension;
  }

  if (!imageFileName.contains('.')) {
    return defaultImageFileExtension;
  }

  return imageFileName.split('.').lastOrNull ?? defaultImageFileExtension;
}

String? extractImageNameFromFileName(
  String? imageFileName, {
  required String imageFileExtension,
}) {
  if (imageFileName == null || imageFileName.isEmpty) {
    return null;
  }
  if (imageFileExtension.isEmpty) {
    throw ArgumentError.value(
      imageFileExtension,
      'imageFileExtension',
      'cannot be empty',
    );
  }
  return imageFileName.replaceFirst('.$imageFileExtension', '');
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
    // Windows and macOS system native save dialog handle name conflicts.
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

  // Returns `null` on failure.
  // Throws [GalleryImageSaveAccessDeniedException] in case permission was denied or insuffeicnet.
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

    final imageFileName = extractFileNameFromUrl(imageUrl);
    final imageFileExtension =
        extractImageFileExtensionFromFileName(imageFileName);
    final imageName = extractImageNameFromFileName(
      imageFileName,
      imageFileExtension: imageFileExtension,
    );

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
