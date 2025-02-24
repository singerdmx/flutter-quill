import 'package:flutter_quill/flutter_quill.dart';

@Deprecated('Invalid extension')
extension QuillControllerExt on QuillController {
  @Deprecated(
      'Invalid extension property and will be removed, use selection.baseOffset instead')
  int get index => selection.baseOffset;
  @Deprecated(
      'Invalid extension property and will be removed, use selection.extentOffset - selection.baseOffset instead')
  int get length => selection.extentOffset - index;

  @Deprecated('Invalid extension method and will be removed.')
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

  @Deprecated('Invalid extension method and will be removed.')
  void insertVideoBlock({
    required String videoUrl,
  }) {
    this
      ..skipRequestKeyboard = true
      ..replaceText(index, length, BlockEmbed.video(videoUrl), null)
      ..moveCursorToPosition(index + 1);
  }
}
