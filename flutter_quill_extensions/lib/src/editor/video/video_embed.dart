import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import '../../common/utils/utils.dart';
import 'models/video_configurations.dart';
import 'widgets/video_app.dart';
import 'widgets/youtube_video_app.dart';

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

    final customVideoBuilder = configurations.customVideoBuilder;
    if (customVideoBuilder != null) {
      final videoWidget = customVideoBuilder(videoUrl, readOnly);
      if (videoWidget != null) {
        return videoWidget;
      }
    }

    // ignore: deprecated_member_use_from_same_package
    if (isYouTubeUrl(videoUrl) && !configurations.ignoreYouTubeSupport) {
      assert(() {
        debugPrint(
          "It seems that you're loading a youtube video URL.\n"
          'Loading YouTube videos is no longer built-in feature as part of flutter_quill_extensions.\n'
          'This message will only appear in development mode. See https://github.com/singerdmx/flutter-quill/issues/2284\n'
          'Consider using the experimental property `QuillEditorVideoEmbedConfigurations.customVideoBuilder` in your configuration.\n'
          'This message will only included in development mode.\n',
        );
        return true;
      }());

      /// Will be removed soon in future releases

      // ignore: deprecated_member_use_from_same_package
      return YoutubeVideoApp(
        videoUrl: videoUrl,
        readOnly: readOnly,
        // ignore: deprecated_member_use_from_same_package
        youtubeVideoSupportMode: configurations.youtubeVideoSupportMode,
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
        readOnly: readOnly,
        onVideoInit: configurations.onVideoInit,
      ),
    );
  }
}
