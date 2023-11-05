/// Specifies the source where the picked image should come from.
enum ImageSource {
  /// Opens up the device camera, letting the user to take a new picture.
  camera,

  /// Opens the user's photo gallery.
  gallery,
}

enum CameraDevice {
  /// Use the rear camera.
  ///
  /// In most of the cases, it is the default configuration.
  rear,

  /// Use the front camera.
  ///
  /// Supported on all iPhones/iPads and some Android devices.
  front,
}
