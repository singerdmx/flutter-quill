import 'package:flutter/widgets.dart' show BuildContext;
import 'package:meta/meta.dart' show immutable;

import '../../editor/image/image_embed_types.dart';
import '../video/config/video.dart';

enum CameraAction {
  video,
  image,
}

/// When the user click the camera button, should we take a photo or record
/// a video using the camera
///
/// by default will show a dialog that ask the user which option he/she wants
typedef OnRequestCameraActionCallback = Future<CameraAction?> Function(
  BuildContext context,
);

@immutable
class QuillToolbarCameraConfig {
  const QuillToolbarCameraConfig({
    this.onRequestCameraActionCallback,
    this.onImageInsertCallback,
    this.onImageInsertedCallback,
    this.onVideoInsertedCallback,
    this.onVideoInsertCallback,
  });

  final OnRequestCameraActionCallback? onRequestCameraActionCallback;

  final OnImageInsertedCallback? onImageInsertedCallback;

  final OnImageInsertCallback? onImageInsertCallback;

  final OnVideoInsertedCallback? onVideoInsertedCallback;

  final OnVideoInsertCallback? onVideoInsertCallback;
}
