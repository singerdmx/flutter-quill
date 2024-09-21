import 'dart:io' show Directory, File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:path/path.dart' as path;

typedef OnGenerateNewFileNameCallback = String Function(
  String currentFileName,
  String fileExt,
);

@Deprecated(
  'QuillImageUtilities is no longer supported an will be removed in future releases.',
)
class QuillImageUtilities {
  const QuillImageUtilities({
    required this.document,
  });

  final quill.Document document;

  /// Private function that is throw an error if the platform is web
  static void _webIsNotSupported(String functionName) {
    if (kIsWeb) {
      throw UnsupportedError(
        'The static function "$functionName()"'
        ' on class "QuillImageUtilities" is not supported in Web',
      );
    }
  }

  /// Saves a list of images to a specified directory.
  ///
  /// This function is designed to work efficiently on
  /// mobile platforms, but it can also be used on other platforms.
  /// But it's not supported on web for now
  ///
  /// When you have a list of cached image paths
  ///  from a Quill document and you want to save them,
  /// you can use this function.
  /// It takes a list of image paths and copies each image to the specified
  /// directory. If the image
  /// path does not exist, it returns an
  /// empty string for that item.
  ///
  /// Make sure that the image paths provided in the [images]
  /// list exist, and handle the cases where images are not found accordingly.
  ///
  /// [images]: List of image paths to be saved.
  /// [deleteThePreviousImages]: Indicates whether to delete the
  ///  original cached images after copying.
  /// [saveDirectory]: The directory where the images will be saved.
  /// [startOfEachFile]: Each file will have a name and it need to be unique
  /// but to make the file name is clear we will need a string represent
  /// the start of each file
  ///
  /// Returns a list of paths to the newly saved images.
  /// For images that do not exist, their paths are returned as empty strings.
  ///
  /// Example usage:
  /// ```dart
  /// final documentsDir = await getApplicationDocumentsDirectory();
  /// final savedImagePaths = await saveImagesToDirectory(
  ///   images: cachedImagePaths,
  ///   deleteThePreviousImages: true,
  ///   saveDirectory: documentsDir,
  ///   startOfEachFile: 'quill-image-', // default
  /// );
  /// ```
  static Future<List<String>> saveImagesToDirectory({
    required Iterable<String> images,
    required deleteThePreviousImages,
    required Directory saveDirectory,
    OnGenerateNewFileNameCallback? onGenerateNewFileName,
  }) async {
    _webIsNotSupported('saveImagesToDirectory');
    final newImagesFutures = images.map((cachedImagePath) async {
      final previousImageFile = File(cachedImagePath);
      final isPreviousImageFileExists = await previousImageFile.exists();

      if (!isPreviousImageFileExists) {
        return '';
      }

      final newImageFileExtension = path.extension(cachedImagePath); // with dot

      final dateTimeString = DateTime.now().toIso8601String();
      final newImageFileName = onGenerateNewFileName?.call(
            cachedImagePath,
            newImageFileExtension,
          ) ??
          'quill-image-$dateTimeString$newImageFileExtension';
      final newImagePath = path.join(saveDirectory.path, newImageFileName);
      final newImageFile = await previousImageFile.copy(newImagePath);
      if (deleteThePreviousImages) {
        await previousImageFile.delete();
      }
      return newImageFile.path;
    });
    // Await for the saving process for each image
    final newImages = await Future.wait(newImagesFutures);
    return newImages;
  }

  /// Deletes all local images referenced in a Quill document.
  /// it's not supported on web for now
  ///
  /// Be **careful**, on desktop you should never delete user images. only if you
  /// are sure the image is saved in applicaton documents directory
  ///
  /// on mobile the app is sandboxed so you can't delete user images
  /// because it will be a copy of the image for the app
  /// so you should be safe
  ///
  /// This function removes local images from the
  /// file system that are referenced in the provided [document].
  ///
  /// [document]: The Quill document from which images will be deleted.
  ///
  /// Throws an [Exception] if any errors occur during the deletion process.
  ///
  /// Example usage:
  /// ```dart
  /// try {
  ///   await deleteAllLocalImagesOfDocument(myQuillDocument);
  /// } catch (e) {
  ///   print('Error deleting local images: $e');
  /// }
  /// ```
  Future<void> deleteAllLocalImages() async {
    _webIsNotSupported('deleteAllLocalImagesOfDocument');
    final imagesPaths = getImagesPathsFromDocument(
      onlyLocalImages: true,
    );
    for (final image in imagesPaths) {
      final imageFile = File(image);
      final fileExists = await imageFile.exists();
      if (!fileExists) {
        return;
      }
      final deletedFile = await imageFile.delete();
      final deletedFileStillExists = await deletedFile.exists();
      if (deletedFileStillExists) {
        throw Exception(
          'We have successfully deleted the file and it is still exists!!',
        );
      }
    }
  }

