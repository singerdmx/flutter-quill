import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/video_config.dart';
import 'widgets/video_app.dart';

class QuillEditorVideoEmbedBuilder extends EmbedBuilder {
  const QuillEditorVideoEmbedBuilder({
    required this.config,
  });

  final QuillEditorVideoEmbedConfig config;

  @override
  String get key => BlockEmbed.videoType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final videoUrl = embedContext.node.value.data;

    final customVideoBuilder = config.customVideoBuilder;
    if (customVideoBuilder != null) {
      final videoWidget = customVideoBuilder(videoUrl, embedContext.readOnly);
      if (videoWidget != null) {
        return videoWidget;
      }
    }

    final ((elementSize), margin, alignment) = getElementAttributes(
      embedContext.node,
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
        readOnly: embedContext.readOnly,
        onVideoInit: config.onVideoInit,
      ),
    );
  }
}
