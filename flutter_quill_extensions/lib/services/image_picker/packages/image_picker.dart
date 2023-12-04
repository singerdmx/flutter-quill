import 'package:image_picker/image_picker.dart' as package
    show ImagePicker, ImageSource, CameraDevice;

import '../image_picker.dart';

class ImagePickerPackageImpl extends ImagePickerInterface {
  const ImagePickerPackageImpl();
  package.ImagePicker get _picker {
    return package.ImagePicker();
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    return _picker.pickImage(
      source: source.toImagePickerPackage(),
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice.toImagePickerPackage(),
      requestFullMetadata: requestFullMetadata,
    );
  }

  @override
  Future<XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) {
    return _picker.pickMedia(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      requestFullMetadata: requestFullMetadata,
    );
  }

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    return _picker.pickVideo(
      source: source.toImagePickerPackage(),
      preferredCameraDevice: preferredCameraDevice.toImagePickerPackage(),
      maxDuration: maxDuration,
    );
  }
}

extension ImageSoureceExt on ImageSource {
  package.ImageSource toImagePickerPackage() {
    switch (this) {
      case ImageSource.camera:
        return package.ImageSource.camera;
      case ImageSource.gallery:
        return package.ImageSource.gallery;
    }
  }
}

extension CameraDeviceExt on CameraDevice {
  package.CameraDevice toImagePickerPackage() {
    switch (this) {
      case CameraDevice.rear:
        return package.CameraDevice.rear;
      case CameraDevice.front:
        return package.CameraDevice.front;
    }
  }
}
