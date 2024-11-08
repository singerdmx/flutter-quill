import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

import '../editor/image/image_embed_types.dart';
import 'extensions/controller_ext.dart';

OnImageInsertCallback _defaultOnImageInsert() {
  return (imageUrl, controller) async {
    controller
      ..skipRequestKeyboard = true
      // ignore: deprecated_member_use_from_same_package
      ..insertImageBlock(imageSource: imageUrl);
  };
}

@internal
Future<void> handleImageInsert(
  String imageUrl, {
  required QuillController controller,
  required OnImageInsertCallback? onImageInsertCallback,
  required OnImageInsertedCallback? onImageInsertedCallback,
}) async {
  final customOnImageInsert = onImageInsertCallback;
  if (customOnImageInsert != null) {
    await customOnImageInsert.call(imageUrl, controller);
  } else {
    await _defaultOnImageInsert().call(imageUrl, controller);
  }
  await onImageInsertedCallback?.call(imageUrl);
}
