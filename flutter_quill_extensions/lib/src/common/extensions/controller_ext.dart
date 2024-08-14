import 'package:flutter_quill/flutter_quill.dart';

/// Extension functions on [QuillController]
/// that make it easier to insert the embed blocks
///
/// and provide some other extra utilities
extension QuillControllerExt on QuillController {
  int get index => selection.baseOffset;
  int get length => selection.extentOffset - index;

  /// Insert image embed block, it requires the [imageSource]
  ///
  /// it could be local image on the system file
  /// http image on the network
  ///
  /// image base 64
  void insertImageBlock({
    required String imageSource,
  }) {
    this
      ..skipRequestKeyboard = true
      ..replaceText(
        index,
        length,
        BlockEmbed.image(imageSource),
        null,
      )
      ..moveCursorToPosition(index + 1);
  }

  /// Insert video embed block, it requires the [videoUrl]
  ///
  /// it could be the video url directly (.mp4)
  /// either locally on file system
  /// or http video on the network
  ///
  /// it also supports youtube video url
  void insertVideoBlock({
    required String videoUrl,
  }) {
    this
      ..skipRequestKeyboard = true
      ..replaceText(index, length, BlockEmbed.video(videoUrl), null)
      ..moveCursorToPosition(index + 1);
  }
}
