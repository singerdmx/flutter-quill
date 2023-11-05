import 'package:cross_file/cross_file.dart' show XFile;

import 'image_options.dart';

export 'package:cross_file/cross_file.dart' show XFile;

export 'image_options.dart';

abstract class ImagePickerInterface {
  const ImagePickerInterface();
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  });
  Future<XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  });
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  });
}
