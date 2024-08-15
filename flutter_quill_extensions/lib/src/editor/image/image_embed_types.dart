import 'package:flutter/widgets.dart'
    show ImageErrorWidgetBuilder, ImageProvider;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show immutable;

import '../../common/extensions/controller_ext.dart';
import '../../editor_toolbar_shared/image_picker/s_image_picker.dart';

/// When request picking an image, for example when the image button toolbar
/// clicked, it should be null in case the user didn't choose any image or
/// any other reasons, and it should be the image file path as string that is
/// exists in case the user picked the image successfully
///
/// by default we already have a default implementation that show a dialog
/// request the source for picking the image, from gallery, link or camera
typedef OnRequestPickImage = Future<String?> Function(
  BuildContext context,
  ImagePickerService imagePickerService,
);

/// A callback will called when inserting a image in the editor
/// it have the logic that will insert the image block using the controller
typedef OnImageInsertCallback = Future<void> Function(
  String image,
  QuillController controller,
);

OnImageInsertCallback defaultOnImageInsertCallback() {
  return (imageUrl, controller) async {
    controller
      ..skipRequestKeyboard = true
      ..insertImageBlock(imageSource: imageUrl);
  };
}

/// When a new image picked this callback will called and you might want to
/// do some logic depending on your use case
typedef OnImageInsertedCallback = Future<void> Function(
  String image,
);

enum InsertImageSource {
  gallery,
  camera,
  link,
}

/// Configurations for dealing with images, on insert a image
/// on request picking a image
@immutable
class QuillToolbarImageConfigurations {
  const QuillToolbarImageConfigurations({
    this.onRequestPickImage,
    this.onImageInsertedCallback,
    OnImageInsertCallback? onImageInsertCallback,
  }) : _onImageInsertCallback = onImageInsertCallback;

  final OnRequestPickImage? onRequestPickImage;

  final OnImageInsertedCallback? onImageInsertedCallback;

  final OnImageInsertCallback? _onImageInsertCallback;

  OnImageInsertCallback get onImageInsertCallback {
    return _onImageInsertCallback ?? defaultOnImageInsertCallback();
  }
}

typedef ImageEmbedBuilderWillRemoveCallback = Future<bool> Function(
  String imageUrl,
);

typedef ImageEmbedBuilderOnRemovedCallback = Future<void> Function(
  String imageUrl,
);

typedef ImageEmbedBuilderProviderBuilder = ImageProvider Function(
  BuildContext context,
  String imageUrl,
);

typedef ImageEmbedBuilderErrorWidgetBuilder = ImageErrorWidgetBuilder;
