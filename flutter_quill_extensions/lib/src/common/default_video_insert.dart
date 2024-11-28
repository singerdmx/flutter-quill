import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

import '../toolbar/video/config/video.dart';
import 'extensions/controller_ext.dart';

OnVideoInsertCallback _defaultOnVideoInsert() {
  return (imageUrl, controller) async {
    controller
      ..skipRequestKeyboard = true
      // ignore: deprecated_member_use_from_same_package
      ..insertVideoBlock(videoUrl: imageUrl);
  };
}

@internal
Future<void> handleVideoInsert(
  String videoUrl, {
  required QuillController controller,
  required OnVideoInsertCallback? onVideoInsertCallback,
  required OnVideoInsertedCallback? onVideoInsertedCallback,
}) async {
  final customOnVideoInsert = onVideoInsertCallback;
  if (customOnVideoInsert != null) {
    await customOnVideoInsert.call(videoUrl, controller);
  } else {
    await _defaultOnVideoInsert().call(videoUrl, controller);
  }
  await onVideoInsertedCallback?.call(videoUrl);
}
