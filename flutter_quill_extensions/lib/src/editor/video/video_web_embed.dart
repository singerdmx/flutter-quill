import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    show YoutubePlayer;

import '../../common/utils/dart_ui/dart_ui_fake.dart'
    if (dart.library.js_interop) '../../common/utils/dart_ui/dart_ui_real.dart'
    as ui;
import '../../common/utils/element_utils/element_web_utils.dart';
import '../../common/utils/utils.dart';
import 'models/video_web_configurations.dart';

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
