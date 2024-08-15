import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:meta/meta.dart' show immutable;

import 'youtube_video_support_mode.dart';

@immutable
class QuillEditorVideoEmbedConfigurations {
  const QuillEditorVideoEmbedConfigurations({
    this.onVideoInit,
    this.youtubeVideoSupportMode = YoutubeVideoSupportMode.iframeView,
  });

  /// [onVideoInit] is a callback function that gets triggered when
  ///  a video is initialized.
  /// You can use this to perform actions or setup configurations related
  ///  to video embedding.
  ///
  ///
  /// Example usage:
  /// ```dart
  ///   onVideoInit: (videoContainerKey) {
  ///     // Custom video initialization logic
  ///   },
  ///   // Customize other callback functions as needed
  /// ```
  final void Function(GlobalKey videoContainerKey)? onVideoInit;

  /// Specifies how YouTube videos should be loaded if the video URL
  /// is YouTube video.
  final YoutubeVideoSupportMode youtubeVideoSupportMode;
}
