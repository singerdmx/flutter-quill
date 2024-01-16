import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../models/config/video/editor/video_configurations.dart';
import '../../../utils/element_utils/element_utils.dart';
import '../../../utils/utils.dart';
import '../../widgets/video_app.dart';
import '../../widgets/youtube_video_app.dart';

class QuillEditorVideoEmbedBuilder extends EmbedBuilder {
  const QuillEditorVideoEmbedBuilder({
    required this.configurations,
  });

  final QuillEditorVideoEmbedConfigurations configurations;

  @override
  String get key => BlockEmbed.videoType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(!kIsWeb, 'Please provide video EmbedBuilder for Web');

    final videoUrl = node.value.data;
    if (isYouTubeUrl(videoUrl)) {
      return YoutubeVideoApp(
        videoUrl: videoUrl,
        readOnly: readOnly,
      );
    }
    final ((elementSize), margin, alignment) = getElementAttributes(
      node,
      context,
    );

    final width = elementSize.width;
    final height = elementSize.height;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(margin ?? 0.0),
      alignment: alignment,
      child: VideoApp(
        videoUrl: videoUrl,
        context: context,
        readOnly: readOnly,
        onVideoInit: configurations.onVideoInit,
      ),
    );
  }
}
