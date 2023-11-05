import 'package:flutter/widgets.dart' show BuildContext;
import 'package:meta/meta.dart' show immutable;

import 'image.dart';

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
class QuillToolbarCameraConfigurations {
  const QuillToolbarCameraConfigurations({
    this.onRequestCameraActionCallback,
    OnImageInsertCallback? onImageInsertCallback,
    this.onImageInsertedCallback,
  }) : _onImageInsertCallback = onImageInsertCallback;

  final OnRequestCameraActionCallback? onRequestCameraActionCallback;

  final OnImageInsertedCallback? onImageInsertedCallback;

  final OnImageInsertCallback? _onImageInsertCallback;

  OnImageInsertCallback get onImageInsertCallback {
    return _onImageInsertCallback ?? defaultOnImageInsertCallback();
  }
}
