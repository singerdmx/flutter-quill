import 'package:flutter/widgets.dart' show NetworkImageLoadException;
import 'package:gal/gal.dart' show Gal, GalException, GalExceptionType;
import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../image_saver.dart';

class ImageSaverGalImpl extends ImageSaverInterface {
  @override
  Future<void> saveImageFromNetwork(Uri imageUrl) async {
    try {
      final response = await http.get(
        imageUrl,
      );
      if (response.statusCode != 200) {
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: imageUrl,
        );
      }
      final imageBytes = response.bodyBytes;
      await Gal.putImageBytes(imageBytes);
    } on GalException catch (e) {
      throw ImageSaverException(
        message: e.toString(),
        type: e.type.toImageSaverExceptionType(),
      );
    } catch (e) {
      throw ImageSaverException(
        message: e.toString(),
        type: ImageSaverExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> saveLocalImage(String imageUrl) async {
    try {
      await Gal.putImage(imageUrl);
    } on GalException catch (e) {
      throw ImageSaverException(
        message: e.toString(),
        type: e.type.toImageSaverExceptionType(),
      );
    } catch (e) {
      throw ImageSaverException(
        message: e.toString(),
        type: ImageSaverExceptionType.unknown,
      );
    }
  }

  @override
  Future<bool> hasAccess({required bool toAlbum}) {
    return Gal.hasAccess(toAlbum: toAlbum);
  }

  @override
  Future<bool> requestAccess({required bool toAlbum}) {
    return Gal.requestAccess(toAlbum: toAlbum);
  }
}

extension GalExceptionTypeExt on GalExceptionType {
  ImageSaverExceptionType toImageSaverExceptionType() {
    switch (this) {
      case GalExceptionType.accessDenied:
        return ImageSaverExceptionType.accessDenied;
      case GalExceptionType.notEnoughSpace:
        return ImageSaverExceptionType.notEnoughSpace;
      case GalExceptionType.notSupportedFormat:
        return ImageSaverExceptionType.notSupportedFormat;
      case GalExceptionType.unexpected:
        return ImageSaverExceptionType.unexpected;
    }
  }
}
