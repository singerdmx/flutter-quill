import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_quill/flutter_quill.dart';
import '../../../logic/extensions/controller.dart';
import '../../../logic/services/image_picker/s_image_picker.dart';

/// When request picking an image, for example when the image button toolbar
/// clicked, it should be null in case the user didn't choose any image or
/// any other reasons, and it should be the image file path as string that is
/// existied in case the user picked the image successfully
///
/// by default we already have a default implementation that show a dialog
/// request the source for picking the image, from gallery, link or camera
typedef OnRequestPickImage = Future<String?> Function(
  BuildContext context,
  ImagePickerService imagePickerService,
);

/// When a new image picked this callback will called and you might want to
/// do some logic depending on your use case
typedef OnImagePickedCallback = Future<void> Function(
  String image,
);

/// A callback will called when inserting a image in the editor
typedef OnImageInsertCallback = Future<void> Function(
  String image,
  QuillController controller,
);

OnImageInsertCallback defaultOnImageInsertCallback() {
  return (imageUrl, controller) async {
    controller
      ..skipRequestKeyboard = true
      ..insertImageBlock(imageUrl: imageUrl);
  };
}

enum InsertImageSource {
  gallery,
  camera,
  link,
}