  /// Retrieves paths to images embedded in a Quill document.
  ///
  /// it's not supported on web for now.
  /// This function parses the Document and returns a list of image paths.
  ///
  /// [document]: The Quill document from which image paths will be retrieved.
  /// [onlyLocalImages]: If `true`,
  /// only local (non-web-url) image paths will be included.
  ///
  /// Returns an iterable of image paths.
  ///
  /// Example usage:
  /// ```dart
  /// final quillDocument = _controller.document;
  /// final imagePaths
  ///  = getImagesPathsFromDocument(quillDocument, onlyLocalImages: true);
  /// print('Image paths: $imagePaths');
  /// ```
  ///
  /// Note: This function assumes that images are
  ///  embedded as block embeds in the Quill document.
  Iterable<String> getImagesPathsFromDocument({
    required bool onlyLocalImages,
  }) {
    _webIsNotSupported('getImagesPathsFromDocument');
    // final images = document.root.children
    //     .whereType<quill.Line>()
    //     .where((node) {
    //       if (node.isEmpty) {
    //         return false;
    //       }
    //       final firstNode = node.children.first;
    //       if (firstNode is! quill.Embed) {
    //         return false;
    //       }

    //       if (firstNode.value.type != quill.BlockEmbed.imageType) {
    //         return false;
    //       }
    //       final imageSource = firstNode.value.data;
    //       if (imageSource is! String) {
    //         return false;
    //       }
    //       if (onlyLocalImages && isHttpBasedUrl(imageSource)) {
    //         return false;
    //       }
    //       return imageSource.trim().isNotEmpty;
    //     })
    //     .toList()
    //     .map((e) => (e.children.first as quill.Embed).value.data as String);

    final images = <String>[];
    for (final item in document.toDelta().toJson()) {
      if (!item.containsKey(Operation.insertKey)) {
        return [];
      }
      final insertValue = item[Operation.insertKey];

      // Check if the insert value is a map with the "image" key
      if (insertValue is Map &&
          insertValue.containsKey(quill.BlockEmbed.imageType)) {
        final String imageUrl = insertValue[quill.BlockEmbed.imageType];
        images.add(imageUrl);
      }
    }
    return images;
  }

  /// Determines if an image file is cached based on the platform.
  /// it's not supported on web for now
  ///
  /// On mobile platforms (Android and iOS), images are typically
  ///  cached in temporary directories.
  /// This function helps identify whether the given image file path
  ///  is a cached path on supported platforms.
  ///
  /// [imagePath] is the path of the image file to check for caching.
  ///
  /// Returns `true` if the image is cached, `false` otherwise.
  /// On other platforms it will always return false
  static bool isImageCached(String imagePath) {
    // Determine if the image path is a cached path based on platform
    if (kIsWeb) {
      // For now this will not work for web
      return false;
    }
    if (Platform.isAndroid) {
      return imagePath.contains('cache');
    }
    if (Platform.isIOS) {
      // Don't use isAppleOS() since macOS has different behavior
      return imagePath.contains('tmp');
    }
    // On other platforms like desktop
    // The image is not cached and we will get a direct
    // access to the image
    return false;
  }

  /// Retrieves cached image paths from a Quill document,
  ///  primarily for mobile platforms.
  ///
  /// it's not supported on web for now
  ///
  /// This function scans a Quill document to identify
  ///  and return paths to locally cached images.
  /// It is specifically designed for mobile
  ///  operating systems (Android and iOS).
  ///
  ///
  /// [replaceUnexistentImagesWith] is an optional parameter.
  ///  If provided, it replaces non-existent image paths
  /// with the specified value. If not provided, non-existent
  /// image paths are removed from the result.
  ///
  /// Returns a list of cached image paths found in the document.
  /// On non-mobile platforms, this function returns an empty list.
  Iterable<String> getCachedImagePathsFromDocument({
    String? replaceUnexistentImagesWith,
  }) {
    _webIsNotSupported('getCachedImagePathsFromDocument');
    final imagePaths = getImagesPathsFromDocument(
      onlyLocalImages: true,
    );

    // We don't want the not cached images to be saved again for example.
    final cachesImagePaths = imagePaths.where((imagePath) {
      final isCurrentImageCached = isImageCached(imagePath);
      return isCurrentImageCached;
    }).toList();
    return cachesImagePaths;
  }
}
