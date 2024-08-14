import 'image_picker.dart';
import 'packages/image_picker.dart';

/// A service used for packing images in the extensions package
class ImagePickerService extends ImagePickerInterface {
  const ImagePickerService(
    this._impl,
  );

  factory ImagePickerService.imagePickerPackage() => const ImagePickerService(
        ImagePickerPackageImpl(),
      );

  factory ImagePickerService.defaultImpl() =>
      ImagePickerService.imagePickerPackage();

  final ImagePickerInterface _impl;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) =>
      _impl.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
        requestFullMetadata: requestFullMetadata,
      );

  @override
  Future<XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) =>
      _impl.pickMedia(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) =>
      _impl.pickVideo(
        source: source,
        preferredCameraDevice: preferredCameraDevice,
        maxDuration: maxDuration,
      );
}
