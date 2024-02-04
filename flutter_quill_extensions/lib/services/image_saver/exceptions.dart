import 'package:meta/meta.dart' show immutable;

enum ImageSaverExceptionType {
  accessDenied,
  notEnoughSpace,
  notSupportedFormat,
  unexpected,
  unknown;
}

@immutable
class ImageSaverException implements Exception {
  const ImageSaverException({
    required this.message,
    required this.type,
  });

  final String message;
  final ImageSaverExceptionType type;

  @override
  String toString() => 'Error while saving image, error type: ${type.name}';
}
