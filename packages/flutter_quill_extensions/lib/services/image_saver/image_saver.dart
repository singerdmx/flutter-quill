abstract class ImageSaverInterface {
  const ImageSaverInterface();
  Future<void> saveLocalImage(String imageUrl);
  Future<void> saveImageFromNetwork(Uri imageUrl);
  Future<bool> hasAccess({required bool toAlbum});
  Future<bool> requestAccess({required bool toAlbum});
}
