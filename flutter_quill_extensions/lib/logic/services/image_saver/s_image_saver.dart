// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'image_saver.dart';
import 'packages/gal.dart' show ImageSaverGalImpl;

/// A service used for saving images in the extensions package
class ImageSaverService extends ImageSaverInterface {
  final ImageSaverInterface _impl;
  const ImageSaverService(this._impl);

  factory ImageSaverService.galPackage() => ImageSaverService(
        ImageSaverGalImpl(),
      );

  factory ImageSaverService.defaultImpl() => ImageSaverService.galPackage();

  @override
  Future<bool> hasAccess({bool toAlbum = false}) =>
      _impl.hasAccess(toAlbum: toAlbum);

  @override
  Future<bool> requestAccess({bool toAlbum = false}) =>
      _impl.requestAccess(toAlbum: toAlbum);

  @override
  Future<void> saveImageFromNetwork(Uri imageUrl) =>
      _impl.saveImageFromNetwork(imageUrl);

  @override
  Future<void> saveLocalImage(String imageUrl) =>
      _impl.saveLocalImage(imageUrl);
}
