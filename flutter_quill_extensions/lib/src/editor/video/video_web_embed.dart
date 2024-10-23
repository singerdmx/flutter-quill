import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;

import '../../common/utils/dart_ui/dart_ui_fake.dart'
    if (dart.library.js_interop) '../../common/utils/dart_ui/dart_ui_real.dart'
    as ui;
import '../../common/utils/element_utils/element_web_utils.dart';
import '../../common/utils/utils.dart';
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

    ui.PlatformViewRegistry().registerViewFactory(
      videoUrl,
      (id) => html.IFrameElement()
        ..style.width = width
        ..style.height = height
        ..src = videoUrl
        ..style.border = 'none'
        ..style.margin = margin
        ..style.alignSelf = alignment
        ..attributes['loading'] = 'lazy',
    );

    return SizedBox(
      height: 500,
      child: HtmlElementView(
        viewType: videoUrl,
      ),
    );
  }
}
