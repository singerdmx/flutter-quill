import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_web_utils.dart';
import '../../common/utils/utils.dart';
import '../../common/utils/web/web.dart';
import 'config/video_web_config.dart';
import 'youtube_video_url.dart';

class QuillEditorWebVideoEmbedBuilder extends EmbedBuilder {
  const QuillEditorWebVideoEmbedBuilder({
    required this.config,
  });

  final QuillEditorWebVideoEmbedConfig config;

  @override
  String get key => BlockEmbed.videoType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    var videoUrl = embedContext.node.value.data;
    if (isYouTubeUrl(videoUrl)) {
      // ignore: deprecated_member_use_from_same_package
      final youtubeID = convertVideoUrlToId(videoUrl);
      if (youtubeID != null) {
        videoUrl = 'https://www.youtube.com/embed/$youtubeID';
      }
    }

    final (height, width, margin, alignment) =
        getWebElementAttributes(embedContext.node);

    createHtmlIFrameElement(
      src: videoUrl,
      width: width,
      height: height,
      margin: margin,
      alignSelf: alignment,
    );

    return SizedBox(
      height: 500,
      child: HtmlElementView(
        viewType: videoUrl,
      ),
    );
  }
}
