// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'image_saver.dart';
import 'packages/gal.dart' show ImageSaverGalImpl;

class ImageSaverService extends ImageSaverInterface {
  final ImageSaverInterface _provider;
  const ImageSaverService({
    required ImageSaverInterface impl,
  }) : _provider = impl;

  factory ImageSaverService.gal() => ImageSaverService(
        impl: ImageSaverGalImpl(),
      );

  static final _instance = ImageSaverService.gal();
  factory ImageSaverService.getInstance() => _instance;

  @override
  Future<bool> hasAccess({bool toAlbum = false}) =>
      _provider.hasAccess(toAlbum: toAlbum);

  @override
  Future<bool> requestAccess({bool toAlbum = false}) =>
      _provider.requestAccess(toAlbum: toAlbum);

  @override
  Future<void> saveImageFromNetwork(Uri imageUrl) =>
      _provider.saveImageFromNetwork(imageUrl);

  @override
  Future<void> saveLocalImage(String imageUrl) =>
      _provider.saveLocalImage(imageUrl);
}
