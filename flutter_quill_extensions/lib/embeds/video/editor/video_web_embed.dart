import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    show YoutubePlayer;

import '../../../models/config/video/editor/video_web_configurations.dart';
import '../../../utils/dart_ui/dart_ui_fake.dart'
    if (dart.library.html) '../../../utils/dart_ui/dart_ui_real.dart' as ui;
import '../../../utils/element_utils/element_web_utils.dart';
import '../../../utils/utils.dart';

class QuillEditorWebVideoEmbedBuilder extends EmbedBuilder {
  const QuillEditorWebVideoEmbedBuilder({
    required this.configurations,
  });

  final QuillEditorWebVideoEmbedConfigurations configurations;

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
    var videoUrl = node.value.data;
    if (isYouTubeUrl(videoUrl)) {
      final youtubeID = YoutubePlayer.convertUrlToId(videoUrl);
      if (youtubeID != null) {
        videoUrl = 'https://www.youtube.com/embed/$youtubeID';
      }
    }

    final (height, width, margin, alignment) = getWebElementAttributes(node);

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
