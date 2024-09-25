import 'package:flutter/widgets.dart' show GlobalKey, Widget;
import 'package:meta/meta.dart' show experimental, immutable;

import 'youtube_video_support_mode.dart';

@immutable
class QuillEditorVideoEmbedConfigurations {
  const QuillEditorVideoEmbedConfigurations({
    this.onVideoInit,
    @Deprecated(
      'Loading youtube videos is no longer built-in feature of flutter_quill_extensions.\n'
      'See https://github.com/singerdmx/flutter-quill/issues/2284.\n'
      'Try to use the experimental `customVideoBuilder` property to implement\n'
      'your own YouTube logic using packages such as '
      'https://pub.dev/packages/youtube_video_player or https://pub.dev/packages/youtube_player_flutter',
    )
    this.youtubeVideoSupportMode = YoutubeVideoSupportMode.disabled,
    this.ignoreYouTubeSupport = false,
    this.customVideoBuilder,
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
  @Deprecated(
    'Loading youtube videos is no longer built-in feature of flutter_quill_extensions.\n'
    'See https://github.com/singerdmx/flutter-quill/issues/2284.\n'
    'Try to use the experimental `customVideoBuilder` property to implement\n'
    'your own YouTube logic using packages such as '
    'https://pub.dev/packages/youtube_video_player or https://pub.dev/packages/youtube_player_flutter',
  )
  final YoutubeVideoSupportMode youtubeVideoSupportMode;

  /// Pass `true` to ignore anything related to YouTube which will disable
  /// This functionality is without any warnings.
  ///
  /// Making it `true`, means that the video embed widget will no longer
  /// check for the video URL and expect it a valid and a standrad video URL.
  ///
  /// This property will be removed in future releases once YouTube support is
  /// removed.
  ///
  /// Use [customVideoBuilder] to load youtube videos.
  @experimental
  @Deprecated(
    'Will be removed in future releases. Exist to allow users to ignore warnings.',
  )
  final bool ignoreYouTubeSupport;

  /// [customVideoBuilder] is a callback function that receives the
  /// video URL and a read-only flag. This allows users to define
  /// their own logic for rendering video widgets, enabling support
  /// for various video platforms, such as YouTube.
  ///
  /// Example usage:
  /// ```dart
  ///   customVideoBuilder: (videoUrl, readOnly) {
  ///     // Return `null` to fallback to defualt logic of QuillEditorVideoEmbedBuilder
  ///
  ///     // Return a custom video widget based on the videoUrl
  ///     return CustomVideoWidget(videoUrl: videoUrl, readOnly: readOnly);
  ///   },
  /// ```
  ///
  /// It's a quick solution as response to https://github.com/singerdmx/flutter-quill/issues/2284
  ///
  /// **Might be removed or changed in future releases.**
  @experimental
  final Widget? Function(String videoUrl, bool readOnly)? customVideoBuilder;
}
